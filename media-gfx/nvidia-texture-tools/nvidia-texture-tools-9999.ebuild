# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

DESCRIPTION="A set of cuda-enabled texture tools and compressors"
HOMEPAGE="http://developer.nvidia.com/object/texture_tools.html"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/castano/${PN}.git"
	KEYWORDS=""
else
	MY_PV=$(replace_version_separator 3 '-')
	MY_P="${PN}-${MY_PV}"

	SRC_URI="https://github.com/castano/${PN}/archive/v${MY_PV}.tar.gz -> ${MY_P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="MIT"
SLOT="0"
IUSE="cuda openmp"

RDEPEND="
	media-libs/libpng:0
	media-libs/ilmbase
	media-libs/tiff:0
	sys-libs/zlib
	virtual/jpeg
	virtual/opengl
	x11-libs/libX11
	cuda? ( dev-util/nvidia-cuda-toolkit )
	openmp? ( sys-devel/gcc[openmp] )
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

DOCS=( ChangeLog README.md )

src_prepare() {
	sed -i \
		-e '/NVIDIA_Texture_Tools_LICENSE.txt/d' \
		-e '/NVIDIA_Texture_Tools_README.txt/d' \
		CMakeLists.txt || die

	# TODO: remove this sed if possible
	sed -i \
		-e '/ADD_SUBDIRECTORY.*tests/d' \
		src/nvtt/CMakeLists.txt || die

	sed -r -i \
		-e 's/(LIBRARY DESTINATION )lib/\1'$(get_libdir)'/' \
		src/{nvcore,nvimage,nvmath,nvthread,nvtt}/CMakeLists.txt || die

	if ! use openmp; then
		sed -i \
			-e '/INCLUDE.*FindOpenMP/d' \
			src/CMakeLists.txt || die
	fi

	default
}

src_configure() {
	local mycmakeargs=(
		-DNV_SOURCE_DIR=${S}
		-DNVTHREAD_SHARED=TRUE
		-DNVTT_SHARED=TRUE
		-DCUDA_FOUND=$(usex cuda TRUE FALSE)
	)

	cmake-utils_src_configure
}
