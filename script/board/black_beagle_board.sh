#! /bin/bash

MYBOARD=bbb
NPWD=/home/vencol/code/board/boardbuild/$MYBOARD


ARCH=arm
CROSS_COMPILE=/home/vencol/code/gcc/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-

SPLOFFSET=128
SPLPATH=$NPWD/bootbuild/MLO

BOOTOFFSET=384
BOOTSIZE=500
BOOTPATH=$NPWD/bootbuild/u-boot.img

ENVPATH=$NPWD/uEnv.txt
IMGPATH=$NPWD/linuxbuild/arch/arm/boot/zImage
DTBPATH=$NPWD/linuxbuild/arch/arm/boot/dts/am335x-boneblack.dtb

# export ARCH CROSS_COMPILE MYBOARD
# export SPLOFFSET SPLPATH
# export BOOTOFFSET BOOTSIZE BOOTPATH
# export ENVPATH IMGPATH DTBPATH