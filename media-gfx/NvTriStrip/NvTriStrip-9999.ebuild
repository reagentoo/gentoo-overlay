# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

DESCRIPTION="NVTriStrip is a library for vertex cache aware stripification of geometry"
HOMEPAGE="http://www.nvidia.com/object/nvtristrip_library.html"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/turbulenz/${PN}.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/turbulenz/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE=""
SLOT="0"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"

src_prepare() {
	cp "${FILESDIR}/${PN}.cmake" "${S}/CMakeLists.txt" || die
	default
}

src_configure() {
	local mycmakeargs=(
		-DINC="${S}/NvTriStrip/include"
		-DSRC="${S}/NvTriStrip/src"
		-DLIB="$(get_libdir)"
	)

	cmake-utils_src_configure
}
