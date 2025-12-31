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

# Attach mounts
#	Use basic permissions on ESP to suppress filesystem warning during pacstrap
sudo mount $part_root /mnt/
sudo mount -m $part_efi /mnt/boot/

# Get top 10 of 25 latest synchronized https mirrors sorted by download rate
#	Updates local mirrorlist to be shared with root by pacstrap
sudo reflector -c US,CA,GB -l 25 -n 10 -p https \
	--save /etc/pacman.d/mirrorlist --sort rate --verbose

# Use default keymap on root
#	Removes error on first initramfs image generation
sudo mkdir -p /mnt/etc/
echo KEYMAP=us | sudo tee /mnt/etc/vconsole.conf

# Begin system installation using basic packages
sudo pacstrap -K /mnt \
	base cloud-guest-utils cloud-init linux \
	man-db man-pages openssh vim

# Generate fstab to persist filesystem hierarchy
#	Removes swap partitions
#	Removes Group/Others file/directory permissions on /mnt/boot/
genfstab -U /mnt \
	| sed '/swap/d; s/\(mask=00\)22/\177/g' \
	| sudo tee -a /mnt/etc/fstab

# Add domain name resolution for software that reads /etc/resolv.conf directly
#	Done outside of root because arch-chroot adds the link temporarily
sudo ln -fsv /run/systemd/resolve/stub-resolv.conf /mnt/etc/resolv.conf

# Reattach ESP with proper permissions prior to arch-chroot
#	Requires a detach/attach cycle to set FAT-specific options
#	Suppresses systemd-boot "Security Holes" warning
sudo umount /mnt/boot/
sudo mount -o dmask=0077,fmask=0077 $part_efi /mnt/boot/

# Change root and configure installation
sudo arch-chroot -S /mnt sh <<-EOF
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

	# Configure mkinitcpio.conf and regenerate initramfs image
	hooks='base systemd autodetect modconf block filesystems fsck'

	sed -i "s/^\(HOOKS=(\).*)/\1\$hooks)/" /etc/mkinitcpio.conf
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
		options root=UUID=$(lsblk -dno UUID $part_root) rw
	EOFROOT

	# Display updated systemd-boot config
	bootctl status | cat

	# Reset all pacman keys on the system
	#	Allows root to be unmounted
	rm -fr /etc/pacman.d/gnupg/
EOF

# Detach mounts and loop device
sudo umount /mnt/boot/
sudo umount /mnt/

sudo losetup -d $device
