# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils unpacker

DESCRIPTION="NVTriStrip is a library for vertex cache aware stripification of geometry"
HOMEPAGE="http://www.nvidia.com/object/nvtristrip_library.html"
SRC_URI="http://www.nvidia.com/attach/8082 -> ${P}.tar.gz"
KEYWORDS="~amd64 ~x86"

LICENSE=""
SLOT="0"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	app-arch/unzip
"

src_unpack() {
	mkdir ${P} || die
	cd ${P} || die
	unpack_zip ${A}
}

src_prepare() {
	edos2unix include/*.h src/NvTriStrip/*.cpp src/NvTriStrip/*.h
	EPATCH_OPTS="-l" epatch "${FILESDIR}/${P}-unix.patch"
	cp "${FILESDIR}/${PN}.cmake" "${S}/CMakeLists.txt" || die
	default
}

src_configure() {
	local mycmakeargs=(
		-DINC="${S}/include"
		-DSRC="${S}/src/NvTriStrip"
		-DLIB="$(get_libdir)"
	)

	cmake-utils_src_configure
}
