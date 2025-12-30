#!/bin/sh
# Builds an Arch Linux Amazon Machine Image

set -e

# Directory of this script
dir=$(dirname "$(readlink -f "$0")")
file=archlinux-$(date +%Y.%m.%d)-$(uname -m).img

# Allocate disk space for loop device file association
dd if=/dev/zero of=$dir/$file bs=1 count=0 seek=8G

# Initialize loop device
device=$(sudo losetup -fPv --show $dir/$file)
part_efi=${device}p1
part_root=${device}p2

# Create EFI System and root partitions
sudo sfdisk --lock $device <<-EOF
	label: gpt
	attrs=RequiredPartition, size=1GiB, type=uefi
	attrs=RequiredPartition, size=+, type=linux
EOF

# Format filesystems
sudo mkfs.fat -F 32 $part_efi
sudo mkfs.ext4 $part_root

# Prepare mount points
sudo mount $part_root /mnt/
sudo mount --mkdir $part_efi /mnt/boot/

# Get top 10 of 25 latest synchronized https mirrors sorted by download rate
#	Will update local mirrorlist and be transferred to root by pacstrap
sudo reflector -c US,CA,GB -l 25 -n 10 -p https \
	--save $path/mirrorlist --sort rate --verbose

# Begin system installation using basic packages
sudo pacstrap -K /mnt \
	base cloud-guest-utils cloud-init linux \
	man-db man-pages openssh reflector vim

# Generate fstab to persist filesystem hierarchy
#	Removes active swap partitions
#	Removes Group/Others file/directory permissions on /mnt/boot/
#		Fixes systemd-boot security holes
genfstab -U /mnt \
	| sed '/swap/d; s/\(mask=00\)22/\177/g'
	| sudo tee -a /mnt/etc/fstab

# Add domain name resolution for software that reads /etc/resolv.conf directly
sudo ln -fsv /run/systemd/resolve/stub-resolv.conf /mnt/etc/resolv.conf

# Root UUID is needed for systemd-boot on root
uuid_root=$(lsblk -dno UUID $part_root)

# Change root and configure installation
sudo arch-chroot /mnt sh <<-EOF
	# Set local time to UTC
	ln -fsv /usr/share/zoneinfo/UTC /etc/localtime

	# Configure locale
	sed -i 's/^#\(en_US\)/\1/' /etc/locale.gen
	locale-gen

	echo LANG=en_US.UTF-8 >>/etc/locale.conf

	# Add wheel group sudo permissions and add default user to wheel group
	echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >>/etc/sudoers.d/20-wheel
	sed -i 's/\(groups: \[wheel\).*\]/\1]/; /sudo: \[.*\]/d' \
		/etc/cloud/cloud.cfg

	# Configure basic SSH settings
	sed -i 's/^#\(Port 22\)/\1/
	s/^#\(PasswordAuthentication\).*/\1 no\nAuthenticationMethods publickey/' \
		/etc/ssh/sshd_config

	# Remove password from root in case exists
	#	Root user disabled by cloud-init
	#	Prompts user to log in as default user
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

	sed -i 's/^\(HOOKS=(\).*)/\1\$hooks)/' /etc/mkinitcpio.conf
	mkinitcpio -P

	# Configure systemd-boot
	#	Firmware is inaccessible and EFI variables are not needed
	bootctl --variables=no install

	cat >/boot/loader/loader.conf <<-EOFROOT
		default arch.conf
		editor no
	EOFROOT

	cat >/boot/loader/entries/arch.conf <<-EOFROOT
		title Arch Linux
		linux /vmlinuz-linux
		initrd /initramfs-linux.img
		options root=UUID=$uuid_root rw
	EOFROOT

	# Display updated systemd-boot config
	bootctl

	# Reset all pacman keys on the system
	#	Allows root to be unmounted
	rm -fr /etc/pacman.d/gnupg/
EOF

# Unmount mount points and detach loop device
sudo umount /mnt/boot/
sudo umount /mnt/

sudo losetup -d $device
