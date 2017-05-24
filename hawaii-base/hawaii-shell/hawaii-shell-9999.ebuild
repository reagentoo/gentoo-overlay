# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

DESCRIPTION="Hawaii desktop environment shell"
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
IUSE="alsa debug modemmanager networkmanager pulseaudio systemd"

RDEPEND="
	dev-libs/greenisland
	dev-libs/libqtxdg
	>=dev-qt/qtcore-5.7.0:5
	>=dev-qt/qtdbus-5.7.0:5
	>=dev-qt/qtdeclarative-5.7.0:5
	>=dev-qt/qtgui-5.7.0:5
	>=dev-qt/qtwayland-5.7.0:5
	>=dev-qt/qtwidgets-5.7.0:5
	>=dev-qt/qtxml-5.7.0:5
	hawaii-base/hawaii-workspace
	kde-frameworks/solid
	virtual/pam
	alsa? ( media-libs/alsa-lib )
	modemmanager? ( kde-frameworks/modemmanager-qt )
	networkmanager? ( kde-frameworks/networkmanager-qt )
	pulseaudio? ( media-sound/pulseaudio )
	systemd? ( sys-apps/systemd )
"
DEPEND="${RDEPEND}"

CMAKE_MIN_VERSION="2.8.12"
DOCS=( AUTHORS.md README.md )

src_configure() {
	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE=$(usex debug Debug Release)
		-DCMAKE_INSTALL_PREFIX=/usr
		-DDEVELOPMENT_BUILD=OFF
		-DENABLE_MODEMMANAGER_SUPPORT=$(usex modemmanager)
		-DENABLE_NETWORK_MANAGER=$(usex networkmanager)
	)

	for x in {alsa,pulseaudio,systemd}; do
		mycmakeargs+=( -DENABLE_${x^^}=$(usex $x) )
	done

	cmake-utils_src_configure
}
