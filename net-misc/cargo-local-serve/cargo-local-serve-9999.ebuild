# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo git-r3

DESCRIPTION="Serve a local, offline, clone of crates.io"
HOMEPAGE="https://gitlab.com/est/cargo-local-serve"

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://gitlab.com/est/${PN}.git"
	KEYWORDS=""
else
	KEYWORDS="~amd64 ~x86"
fi

RESTRICT="network-sandbox"

LICENSE="MIT/Apache-2.0"
SLOT="0"
IUSE=""

DEPEND=""
RDEPEND=""

TOOLS=(
	cargo-local-serve
	create-crate-storage
	download-all-crates
)

src_compile() {
	cargo_src_compile ${TOOLS[@]/#/--bin }
}

src_install() {
	for bin in ${TOOLS[@]}; do
		dobin target/release/${bin}
	done
}
