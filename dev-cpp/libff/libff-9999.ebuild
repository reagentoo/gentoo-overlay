# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils git-r3

DESCRIPTION="C++ library for Finite Fields and Elliptic Curves"
HOMEPAGE="https://github.com/scipr-lab/libff"
EGIT_REPO_URI="https://github.com/scipr-lab/${PN}.git"
EGIT_SUBMODULES=(
	depends/ate-pairing
	depends/xbyak
)

if [[ ${PV} == 9999 ]]; then
	KEYWORDS=""
else
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="MIT"
SLOT="0"
IUSE="+asm debug memlimit openmp +procps test"

RDEPEND="
	dev-libs/boost
	dev-libs/gmp
	procps? ( sys-process/procps )
"
DEPEND="${RDEPEND}
	dev-libs/openssl
	virtual/pkgconfig
"

CMAKE_MIN_VERSION="2.8"

src_unpack() {
	if [[ ${PV} != 9999 ]]; then
		EGIT_COMMIT_DATE="$(date -ud ${PV##*_p} +%s)"
	fi

	git-r3_src_unpack
}

src_prepare() {
	sed -r -i \
		-e 's/\$\{CMAKE_CXX_FLAGS\}/\0 -fPIC/' \
		-e 's/if.+IS_LIBFF_PARENT.+/if \(FALSE\)/' \
		CMakeLists.txt || die

	sed -r -i \
		-e '/[[:space:]]+zm/d' \
		-e 's/STATIC/SHARED/' \
		-e 's/(TARGETS.+ff.+DESTINATION.+)lib/\1\$\{CMAKE_INSTALL_LIBDIR\}/' \
		libff/CMakeLists.txt || die

	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCPPDEBUG=OFF
		-DDEBUG=$(usex debug)
		-DIS_LIBFF_PARENT=$(usex test)
		-DLOWMEM=$(usex memlimit)
		-DMULTICORE=$(usex openmp)
		-DPERFORMANCE=OFF
		-DUSE_ASM=$(usex asm)
		-DWITH_PROCPS=$(usex procps)
	)

	cmake-utils_src_configure
}
