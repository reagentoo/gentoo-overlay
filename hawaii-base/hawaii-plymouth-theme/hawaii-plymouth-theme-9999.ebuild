# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

DESCRIPTION="This repository contains the Hawaii theme for Plymouth"
HOMEPAGE="https://github.com/hawaii-desktop/${PN}"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/hawaii-desktop/${PN}.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/hawaii-desktop/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-2.0"
SLOT="0"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"

CMAKE_MIN_VERSION="2.8.12"
DOCS=( README.md )

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX=/usr
	)

	cmake-utils_src_configure
}
