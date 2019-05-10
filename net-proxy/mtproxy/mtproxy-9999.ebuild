# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo git-r3

DESCRIPTION="MTProto Proxy Server"
HOMEPAGE="https://github.com/dotcypress/mtproxy"
EGIT_REPO_URI="https://github.com/dotcypress/${PN}.git"

if [[ ${PV} == 9999 ]]; then
	KEYWORDS=""
else
	EGIT_COMMIT="${MY_PV}"
	KEYWORDS="~amd64 ~x86"
fi

RESTRICT="network-sandbox"

LICENSE="MIT/Apache-2.0"
SLOT="0"
IUSE=""

DEPEND=""
RDEPEND=""

src_prepare() {
	sed -i \
		-e '/macro_use/d' \
		-e '/deny.*warnings/a #\[macro_use\]' \
		src/main.rs || die

	default
}
