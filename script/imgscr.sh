#! /bin/bash
CONFIG_BOARD=$MYBOARD
echo "making $CONFIG_BOARD sdimg fat:${1}M rootfs:${2}M"
BOOTPARTSIZE=$1
FSPARTSIZE=$2
mkdir -p images
cd images
mkdir -p bootdir
mkdir -p linuxdir
echo $PWD
SDIMG="sd.img"
if [ $BOOTPARTSIZE -lt 6 ];then
        echo "boot part size must larget than 6M"
        exit 1
fi
if [ $FSPARTSIZE -lt 3 ];then
        echo "rootfs part size must larget than 2M"
        exit 1
fi

if [ "${CONFIG_BOARD}_x" == "bbb_x" ];then
        TABLESIZE=2
else
        TABLESIZE=1
fi
FATSTART=$[ ${TABLESIZE} * 1024 * 1024 / 512 ]
TOTALSIZE=$[ ($BOOTPARTSIZE + $FSPARTSIZE + $TABLESIZE)*1024 + 10 ]
dd if=/dev/zero of=${SDIMG} bs=1k count=$TOTALSIZE > /dev/null 2>&1
dd if=$SPLPATH of=${SDIMG} conv=notrunc seek=1 bs=${SPLOFFSET}k > /dev/null 2>&1
dd if=$BOOTPATH of=${SDIMG} conv=notrunc seek=1 bs=${BOOTOFFSET}k > /dev/null 2>&1

echo "tablesize : $TABLESIZE fat : $FATSTART ext4 : $EXTSTART total : $TOTALSIZE/1024"
#create img partition table
cat << FDISK_EOF | sudo fdisk ${SDIMG} > /dev/null 2>&1
n
p
1
${FATSTART}
+${BOOTPARTSIZE}M
n
p
2

+${FSPARTSIZE}M
t
1
c
a
1
w
p
FDISK_EOF
# echo -e "n\np\n1\n${FATSTART}\n+${BOOTPARTSIZE}M\nn\np\n2\n${EXTSTART}\n+${FSPARTSIZE}M\nt\n1\nc\na\n1\nw\n" | sudo fdisk ${SDIMG} > /dev/null 2>&1
if [ $? -ne 0 ]; then
        echo "make img partition table error for size"
        exit 1
fi
sync
sleep 2
partprobe -s ${SDIMG}  > /dev/null 2>&1

sudo kpartx -av ${SDIMG}
BOOTPART=` ls /dev/mapper | grep "p1$" `
ROOTPART=` ls /dev/mapper | grep "p2$" `
if [ "$BOOTPART" == "" -o "$ROOTPART" == "" ]; then
        echo "ERROR mounting partitions..."
        sudo kpartx -dv ${SDIMG}
        exit 1
fi
echo " boot in $BOOTPART , root in $ROOTPART "
sudo mkfs -t vfat -F 32 -n BOOT /dev/mapper/$BOOTPART > /dev/null 2>&1
sudo mkfs -t ext4 -F -L ROOTFS /dev/mapper/$ROOTPART > /dev/null 2>&1

echo "  boot partition mounting."
if ! sudo mount /dev/mapper/$BOOTPART bootdir; then
        echo "ERROR mounting fat boot partitions..."
        sudo kpartx -dv ${SDIMG}
        exit 1
fi
sudo cp -rf $IMGPATH $NPWD/images/bootdir/
sudo cp -rf $DTBPATH $NPWD/images/bootdir/
sudo cp -rf $ENVPATH $NPWD/images/bootdir/
sync
if ! sudo umount bootdir; then
        echo "ERROR unmounting fat boot partition."
fi


echo "  rootfs linux partition mounting."
if ! sudo mount -t ext4 /dev/mapper/$ROOTPART linuxdir; then
        echo "ERROR mounting rootfs linux partitions..."
        exit 1
fi
mkdir -p $NPWD/tmp
cp -r $NPWD/rootfs/root/*  $NPWD/tmp
sudo rsync -r -t -p -o -g -x --delete -l -H -D --numeric-ids -s --stats $NPWD/rootfs/ linuxdir > /dev/null 2>&1
if [ $? -ne 0 ]; then
        echo "ERROR copying rootfs linux partition, maybe not enough size for rootfs"
        sudo umount linuxdir
        sudo kpartx -dv ${SDIMG}
        exit 0
fi
sync
if ! sudo umount linuxdir; then
        echo "ERROR unmounting rootfs linux partitions."
fi
sudo kpartx -dv ${SDIMG}
mv $NPWD/tmp/* $NPWD/rootfs/root/ 
rm -rf $NPWD/tmp

cat << FDISK_EOF | sudo fdisk ${SDIMG} #> /dev/null 2>&1
p
q
FDISK_EOF
echo "create sd.img success in $NPWD/images"
