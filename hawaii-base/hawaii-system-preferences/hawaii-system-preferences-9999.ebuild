# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PLOCALES="ar ast bg cs_CZ de el es fa_IR fr hu id it ja_JP kk nl no pl pt pt pt_BR ru si_LK sk tr vi zh_CN"

inherit cmake-utils l10n

DESCRIPTION="System preferences for the Hawaii desktop environment"
HOMEPAGE="https://github.com/hawaii-desktop/${PN}"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/hawaii-desktop/${PN}.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/hawaii-desktop/${PN}/releases/download/v${PV}/${P}.tar.xz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-2.0"
SLOT="0"
IUSE="debug"

RDEPEND="
	dev-libs/greenisland
	>=dev-qt/linguist-tools-5.7.0:5
	>=dev-qt/qtcore-5.7.0:5
	>=dev-qt/qtdeclarative-5.7.0:5
	>=dev-qt/qtgui-5.7.0:5
	>=dev-qt/qtwidgets-5.7.0:5
	hawaii-base/libhawaii
	sys-auth/polkit-qt[qt5]
	x11-misc/xkeyboard-config
"
DEPEND="${RDEPEND}"

CMAKE_MIN_VERSION="2.8.12"
DOCS=( AUTHORS README.md )

src_configure() {
	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE=$(usex debug Debug Release)
		-DCMAKE_INSTALL_PREFIX=/usr
		-DLANGUAGES="$(l10n_get_locales)"
	)

	cmake-utils_src_configure
}
