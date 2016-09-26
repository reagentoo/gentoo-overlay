# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit cmake-utils

DESCRIPTION="Base applications for the Hawaii desktop environment"
HOMEPAGE="https://github.com/hawaii-desktop/${PN}"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/hawaii-desktop/${PN}.git"
	KEYWORDS=""
else
	MY_PV=$(replace_version_separator 3 '-')
	MY_P=${PN}-${MY_PV}

	SRC_URI="https://github.com/hawaii-desktop/${PN}/releases/download/v${MY_PV}/${MY_P}.tar.xz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-2.0"
SLOT="0"
IUSE="debug systemd"

RDEPEND="
	dev-libs/greenisland
	dev-libs/fluid
	>=dev-qt/qtcore-5.7.0:5
	>=dev-qt/qtdbus-5.7.0:5
	>=dev-qt/qtdeclarative-5.7.0:5
	>=dev-qt/qtgui-5.7.0:5
	hawaii-base/libhawaii
	media-libs/qt-gstreamer[qt5]
	sys-auth/polkit-qt[qt5]
	systemd? ( sys-apps/systemd )
"
DEPEND="${RDEPEND}"

CMAKE_MIN_VERSION="2.8.12"
DOCS=( AUTHORS.md README.md )

src_configure() {
	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE=$(usex debug Debug Release)
		-DCMAKE_INSTALL_PREFIX=/usr
		-DENABLE_SYSTEMD=$(usex systemd)
	)

	cmake-utils_src_configure
}
