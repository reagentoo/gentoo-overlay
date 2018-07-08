# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

DESCRIPTION="These are the libraries used by Hawaii Shell and other projects related to the Hawaii desktop environment"
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
	>=dev-libs/glib-2.31.0
	>=dev-qt/qtcore-5.4.0:5
	>=dev-qt/qtdeclarative-5.4.0:5
	>=dev-qt/qtgui-5.4.0:5
"
DEPEND="${RDEPEND}"

CMAKE_MIN_VERSION="2.8.12"
DOCS=( AUTHORS.md README.md )

src_configure() {
	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE=$(usex debug Debug Release)
		-DCMAKE_INSTALL_PREFIX=/usr
	)

	cmake-utils_src_configure
}
