**本项目通过脚本实现，uboot，kernel，busybox，rootfs，sdimg基础linux系统的构建，通过脚本可以了解系统构建的整个过程**
# 1.编译目录结构如下
```
code/
├── board   #board目录下定义不同类型的板子
│   ├── build.sh -> script/build.sh
│   ├── README.md
│   │── script
│   │   ├── board               #当前项目的编译脚本位置
│   │   ├── build.sh            #主编译脚本，软连接到opione板子目录层
│   │   ├── fsscr.sh            #制作rootfs的脚本
│   │   ├── imgscr.sh           #制作sd卡的脚本
│   │   ├── imgscr.sh-old
│   │   └── uEnv.txt            #uboot需要的uEnv文件
│   └── boardbuild              #不同板子的编译输出目录
│       ├── bbb
│       ├── opiwin
│       └── opione
│           ├── bboxbuild       #busybox源码编译输出的位置
│           ├── bootbuild       #uboot源码编译输出的位置
│           ├── build.sh -> script/build.sh
│           ├── images          #生成sd卡镜像的位置
│           ├── linuxbuild      #kernel源码编译输出的位置
│           ├── rootfs          #软连接的实际位置，根文件系统
│           └── README.md       #介绍文件
├── gcc     #gcc目录下定义不同的工具链
│   ├── gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabi
│   ├── gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf
│   ├── gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf.tar.xz
│   ├── gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabi.tar.xz
│   ├── sysroot-glibc-linaro-2.25-2019.12-rc1-arm-linux-gnueabihf
│   ├── sysroot-glibc-linaro-2.25-2019.12-rc1-arm-linux-gnueabihf.tar.xz
├── nfs -> board/opione/rootfs/     #调试时板子需要挂载的nfs根文件系统，可以软连接到不同板子的rootfs
└── src             #所有编译源码的目录
    ├── app         #编译应用和驱动模块的源码位置
    ├── busybox     #busybox源码的位置
    ├── linux       #kernel源码的位置
    ├── other       #其他源码的位置
    └── uboot       #uboot源码的位置

```
# 2.相关源码下载
|名称|源码|说明|
|:-:|:-:|:-:|
|交叉编译gcc|`wget https://releases.linaro.org/components/toolchain/binaries/7.5-2019.12/arm-linux-gnueabihf/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf.tar.xz`|使用linaro的gcc，网址下载的是arm gcc |
|uboot|`git clone https://gitee.com/mirrors/u-boot.git`|用主线uboot的gitee镜像|
|kernel|`git clone https://mirrors.tuna.tsinghua.edu.cn/git/linux-stable.git`|使用稳定版主线内核的清华源镜像|
|busybox|`git clone https://gitee.com/mirrors/busyboxsource.git`|使用主线busybox的gitee镜像|

# 3.编译命令
## 1.编译命令需要在板子目录下执行，比如orangepione，可以在opione目录下执行，如下所示
```
.
├── bboxbuild
├── bootbuild
├── build.sh -> script/build.sh
├── images
├── linuxbuild
├── README.md
├── rootfs
└── script
```
## 4.输入命令`./build.sh help`,输出如下帮助，可以根据自己需要执行相关编译
```
Usage for help
(./build.sh atf xxx) to use arm-trusted-firmware make xxx
(./build.sh uboot xxx) to use uboot make xxx
(./build.sh linux xxx) to use linux make xxx
(./build.sh busybox xxx) to use busybox make xxx
(./build.sh rootfs) to build rootfs with busybox
(./build.sh img x1 x2 ) to build sdimg fat: x1M rootfs: x2M
(./build.sh cp) copy all tftp file to tftp server root
(./build.sh env) set the board env to uEnv.txt
(./build.sh clean xxx) clean xxx dir
(./build.sh app x1) build the x1 app
(./build.sh module x1) build the x1 module
```
