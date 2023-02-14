find /dev/disk/by-id/
DISK=/dev/disk/by-id/ata-TOSHIBA_Q300._46DB5111K1MU
git clone https://github.com/ne9z/dotfiles-nixos.git
INST_PARTSIZE_SWAP=8
diskNames=""
for i in $DISK; do   diskNames="$diskNames \"${i##*/}\""; done
tee -a dotfiles-nixos/.config/nixos/machine.nix <<EOF
{
  bootDevices = [ $diskNames ];
}
EOF

for i in ${DISK}; do blkdiscard -f $i sgdisk --zap-all $i sgdisk -n1:1M:+1G -t1:EF00 $i sgdisk -n2:0:+4G -t2:BE00 $i sgdisk -n4:0:+${INST_PARTSIZE_SWAP}G -t4:8200 $i if test -z $INST_PARTSIZE_RPOOL; then     sgdisk -n3:0:0   -t3:BF00 $i; else     sgdisk -n3:0:+${INST_PARTSIZE_RPOOL}G -t3:BF00 $i; fi sgdisk -a1 -n5:24K:+1000K -t5:EF02 $i sync && udevadm settle && sleep 3; cryptsetup open --type plain --key-file /dev/random $i-part4 ${i##*/}-part4; mkswap /dev/mapper/${i##*/}-part4; swapon /dev/mapper/${i##*/}-part4; done
zpool create       -o compatibility=grub2       -o ashift=12       -o autotrim=on       -O acltype=posixacl       -O canmount=off       -O compression=lz4       -O devices=off       -O normalization=formD       -O atime=off       -O xattr=sa       -O mountpoint=/boot       -R /mnt     bpool       $(for i in ${DISK}; do
	    printf "$i-part2 ";
	done)
zpool create       -o ashift=12       -o autotrim=on       -R /mnt        -O  acltype=posixacl       -O canmount=off       -O compression=zstd       -O dnodesize=auto       -O normalization=formD       -O atime=off       -O xattr=sa       -O mountpoint=/       rpool       $(for i in ${DISK}; do
      printf "$i-part3 ";
     done)
echo poolpass |     zfs create 	-o canmount=off 	-o mountpoint=none 	-o encryption=on 	-o keylocation=prompt 	-o keyformat=passphrase 	rpool/nixos
zfs create -o mountpoint=legacy     rpool/nixos/root
mount -t zfs rpool/nixos/root /mnt/
zfs create -o mountpoint=legacy rpool/nixos/home
mkdir /mnt/home
mount -t zfs  rpool/nixos/home /mnt/home
zfs create -o mountpoint=legacy  rpool/nixos/var
zfs create -o mountpoint=legacy rpool/nixos/var/lib
zfs create -o mountpoint=legacy rpool/nixos/var/log
zfs create -o mountpoint=none bpool/nixos
zfs create -o mountpoint=legacy bpool/nixos/root
mkdir /mnt/boot
mount -t zfs bpool/nixos/root /mnt/boot
zfs create -o mountpoint=legacy rpool/nixos/empty
zfs snapshot rpool/nixos/empty@start
for i in ${DISK}; do     mkfs.vfat -n EFI ${i}-part1;     mkdir -p /mnt/boot/efis/${i##*/}-part1;     mount -t vfat ${i}-part1 /mnt/boot/efis/${i##*/}-part1; done
mv dotfiles-nixos /mnt/home/user
cp -r /mnt/home/user/.config/nixos/ /mnt/etc/
chown -R 1001:100 /mnt/home/user/
history -w /mnt/home/user/.config/nixos/inst.sh
