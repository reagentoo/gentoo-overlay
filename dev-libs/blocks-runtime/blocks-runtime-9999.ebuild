# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit autotools

DESCRIPTION="Blocks runtime for libdispatch-objc2"
HOMEPAGE="https://github.com/mheily/${PN}"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/mheily/${PN}.git"
	KEYWORDS=""
else
	inherit versionator
	MY_PV=$(replace_version_separator 3 '-')
	MY_P="${PN}-${MY_PV}"

	SRC_URI="https://github.com/mheily/${PN}/archive/v${MY_PV}.tar.gz -> ${MY_P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE=""
SLOT="0"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	sys-devel/clang
"

src_prepare() {
	default
	eautoreconf
}
