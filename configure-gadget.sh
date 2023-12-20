#!/bin/bash -e

SYSDIR=/sys/kernel/config/usb_gadget/
DEVDIR=$SYSDIR/$1

# These are the default values that will be used if you have not provided
# an explicit value in the environment.
: ${USB_IDVENDOR:=0x1d6b}
: ${USB_IDPRODUCT:=0x0104}
: ${USB_BCDDEVICE:=0x0100}
: ${USB_BCDUSB:=0x0200}
: ${USB_SERIALNUMBER:=deadbeef0000}
: ${USB_PRODUCT:="Pi Zero Gadget"}
: ${USB_MANUFACTURER:="Linux"}
: ${USB_MAXPOWER:=250}
: ${USB_CONFIG:=conf.1}

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
 
mkdir -p $DEVDIR/configs/$USB_CONFIG
echo $USB_MAXPOWER > $DEVDIR/configs/$USB_CONFIG/MaxPower

for func in $USB_FUNCTIONS; do
	echo "Adding function $func to USB gadget $1"
	FUNC_DIR=$DEVDIR/functions/$func
	mkdir -p $FUNC_DIR
	ln -s $FUNC_DIR $DEVDIR/configs/$USB_CONFIG

	func_params_var=$(echo $func | tr '.' '_')
	if ! declare -p $func_params_var 2> /dev/null; then
		echo "No parameters defined for $func"
		continue
	fi

	declare -n func_params=$func_params_var

	for param in "${func_params[@]}"; do
		key=${param%%=*}
		value=${param##*=}
		echo $value > $FUNC_DIR/$key
	done
done
 
udevadm settle -t 5 || :
ls /sys/class/udc/ > $DEVDIR/UDC
