# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools versionator

DESCRIPTION="Small C library for x86 CPU detection and feature extraction"
HOMEPAGE="http://libcpuid.sourceforge.net/"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/anrieff/${PN}.git"
	KEYWORDS=""
else
	MY_PV=$(replace_version_separator 3 '-')
	MY_P=${PN}-${MY_PV}

	SRC_URI="https://github.com/anrieff/${PN}/archive/v${MY_PV}.tar.gz -> ${MY_P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="BSD-2"
SLOT="0"
IUSE=""

RESTRICT="mirror"

src_prepare() {
	eautoreconf
	default
}
