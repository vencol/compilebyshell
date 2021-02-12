#! /bin/bash
MYIPADDR=192.168.0.111
TFTPSERVERPATH=~/tftp
NPWD=`realpath .`
CODETOP=`realpath ../../`
SRCPATH=$NPWD/script
BOARDSH_NAME=orangepi_one_board

. $SRCPATH/board/$BOARDSH_NAME.sh
if [ $? != 0 ]; then
    echo "set board param fail, pls set you board config"
    exit 1
fi
export MYBOARD NPWD CODETOP SRCPATH
export ARCH CROSS_COMPILE ENVPATH SPLPATH BOOTPATH IMGPATH DTBPATH SPLOFFSET BOOTOFFSET

if [ $1_x == cp_x ];then
    echo $PWD
	cp $SPLPATH $TFTPSERVERPATH
	cp $BOOTPATH $TFTPSERVERPATH
	cp $ENVPATH $TFTPSERVERPATH
	cp $IMGPATH $TFTPSERVERPATH
	cp $DTBPATH $TFTPSERVERPATH
elif [ $1_x == scr_x ];then
    echo $PWD
    #mkenvimage -s 0x2000 -o uboot.env env.txt #8k
    #mkenvimage -s 0x20000 -o uboot.env env.txt #128k
    if [ ${MYBOARD}_x == opiwin_x ];then
            mkimage -C none -A arm64 -T script -d boot.cmd boot.scr
    else
            mkimage -C none -A arm -T script -d boot.cmd boot.scr
    fi
elif [ $1_x == atf_x ];then
    cd $CODETOP/src/arm-trusted-firmware
    echo $PWD  #arm-trusted-firmware
    mkdir -p $NPWD/atfbuild
    make  CROSS_COMPILE=$CROSS_COMPILE BUILD_BASE=$NPWD/atfbuild PLAT=sun50i_a64  $2
elif [ $1_x == uboot_x ];then
    cd $CODETOP/src/uboot
    echo $PWD  #am335x_evm
    mkdir -p $NPWD/bootbuild
    if [ ${MYBOARD}_x == opiwin_x ];then
            cp $NPWD/atfbuild/sun50i_a64/release/bl31.bin $NPWD/bootbuild
    fi
	if [ "$2" == "baseconfig" ]; then
        cp $SRCPATH/board/$MYBOARD/uboot-config $NPWD/bootbuild/.config
	else
	    make -j8 ARCH=arm CROSS_COMPILE=$CROSS_COMPILE O=$NPWD/bootbuild $2
        cp $SPLPATH $TFTPSERVERPATH
    	cp $BOOTPATH $TFTPSERVERPATH
	fi
elif [ $1_x == linux_x ];then
    cd $CODETOP/src/linux-5.7.7
    echo $PWD
	if [ "$2" == "baseconfig" ]; then
        cp $SRCPATH/board/$MYBOARD/linux-config $NPWD/linuxbuild/.config
	elif [ $2_x == modules_install_x ];then
    	mkdir -p $NPWD/rootfs
    	make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE INSTALL_MOD_PATH=$NPWD/rootfs O=$NPWD/linuxbuild $2
    elif [ $2_x == modules_x ];then
    	make -j8 ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE INSTALL_MOD_PATH=$NPWD/rootfs O=$NPWD/linuxbuild $2 $3
    elif [ $2_x == dtb_x ];then
        DTBNAME=`basename ${DTBPATH}`
    	make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE INSTALL_MOD_PATH=$NPWD/rootfs O=$NPWD/linuxbuild $DTBNAME
    else
        mkdir -p $NPWD/linuxbuild
        make -j8 ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE O=$NPWD/linuxbuild $2
        cp $IMGPATH $TFTPSERVERPATH
        cp $DTBPATH $TFTPSERVERPATH
    fi
elif [ $1_x == busybox_x ];then
    cd $CODETOP/src/busybox
	SYSROOTPATH=$CODETOP/gcc/sysroot-glibc-linaro-2.25-2019.12-rc1-arm-linux-gnueabihf
    echo $PWD
    if [ $2_x == install_x ];then
    	mkdir -p $NPWD/rootfs
       	make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE CONFIG_EXTRA_LDLIBS="resolv" O=$NPWD/bboxbuild CONFIG_PREFIX=$NPWD/rootfs $2
       	#make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE CONFIG_SYSROOT=$SYSROOTPATH CONFIG_EXTRA_LDLIBS="resolv" O=$NPWD/bboxbuild CONFIG_PREFIX=$NPWD/rootfs $2
    else
        mkdir -p $NPWD/bboxbuild
        make -j8 ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE CONFIG_EXTRA_LDLIBS="resolv" O=$NPWD/bboxbuild $2
        #make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE CONFIG_SYSROOT=$SYSROOTPATH CONFIG_EXTRA_LDLIBS="resolv" O=$NPWD/bboxbuild $2
    fi
elif [ $1_x == rootfs_x ];then
    echo $PWD
    mkdir -p $NPWD/rootfs
	cd $CODETOP/src/busybox
	SYSROOTPATH=$CODETOP/gcc/sysroot-glibc-linaro-2.25-2019.12-rc1-arm-linux-gnueabihf
    make -j8 ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE CONFIG_EXTRA_LDLIBS="resolv" O=$NPWD/bboxbuild CONFIG_PREFIX=$NPWD/rootfs install
    #make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE CONFIG_EXTRA_LDLIBS="resolv" SYSROOT=$SYSROOTPATH O=$NPWD/bboxbuild CONFIG_PREFIX=$NPWD/rootfs install
	cd $NPWD
	source $SRCPATH/fsscr.sh
elif [ $1_x == img_x ];then
    echo $PWD
    if [ $2_x == _x -o $3_x == _x ];then
            source $SRCPATH/imgscr.sh 10 10
    else
            source $SRCPATH/imgscr.sh $2 $3
    fi
elif [ $1_x == env_x ];then
    echo $PWD
    #block is sd is 512 ,so * 2
    SPLSTART=`echo "obase=16;$[$SPLOFFSET * 2]" | bc`
    SPLSIZE=`echo "obase=16;$[($BOOTOFFSET - $SPLOFFSET) * 2]" | bc`
    BOOTSTART=`echo "obase=16;$[$BOOTOFFSET * 2]" | bc`
    BOOTSIZE=`echo "obase=16;$[$BOOTSIZE * 2]" | bc`

    ENVNAME=`basename $ENVPATH`
    SPLNAME=`basename $SPLPATH`
    BOOTNAME=`basename $BOOTPATH`
    IMGNAME=`basename $IMGPATH`
    DTBNAME=`basename $DTBPATH`

    echo "hex $SPLSTART $SPLSIZE $BOOTSTART $BOOTSIZEi $SPLNAME"
    sed -i "s/^splstart=.*$/splstart=$SPLSTART/g" $ENVPATH
    sed -i "s/^splsize=.*$/splsize=$SPLSIZE/g" $ENVPATH
    sed -i "s/^bootstart=.*$/bootstart=$BOOTSTART/g" $ENVPATH
    sed -i "s/^bootsize=.*$/bootsize=$BOOTSIZE/g" $ENVPATH
    sed -i "s/^splname=.*$/splname=$SPLNAME/g" $ENVPATH
    sed -i "s/^bootname=.*$/bootname=$BOOTNAME/g" $ENVPATH
    sed -i "s/^imagename=.*$/imagename=$IMGNAME/g" $ENVPATH
    sed -i "s/^dtbname=.*$/dtbname=$DTBNAME/g" $ENVPATH
    if [ ${IMGNAME}_x == Image_x ];then
            sed -i "s/^bootimg=.*$/bootimg=booti \$kernel_addr_r - \$fdt_addr_r/g" $ENVPATH
    else
            sed -i "s/^bootimg=.*$/bootimg=bootz \$kernel_addr_r - \$fdt_addr_r/g" $ENVPATH
    fi
    sed -i "s/^pcip=.*$/pcip=$MYIPADDR/g" $ENVPATH
elif [ $1_x == clean_x ];then
    if [ $2_x == _x ];then
    	sudo rm -r $NPWD/bootbuild $NPWD/linuxbuild $NPWD/bboxbuild $NPWD/atfbuild $NPWD/rootfs $NPWD/images
    else
   		sudo rm -r $2
    fi
else
    echo "Usage for help"
    echo "(./build.sh atf xxx) to use arm-trusted-firmware make xxx"
    echo "(./build.sh uboot xxx) to use uboot make xxx"
    echo "(./build.sh linux xxx) to use linux make xxx"
    echo "(./build.sh busybox xxx) to use busybox make xxx"
    echo "(./build.sh rootfs) to build rootfs with busybox"
    echo "(./build.sh img x1 x2 ) to build sdimg fat: x1M rootfs: x2M"
    echo "(./build.sh cp) copy all tftp file to tftp server root"
    echo "(./build.sh cpenv) copy env file to tftp server root"
    echo "(./build.sh env) set the board env to uEnv.txt"
    echo "(./build.sh clean xxx) clean xxx dir"
fi
