# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

DESCRIPTION="A cross-platform library for USB video devices, built atop libusb"
HOMEPAGE="https://int80k.com/libuvc/"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/ktossell/${PN}.git"
	KEYWORDS=""
else
	MY_PV=$(replace_version_separator 3 '-')
	MY_P=${PN}-${MY_PV}

	SRC_URI="https://github.com/ktossell/${PN}/archive/v${MY_PV}.tar.gz -> ${MY_P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="AGPL"
SLOT="0"
IUSE="static-libs"

CMAKE_MIN_VERSION="2.8.0"

RDEPEND="
	dev-libs/libusb
	virtual/jpeg
	virtual/udev
"
DEPEND="${RDEPEND}"

DOCS=( changelog.txt README.md )

src_prepare() {
	sed -r -i \
		-e 's/(CONF_LIBRARY "\$\{CMAKE_INSTALL_PREFIX\}\/)lib/\1'$(get_libdir)'/' \
		-e 's/(INSTALL_CMAKE_DIR "\$\{CMAKE_INSTALL_PREFIX\}\/)lib/\1'$(get_libdir)'/' \
		CMakeLists.txt || die

	sed -r -i \
		-e 's/(ARCHIVE DESTINATION "\$\{CMAKE_INSTALL_PREFIX\}\/)lib/\1'$(get_libdir)'/' \
		-e 's/(LIBRARY DESTINATION "\$\{CMAKE_INSTALL_PREFIX\}\/)lib/\1'$(get_libdir)'/' \
		CMakeLists.txt || die

	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_BUILD_TARGET=$(usex static-libs Static Shared)
	)

	cmake-utils_src_configure
}
