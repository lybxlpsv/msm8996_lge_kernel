#!/bin/bash
#
# Stock kernel for LG Electronics msm8996 devices build script by jcadduono
# -modified by stendro
#
################### BEFORE STARTING ################
#
# download a working toolchain and extract it somewhere and configure this
# file to point to the toolchain's root directory.
#
# once you've set up the config section how you like it, you can simply run
# ./build.sh [VARIANT]
#
# optional: specify "clang" after [VARIANT] to use CLANG compiler.
##################### VARIANTS #####################
#
# H850		= International (Global)
#		LGH850   (LG G5)
#
# H830		= T-Mobile (US)
#		LGH830   (LG G5)
#
# RS988		= Unlocked (US)
#		LGRS988  (LG G5)
#
#   *************************
#
# H910		= AT&T (US)
#		LGH910   (LG V20)
#
# H915		= Canada (CA)
#		LGH915   (LG V20)
#
# H918		= T-Mobile (US)
#		LGH918   (LG V20)
#
# US996		= US Cellular & Unlocked (US)
#		LGUS996  (LG V20)
#
# US996Santa	= US Cellular & Unlocked (US)
#		LGUS996  (LG V20) (Unlocked with Engineering Bootloader)
#
# VS995		= Verizon (US)
#		LGVS995  (LG V20)
#
# H990DS/TR	= International (Global)
#		LGH990   (LG V20) (TR = Single sim)
#
# LS997		= Sprint (US)
#		LGLS997  (LG V20)
#
# F800K/L/S	= Korea (KR)
#		LGF800   (LG V20)
#
#   *************************
#
# H870		= International (Global)
#		LGH870   (LG G6)
#
# US997		= US Cellular & Unlocked (US)
#		US997    (LG G6)
#
# H872		= T-Mobile (US)
#		LGH872   (LG G6)
#
###################### CONFIG ######################

# root directory of this kernel (this script's location)
RDIR=$(pwd)

# build dir
BDIR=build

# color codes
COLOR_N="\033[0m"
COLOR_R="\033[0;31m"
COLOR_G="\033[1;32m"
COLOR_P="\033[1;35m"

# version number
VER=$(cat "$RDIR/VERSION")
LVER=$(cat "$RDIR/VERSION" | cut -f2 -d'_')

# get build date, day/month/year
BDATE=$(date '+%d/%m/%Y')

# select cpu threads
CPU_THREADS=$(grep -c "processor" /proc/cpuinfo)
THREADS=$((CPU_THREADS + 1))

# directory containing cross-compiler
[ "$2" ] && IS_CLANG=$2
if [ "$IS_CLANG" = "clang" ]; then
  CLANG_COMP=$HOME/build/toolchain/clang/bin/clang
  MK_COMMAND="-C $RDIR O=$BDIR CC=$CLANG_COMP"
  GCC_COMP=$HOME/build/toolchain/google-gcc/bin/aarch64-linux-android-
  CLANG_VER=$(${CLANG_COMP} --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | \
	sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
else
  MK_COMMAND="-C $RDIR O=$BDIR"
  GCC_COMP=$HOME/build/toolchain/bin/aarch64-linux-gnu-
  GCC_VER=$(${GCC_COMP}gcc --version | head -n 1 | cut -f1 -d')' | \
	cut -f2 -d'(')
fi

############## SCARY NO-TOUCHY STUFF ###############

ABORT() {
	echo -e $COLOR_R"Error: $*"
	exit 1
}

export ARCH=arm64
export CROSS_COMPILE=$GCC_COMP
export KBUILD_BUILD_TIMESTAMP=$BDATE
export KBUILD_BUILD_USER=stendro
export KBUILD_BUILD_HOST=github
export LOCALVERSION="MK2000-${LVER}"
if [ "$IS_CLANG" = "clang" ]; then
  export CLANG_TRIPLE=aarch64-linux-gnu-
  export KBUILD_COMPILER_STRING=$CLANG_VER
else
  export KBUILD_COMPILER_STRING=$GCC_VER
fi

# selected device
[ "$1" ] && DEVICE=$1
[ "$DEVICE" ] || ABORT "No device specified!"

# link device name to lg config files
if [ "$DEVICE" = "H850" ]; then
  DEVICE_DEFCONFIG=lineageos_h850_defconfig
elif [ "$DEVICE" = "H830" ]; then
  DEVICE_DEFCONFIG=lineageos_h830_defconfig
elif [ "$DEVICE" = "RS988" ]; then
  DEVICE_DEFCONFIG=lineageos_rs988_defconfig
elif [ "$DEVICE" = "H870" ]; then
  DEVICE_DEFCONFIG=lineageos_h870_defconfig
elif [ "$DEVICE" = "US997" ]; then
  DEVICE_DEFCONFIG=lineageos_us997_defconfig
elif [ "$DEVICE" = "H872" ]; then
  DEVICE_DEFCONFIG=lineageos_h872_defconfig
elif [ "$DEVICE" = "H990" ]; then
  DEVICE_DEFCONFIG=lineageos_h990_defconfig
elif [ "$DEVICE" = "US996" ]; then
  DEVICE_DEFCONFIG=lineageos_us996_defconfig
elif [ "$DEVICE" = "US996Santa" ]; then
  DEVICE_DEFCONFIG=not available
elif [ "$DEVICE" = "LS997" ]; then
  DEVICE_DEFCONFIG=lineageos_ls997_defconfig
elif [ "$DEVICE" = "VS995" ]; then
  DEVICE_DEFCONFIG=lineageos_vs995_defconfig
elif [ "$DEVICE" = "H918" ]; then
  DEVICE_DEFCONFIG=lineageos_h918_defconfig
elif [ "$DEVICE" = "H910" ]; then
  DEVICE_DEFCONFIG=lineageos_h910_defconfig
elif [ "$DEVICE" = "H915" ]; then
  DEVICE_DEFCONFIG=lineageos_h915_defconfig
elif [ "$DEVICE" = "F800K" ]; then
  DEVICE_DEFCONFIG=not available
elif [ "$DEVICE" = "F800L" ]; then
  DEVICE_DEFCONFIG=not available
elif [ "$DEVICE" = "F800S" ]; then
  DEVICE_DEFCONFIG=not available
else
  ABORT "Invalid device specified! Make sure to use upper case."
fi

# check for stuff
[ -f "$RDIR/arch/$ARCH/configs/${DEVICE_DEFCONFIG}" ] \
	|| ABORT "$DEVICE_DEFCONFIG not found in $ARCH configs!"

if [ "$IS_CLANG" = "clang" ]; then
  [ -x "${CLANG_COMP}" ] \
	|| ABORT "Cross-compiler not found at: ${CLANG_COMP}"
  [ "$CLANG_VER" ] || ABORT "Couldn't get CLANG version."
else
  [ "$GCC_VER" ] || ABORT "Couldn't get GCC version."
fi

[ -x "${CROSS_COMPILE}gcc" ] \
	|| ABORT "Cross-compiler not found at: ${CROSS_COMPILE}gcc"


# build commands
CLEAN_BUILD() {
	echo -e $COLOR_G"Cleaning build folder..."$COLOR_N
	rm -rf $BDIR
}

SETUP_BUILD() {
	echo -e $COLOR_G"Creating kernel config..."$COLOR_N
	mkdir -p $BDIR
	make ${MK_COMMAND} "$DEVICE_DEFCONFIG" \
		|| ABORT "Failed to set up build."
}

BUILD_KERNEL() {
	echo -e $COLOR_G"Compiling kernel..."$COLOR_N
	TIMESTAMP1=$(date +%s)
	while ! make ${MK_COMMAND} -j"$THREADS"; do
		read -rp "Build failed. Retry? " do_retry
		case $do_retry in
			Y|y) continue ;;
			*) return 1 ;;
		esac
	done
	TIMESTAMP2=$(date +%s)
	BSEC=$((TIMESTAMP2-TIMESTAMP1))
	BTIME=$(printf '%02dm:%02ds' $(($BSEC/60)) $(($BSEC%60)))
}

INSTALL_MODULES() {
	grep -q 'CONFIG_MODULES=y' $BDIR/.config || return 0
	echo -e $COLOR_G"Installing kernel modules..."$COLOR_N
	make ${MK_COMMAND} \
		INSTALL_MOD_PATH="." \
		INSTALL_MOD_STRIP=1 \
		modules_install
	rm $BDIR/lib/modules/*/build $BDIR/lib/modules/*/source
}

PREPARE_NEXT() {
	echo "$DEVICE" > $BDIR/DEVICE \
		|| echo "Failed to reflect device."
	if grep -q 'KERNEL_COMPRESSION_LZ4=y' $BDIR/.config; then
	  echo lz4 > $BDIR/COMPRESSION \
		|| echo "Failed to reflect compression method."
	else
	  echo gz > $BDIR/COMPRESSION \
		|| echo "Failed to reflect compression method."
	fi
}

cd "$RDIR" || ABORT "Failed to enter $RDIR!"
echo -e $COLOR_G"Building ${DEVICE} ${VER}..."
if [ "$IS_CLANG" = "clang" ]; then
  echo -e $COLOR_P"Using $CLANG_VER..."
else
  echo -e $COLOR_P"Using $GCC_VER..."
fi

CLEAN_BUILD &&
SETUP_BUILD &&
BUILD_KERNEL &&
INSTALL_MODULES &&
PREPARE_NEXT &&
echo -e $COLOR_G"Finished building ${DEVICE} ${VER} -- Kernel compilation took"$COLOR_R $BTIME
echo -e $COLOR_P"Run ./copy_finished.sh to create AnyKernel zip."
