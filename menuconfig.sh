#!/bin/bash
# simple script for executing menuconfig
# -modified by stendro (source: jcadduono)
#
# root directory of LGE msm8996 git repo (default is this script's location)
RDIR=$(pwd)
OUTDIR=$(dirname "$RDIR")
OUTFILE=defconfig_regen

# directory containing cross-compile arm64 toolchain
TOOLCHAIN=$HOME/build/toolchain/bin/aarch64-linux-gnu-

export ARCH=arm64
export CROSS_COMPILE=$TOOLCHAIN

ABORT() {
	[ "$1" ] && echo "Error: $*"
	exit 1
}

[ -x "${CROSS_COMPILE}gcc" ] ||
ABORT "Unable to find gcc cross-compiler at location: ${CROSS_COMPILE}gcc"

[ "$1" ] && DEVICE=$1
[ "$DEVICE" ] || ABORT "No device specified"

# link device name to lg config files
if [ "$DEVICE" = "H850" ]; then
  DEVICE_DEFCONFIG=lineageos_h850_defconfig
fi
if [ "$DEVICE" = "H830" ]; then
  DEVICE_DEFCONFIG=lineageos_h830_defconfig
fi
if [ "$DEVICE" = "RS988" ]; then
  DEVICE_DEFCONFIG=lineageos_rs988_defconfig
fi
if [ "$DEVICE" = "H870" ]; then
  DEVICE_DEFCONFIG=lineageos_h870_defconfig
fi
if [ "$DEVICE" = "US997" ]; then
  DEVICE_DEFCONFIG=lineageos_us997_defconfig
fi
if [ "$DEVICE" = "H872" ]; then
  DEVICE_DEFCONFIG=lineageos_h872_defconfig
fi
if [ "$DEVICE" = "H990" ]; then
  DEVICE_DEFCONFIG=lineageos_h990_defconfig
fi
if [ "$DEVICE" = "US996" ]; then
  DEVICE_DEFCONFIG=lineageos_us996_defconfig
fi
if [ "$DEVICE" = "US996Santa" ]; then
  DEVICE_DEFCONFIG=elsa_usc_us-perf_defconfig
fi
if [ "$DEVICE" = "LS997" ]; then
  DEVICE_DEFCONFIG=lineageos_ls997_defconfig
fi
if [ "$DEVICE" = "VS995" ]; then
  DEVICE_DEFCONFIG=lineageos_vs995_defconfig
fi
if [ "$DEVICE" = "H918" ]; then
  DEVICE_DEFCONFIG=lineageos_h918_defconfig
fi
if [ "$DEVICE" = "H910" ]; then
  DEVICE_DEFCONFIG=lineageos_h910_defconfig
fi
if [ "$DEVICE" = "H915" ]; then
  DEVICE_DEFCONFIG=lineageos_h915_defconfig
fi
if [ "$DEVICE" = "F800K" ]; then
  DEVICE_DEFCONFIG=elsa_kt_kr-perf_defconfig
fi
if [ "$DEVICE" = "F800L" ]; then
  DEVICE_DEFCONFIG=elsa_lgu_kr-perf_defconfig
fi

[ -f "$RDIR/arch/$ARCH/configs/${DEVICE_DEFCONFIG}" ] ||
ABORT "$DEVICE_DEFCONFIG not found in $ARCH configs!"

cd "$RDIR" || ABORT "Failed to enter $RDIR!"

echo "Cleaning build..."
rm -rf build
mkdir build
make -s -i -C "$RDIR" O=build "$DEVICE_DEFCONFIG" menuconfig
echo "Showing differences between old config and new config"
echo "-----------------------------------------------------"
make -s -i -C "$RDIR" O=build "$DEVICE_DEFCONFIG"
if command -v colordiff >/dev/null 2>&1; then
	diff -Bwu --label "old config" build/.config --label "new config" build/.config.old | colordiff
else
	diff -Bwu --label "old config" build/.config --label "new config" build/.config.old
	echo "-----------------------------------------------------"
	echo "Consider installing the colordiff package to make diffs easier to read"
fi
echo "-----------------------------------------------------"
echo -n "Are you satisfied with these changes? Y/N: "
read option
case $option in
y|Y)
	cp build/.config.old "../$OUTFILE"
	echo "Copied new config to $OUTDIR/$OUTFILE"
	;;
*)
	echo "That's unfortunate"
	;;
esac
echo "Done."
