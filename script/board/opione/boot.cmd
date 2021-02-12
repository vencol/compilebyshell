setenv fdt_high ffffffff
usb start
setenv ethact usb_ether
setenv ipaddr 192.168.137.2
setenv gatewayip 192.168.137.1
setenv netmask 255.255.255.0
setenv serverip 192.168.1.111
setenv bootargs console=ttyS0,115200 earlyprintk root=/dev/mmcblk0p2 rootwait rw
#setenv bootargs root=/dev/nfs rw rootpath=/home/vencol/code/nfs nfsroot=192.168.1.111:/home/vencol/code/nfs,nolock ip=192.168.137.2:192.168.1.111:192.168.137.1:255.255.255.0 console=ttyS0,115200 nfsvers=2

tftp $kernel_addr_r zImage
tftp $fdt_addr_r sun8i-h3-orangepi-one.dtb
bootz $kernel_addr_r - $fdt_addr_r

#fatload mmc 0 $kernel_addr_r zImage
#fatload mmc 0 $fdt_addr_r sun8i-h3-orangepi-one.dtb
#bootz $kernel_addr_r - $fdt_addr_r
