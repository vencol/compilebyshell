#! /bin/bash
NPWD=/home/vencol/code/board/opione


ARCH=aarch64
MYBOARD=opiwin
CROSS_COMPILE=/home/vencol/code/gcc/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-

SPLOFFSET=8
SPLPATH=$NPWD/bootbuild/spl/sunxi-spl.bin

BOOTOFFSET=40
BOOTSIZE=800
BOOTPATH=$NPWD/bootbuild/u-boot.itb
BOOTDEFCONFIG=configs/opione/uboot-config

ENVPATH=$NPWD/script/uEnv.txt
IMGPATH=$NPWD/linuxbuild/arch/arm64/boot/Image
DTBPATH=$NPWD/linuxbuild/arch/arm64/boot/dts/allwinner/sun50i-a64-orangepi-win.dtb
KERNELDEFCONFIG=configs/opione/linux-config

# export ARCH CROSS_COMPILE MYBOARD
# export SPLOFFSET SPLPATH
# export BOOTOFFSET BOOTSIZE BOOTPATH
# export ENVPATH IMGPATH DTBPATH