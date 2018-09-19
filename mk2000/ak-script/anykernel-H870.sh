# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=H870 mk2000 Lineage
do.devicecheck=1
do.postboot=0
do.modules=1
do.cleanup=1
do.cleanuponabort=0
device.name1=h870
device.name2=lucye
device.name3=H870
device.name4=LUCYE
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh;

## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
chmod -R 750 $ramdisk/*;
chmod -R 755 $ramdisk/sbin;
chown -R root:root $ramdisk/*;

## AnyKernel install
dump_boot;

## Ramdisk modifications - disabled
# append_file init.rc blu_active "init_rc-mod";

write_boot;
## end install
