#! /bin/bash
#JOBNUM=4
#NPWD=`realpath .`
echo "making rootfs"
mkdir -p rootfs
cd rootfs
mkdir -p dev etc mnt proc var tmp sys root lib
sudo mknod dev/null c 1 3
sudo mknod dev/zero c 1 5
sudo mknod dev/console c 5 1

cat <<   INITEOF > etc/inittab
::sysinit:/etc/init.d/rcS #系统启动脚本
::ctrlaltdel:/sbin/reboot #组合键Ctrl+Alt+Del组合键，重启系统
::shutdown:/bin/umount -a -r #关机前umount所有挂载
ttyS0::respawn:-/bin/login #启动串口终端，如果需要登录改为/bin/login
#ttyS0::askfirst:-/bin/login #启动串口终端，如果需要登录改为/bin/login
#ttyS0::askfirst:-/bin/sh #启动串口终端，如果需要登录改为/bin/login
INITEOF

mkdir -p etc/init.d
cat << RCSEOF > etc/init.d/rcS
# !/bin/sh
mount -a #首先挂载所有在fstab定义的内容
mkdir /dev/pts
mount -t devpts devpts /dev/pts
/bin/hostname -F /etc/hostname
ifconfig usb0 192.168.137.2 
route add default gw 192.168.137.1
RCSEOF
sudo chmod +x etc/init.d/rcS


cat << FSEOF > etc/fstab
proc /proc proc defaults 0 0
sysfs /sys sysfs defaults 0 0
mdev /dev tmpfs defaults 0 0
none /tmp tmpfs defaults 0 0
none /var tmpfs defaults 0 0
FSEOF

mkdir -p etc/network
cat << NETEOF > etc/network/interfaces
auto lo
iface lo inet loopback

#auto eth0
#iface eth0 inet dhcp
#  pre-up /etc/network/nfs_check
#  wait-delay 15
#  hostname $(hostname)

auto usb0
iface usb0 inet static
pre-up /etc/network/nfs_check
address 192.168.137.2
netmask 255.255.255.0
gateway 192.168.137.1
#dns-nameservers 233.6.6.6 192.168.137.1 211.136.20.203
NETEOF

cat << DNSEOF > etc/resolv.conf
nameserver 192.168.137.1
nameseverr 233.6.6.6
nameseverr 10.8.16.30
DNSEOF

cat << HOSTEOF > etc/hostname
vencolfs
HOSTEOF

#cp -a $NPWD/../gcc/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf/arm-linux-gnueabihf/libc/lib/ lib
#rm -f lib/*.a
#去除符号表，节省空间，但是不能反汇编了
#${COMPILE_DIR}arm-none-linux-gnueabi-strip rootfs/lib/*

#下面的是用户相关的信息，自行修改
cat << PWEOF > etc/passwd
root:FMKTwEUCSZm9Q:0:0:root:/root:/bin/sh
PWEOF

cat << GEOF > etc/group
root:x:0:
GEOF

#cat << SHEOF > etc/shadow
#root:$6$B7gzTyFF$Zm2fC5EQYdqupH.BwccJv0YX4XingPOqsMcu1vlWC4AaKof4ycDGlXooMs2m5ZxfDPvjhDicnkt/PuGBDqZtD1:18316:0:99999:7:::
#SHEOF

cat << PROEOF > etc/profile
USER="`id -un`"
LOGNAME=$USER #登录之后使用用户名显示
HOSTNAME="rootfs_by_vencol"     #主机名
#HOSTNAME='/bin/hostname'
PS1="[\u@\h \w]# "      #终端显示信息
alais ll="ls -al"

if [ ! -z ${SSH_TTY} ]; then
   export PATH=/sbin:/usr/sbin:/bin:/usr/bin
fi
PROEOF

GCCLIB=/home/vencol/code/gcc/sysroot-glibc-linaro-2.25-2019.12-rc1-arm-linux-gnueabihf/lib
#cp $GCCLIB/ld-linux-armhf.so.3 $GCCLIB/libc.so.6 $GCCLIB/libm.so.6 $GCCLIB/libresolv.so.2 lib/

# HAVELL=cat etc/bash.bashrc | grep "alias ll= 'ls -al' "
# if [ "$HAVELL" == "" ]; then
#    cat "alias ll= 'ls -al' " >> etc/bash.bashrc
# fi

