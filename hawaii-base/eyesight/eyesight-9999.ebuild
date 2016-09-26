# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
PLOCALES="ar de el es es_AR fr it ja_JP nl pt zh_CN"

inherit cmake-utils l10n

DESCRIPTION="Image viewer for the Hawaii desktop environment"
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
IUSE="debug"

RDEPEND="
	dev-qt/linguist-tools:5
	dev-qt/qtdeclarative:5
	dev-qt/qtgui:5
	dev-qt/qtprintsupport:5
"
DEPEND="${RDEPEND}"

CMAKE_MIN_VERSION="2.8.9"
DOCS=( README.md )

src_configure() {
	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE=$(usex debug Debug Release)
		-DCMAKE_INSTALL_PREFIX=/usr
		-DLANGUAGES="$(l10n_get_locales)"
	)

	cmake-utils_src_configure
}
