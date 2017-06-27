# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Official golang implementation of the Ethereum protocol"
HOMEPAGE="https://github.com/ethereum/go-ethereum"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/ethereum/${PN}.git"
	KEYWORDS=""
else
	inherit versionator
	MY_PV=$(replace_version_separator 3 '-')
	MY_P=${PN}-${MY_PV}

	SRC_URI="https://github.com/ethereum/${PN}/archive/v${MY_PV}.tar.gz -> ${MY_P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-3+ LGPL-3+"
SLOT="0"
IUSE="evm opencl"

DEPEND="dev-lang/go:=
	opencl? ( virtual/opencl )
"
RDEPEND="${DEPEND}"

src_compile() {
	use opencl && export GO_OPENCL=true

	emake geth
	use evm && emake evm
}

src_install() {
	einstalldocs

	dobin build/bin/geth
	use evm && dobin build/bin/evm
}
