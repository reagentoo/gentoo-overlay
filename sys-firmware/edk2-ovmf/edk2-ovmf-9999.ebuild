# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
PYTHON_COMPAT=( python2_7 )

inherit eutils multiprocessing toolchain-funcs python-any-r1

DESCRIPTION="EDK II Open Source UEFI Firmware"
HOMEPAGE="http://tianocore.sourceforge.net"

LICENSE="BSD-2"
SLOT="0"
IUSE="debug +qemu +secure-boot"

if [[ ${PV} == 99999 ]]; then
	inherit subversion
	ESVN_REPO_URI="https://svn.code.sf.net/p/edk2/code/trunk/edk2"
	KEYWORDS="-*"
elif [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/tianocore/edk2.git"
	KEYWORDS="-*"
else
	MY_P="edk2-${PV}"
	S="${WORKDIR}/${MY_P}"
	SRC_URI="http://storage.core-os.net/mirror/snapshots/${MY_P}.tar.xz"
	KEYWORDS="-* amd64"
fi

OPENSSL_PV="1.1.0e"
OPENSSL_P="openssl-${OPENSSL_PV}"
SRC_URI+=" mirror://openssl/source/${OPENSSL_P}.tar.gz"

DEPEND=">=dev-lang/nasm-2.0.7
	sys-power/iasl"
RDEPEND="qemu? ( app-emulation/qemu )"

src_unpack() {
	if [[ ${PV} == 99999 ]]; then
		subversion_src_unpack
	elif [[ ${PV} == 9999 ]]; then
		git-r3_src_unpack
	fi

	if use secure-boot; then
		unpack ${A}
		local openssllib="${S}/CryptoPkg/Library/OpensslLib"
		mv "${WORKDIR}/${OPENSSL_P}" "${openssllib}/openssl" || die
	fi

	cd ${S}
}

src_prepare() {
	sed -r -i \
		-e 's/^BUILD_CFLAGS[[:space:]]*=(.*[a-zA-Z0-9])?/\0 -fPIC/' \
			BaseTools/Source/C/Makefiles/header.makefile || die
	sed -i '/^build -p/i echo $TARGET_TOOLS > target_tools_var' \
		"${S}/OvmfPkg/build.sh" || die

	# This build system is impressively complicated, needless to say
	# it does things that get confused by PIE being enabled by default.
	# Add -nopie to a few strategic places... :)
	if gcc-specs-pie; then
		sed -r -i \
			-e 's/^DEFINE GCC_ALL_CC_FLAGS[[:space:]]*=(.*[a-zA-Z0-9])?/\0 -nopie/' \
			-e 's/^DEFINE GCC44_ALL_CC_FLAGS[[:space:]]*=(.*[a-zA-Z0-9])?/\0 -nopie/' \
				BaseTools/Conf/tools_def.template || die
		sed -r -i \
			-e 's/^BUILD_CFLAGS[[:space:]]*=(.*[a-zA-Z0-9])?/\0 -nopie/' \
			-e 's/^BUILD_LFLAGS[[:space:]]*=(.*[a-zA-Z0-9])?/\0 -nopie/' \
				BaseTools/Source/C/Makefiles/header.makefile || die
	fi

	default
}

src_configure() {
	# edksetup.sh must always be run as a sourced script
	. edksetup.sh || die

	TARGET_NAME=$(usex debug DEBUG RELEASE)
	case $ARCH in
		amd64)	TARGET_ARCH=X64 ;;
		#x86)	TARGET_ARCH=IA32 ;;
		*)		die "Unsupported $ARCH" ;;
	esac
}

src_compile() {
	emake ARCH=${TARGET_ARCH} -C BaseTools -j1

	./OvmfPkg/build.sh \
		-a "${TARGET_ARCH}" \
		-b "${TARGET_NAME}" \
		-n $(makeopts_jobs) \
		-D SECURE_BOOT_ENABLE=$(usex secure-boot TRUE FALSE) \
		-D FD_SIZE_2MB \
		|| die "OvmfPkg/build.sh failed"
}

src_install() {
	local fv="Build/OvmfX64/${TARGET_NAME}_$(cat ${S}/target_tools_var)/FV"
	insinto /usr/share/${PN}
	doins "${fv}"/OVMF{,_CODE,_VARS}.fd
	dosym OVMF.fd /usr/share/${PN}/bios.bin

	if use qemu; then
		dosym ../${PN}/OVMF.fd /usr/share/qemu/efi-bios.bin
	fi
}
