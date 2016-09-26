# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit cmake-utils

DESCRIPTION="Full blown Wayland compositor for QtQuick as well as pluggable hardware abstraction, extensions, tools and a Qt-style API for Wayland clients"
HOMEPAGE="https://github.com/greenisland/${PN}"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/greenisland/${PN}.git"
	KEYWORDS=""
else
	MY_PV=$(replace_version_separator 3 '-')
	MY_P=${PN}-${MY_PV}

	SRC_URI="https://github.com/greenisland/${PN}/releases/download/v${MY_PV}/${MY_P}.tar.xz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-2.0"
SLOT="0"
IUSE="debug drm gles2 mali rpi systemd viv xwayland X"

# TODO: add missing dependencies
REQUIRED_USE="!mali !viv"

RDEPEND="
	dev-libs/libinput
	>=dev-libs/wayland-1.6.0:=
	>=dev-qt/qtcore-5.6.0:5
	>=dev-qt/qtdbus-5.6.0:5
	>=dev-qt/qtdeclarative-5.6.0:5[gles2=]
	>=dev-qt/qtgui-5.6.0:5[gles2=]
	virtual/libudev
	drm? (
		media-libs/mesa[egl,gbm]
		x11-libs/libdrm
	)
	rpi? ( sys-boot/raspberrypi-firmware )
	systemd? ( sys-apps/systemd )
	xwayland? ( x11-libs/xcb-util-cursor )
"
DEPEND="${RDEPEND}"

CMAKE_MIN_VERSION="2.8.12"
DOCS=( AUTHORS.md README.md )

src_prepare() {
	if ! use systemd; then
		sed -i -e '/pkg_check_modules.*systemd/d' \
			CMakeLists.txt || die
	fi

	if ! use X; then
		sed -i -e '/find_package.*X11/d' \
			CMakeLists.txt || die
	fi

	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE=$(usex debug Debug Release)
		-DCMAKE_INSTALL_PREFIX=/usr
		-DENABLE_EGLDEVICEINTEGRATION_BRCM=$(usex rpi)
		-DENABLE_EGLDEVICEINTEGRATION_KMS=$(usex drm)
		-DENABLE_EGLDEVICEINTEGRATION_MALI=$(usex mali)
		-DENABLE_EGLDEVICEINTEGRATION_VIV=$(usex viv)
		-DENABLE_EGLDEVICEINTEGRATION_X11=$(usex X)
		-DENABLE_ONLY_EGLDEVICEINTEGRATION=OFF
		-DENABLE_XWAYLAND=$(usex xwayland)
		-DUSE_LOCAL_WAYLAND_PROTOCOLS=OFF
	)

	cmake-utils_src_configure
}
