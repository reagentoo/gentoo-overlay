# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

inherit cmake-utils

MY_PV=$(replace_version_separator 2 '-')
MY_P="${PN}-${MY_PV}"

DESCRIPTION="Asynchronous HTTP server framework written in C"
HOMEPAGE="https://github.com/${PN}/${PN}"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/${PN}/${PN}.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/${PN}/${PN}/archive/${MY_PV}.tar.gz -> ${MY_P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="Apache-2.0"
SLOT="0"
IUSE="examples static-libs"

# TODO: drop this line if private
# uv-common.h will comes to public include
REQUIRED_USE="!examples"

RDEPEND="
	dev-libs/libuv
"
DEPEND="${RDEPEND}"

src_prepare() {
	sed -r -i \
		-e '/GET_PROPERTY.*haywire_location/d' \
		-e 's/\$\{CMAKE_SOURCE_DIR\}.*libuv\.a/uv/' \
		CMakeLists.txt || die

	if ! use examples; then
		sed -i \
			-e '/.*Hello world sample.*/,$d' \
			CMakeLists.txt || die
	else
		sed -r -i \
			-e 's/\$\{haywire_location\}/haywire/' \
			CMakeLists.txt || die
	fi

	if ! use static-libs; then
		sed -r -i \
			-e 's/(add_library\(haywire) STATIC/\1 SHARED/' \
			CMakeLists.txt || die
	fi

	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DUNIX=TRUE
		-DCMAKE_SKIP_BUILD_RPATH=TRUE
		-DBUILD_SHARED_LIBS=$(usex static-libs OFF ON)
	)

	cmake-utils_src_configure
}

src_install() {
	dolib "${BUILD_DIR}/lib${PN}$(usex static-libs .a .so)"
	insinto "/usr/include/${PN}"
	doins include/*
	dodoc README.md docs/{benchmarking,buffers}.md
}
