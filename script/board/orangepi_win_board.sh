#! /bin/bash
MYBOARD=opiwin
NPWD=/home/vencol/code/board/boardbuild/$MYBOARD


ARCH=aarch64
CROSS_COMPILE=/home/vencol/code/gcc/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-

SPLOFFSET=8
SPLPATH=$NPWD/bootbuild/spl/sunxi-spl.bin

BOOTOFFSET=40
BOOTSIZE=800
BOOTPATH=$NPWD/bootbuild/u-boot.itb

ENVPATH=$NPWD/uEnv.txt
IMGPATH=$NPWD/linuxbuild/arch/arm64/boot/Image
DTBPATH=$NPWD/linuxbuild/arch/arm64/boot/dts/allwinner/sun50i-a64-orangepi-win.dtb


# export ARCH CROSS_COMPILE MYBOARD
# export SPLOFFSET SPLPATH
# export BOOTOFFSET BOOTSIZE BOOTPATH
# export ENVPATH IMGPATH DTBPATH