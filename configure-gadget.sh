#!/bin/bash -e

SYSDIR=/sys/kernel/config/usb_gadget/
DEVDIR=$SYSDIR/$1

echo "Creating USB gadget $1"

mkdir -p $DEVDIR
 
echo $USB_IDVENDOR > $DEVDIR/idVendor
echo $USB_IDPRODUCT > $DEVDIR/idProduct
echo $USB_BCDDEVICE > $DEVDIR/bcdDevice
echo $USB_BCDUSB > $DEVDIR/bcdUSB
 
mkdir -p $DEVDIR/strings/0x409
echo "$USB_SERIALNUMBER" > $DEVDIR/strings/0x409/serialnumber
echo "$USB_MANUFACTURER"        > $DEVDIR/strings/0x409/manufacturer
echo "$USB_PRODUCT"   > $DEVDIR/strings/0x409/product
 
mkdir -p $DEVDIR/configs/c.1
echo $USB_MAXPOWER > $DEVDIR/configs/c.1/MaxPower

for func in $USB_FUNCTIONS; do
	echo "Adding function $func to USB gadget $1"
	mkdir -p $DEVDIR/functions/$func
	ln -s $DEVDIR/functions/$func $DEVDIR/configs/c.1/
done
 
udevadm settle -t 5 || :
ls /sys/class/udc/ > $DEVDIR/UDC
