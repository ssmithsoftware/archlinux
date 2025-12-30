#!/bin/sh
# Builds an Arch Linux Amazon Machine Image

set -e

# Directory of this script
dir=$(dirname "$(readlink -f "$0")")
file=archlinux-$(date +%Y.%m.%d)-$(uname -m).img

# Allocate space for loop device file
dd if=/dev/zero of=$dir/$file bs=1 count=0 seek=8G

# Setup loop device
device=$(sudo losetup -fPv --show $dir/$file)

# Create EFI System and Root partitions
sudo sfdisk --lock $device <<-EOF
	label: gpt
	attrs=RequiredPartition, size=1GiB, type=uefi
	attrs=RequiredPartition, size=+, type=linux
EOF

part_efi=${device}p1
part_root=${device}p2

# Format filesystems
sudo mkfs.fat -F 32 $part_efi
sudo mkfs.ext4 $part_root

# Prepare mount points
sudo mount $part_root /mnt/
sudo mount --mkdir $part_efi /mnt/boot/

# Get top 10 of 25 latest synchronized https mirrors sorted by download rate
sudo reflector -c US,CA,GB -l 25 -n 10 -p https \
	--save $path/mirrorlist --sort rate --verbose

# Begin system installation
sudo pacstrap -K /mnt \
	base cloud-guest-utils cloud-init linux \
	man-db man-pages openssh reflector vim

# Generate fstab and persist filesystem hierarchy
# Exclude any active swap partitions
# Remove group/others file/directory permissions on /mnt/boot/
genfstab -U /mnt \
	| sed '/swap/d; s/\(mask=00\)22/\177/g'
	| sudo tee -a /mnt/etc/fstab

# Add domain name resolution for software that reads /etc/resolv.conf directly
sudo ln -fsv /run/systemd/resolve/stub-resolv.conf /mnt/etc/resolv.conf

uuid_root=$(lsblk -dno UUID $part_root)

# Change and setup new root
sudo arch-chroot /mnt sh <<-EOF
	# Set time to UTC
	ln -fsv /usr/share/zoneinfo/UTC /etc/localtime

	# Configure locale
	sed -i 's/^#\(en_US\)/\1/' /etc/locale.gen
	locale-gen

	echo LANG=en_US.UTF-8 >>/etc/locale.conf

	# Adjust wheel sudo permissions and add default user to wheel
	echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >>/etc/sudoers.d/20-wheel
	sed -i 's/\(groups: \[wheel\).*\]/\1]/; /sudo: \[.*\]/d' \
		/etc/cloud/cloud.cfg

	# Configure SSH
	sed -i 's/^#\(Port 22\)/\1/
	s/^#\(PasswordAuthentication\).*/\1 no\nAuthenticationMethods publickey/' \
		/etc/ssh/sshd_config

	# Remove password from root
	passwd -d root

	# Start basic systemd services
	systemctl enable cloud-final.service
	systemctl enable cloud-init-main.service
	systemctl enable fstrim.timer
	systemctl enable sshd.service
	systemctl enable systemd-networkd.service
	systemctl enable systemd-resolved.service
	systemctl enable systemd-timesyncd.service

	# Set default target to multi-user for headless environment
	systemctl set-default multi-user.target

	# Add basic network config
	ln -fsv /usr/lib/systemd/network/89-ethernet.network.example \
		/etc/systemd/network/89-ethernet.network

	# Configure mkinitcpio.conf
	hooks='base systemd autodetect modconf block filesystems fsck'

	sed -i 's/^\(HOOKS=(\).*)/\1\\$hooks)/' /etc/mkinitcpio.conf
	mkinitcpio -P

	# Configure systemd-boot
	bootctl --variables=no install

	cat >/boot/loader/loader.conf <<-EOFCHROOT
		default arch.conf
		editor no
	EOFCHROOT

	cat >/boot/loader/entries/arch.conf <<-EOFCHROOT
		title Arch Linux
		linux /vmlinuz-linux
		initrd /initramfs-linux.img
		options root=UUID=$uuid_root rw
	EOFCHROOT

	# Display updated systemd-boot config
	bootctl

	# Reset all keys on the system
	rm -fr /etc/pacman.d/gnupg/
EOF

# Unmount mount points and detach loop device
sudo umount /mnt/boot/
sudo umount /mnt/
sudo losetup -d $device
