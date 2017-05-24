# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools

DESCRIPTION="${PN} is a portable implementation of the pthread_workqueue API first introduced in Mac OS X."
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

LICENSE="BSD"
SLOT="0"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"

src_prepare() {
	default
	eautoreconf
}
