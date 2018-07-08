# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools

DESCRIPTION="Blocks runtime for libdispatch-objc2"
HOMEPAGE="https://github.com/mheily/${PN}"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/mheily/${PN}.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/mheily/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
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
