# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo git-r3

DESCRIPTION="A modern editor with a backend written in Rust"
HOMEPAGE="https://xi-editor.io/xi-editor/"

EGIT_REPO_URI="https://github.com/xi-editor/xi-editor.git"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS=""
IUSE="+syntect"
RESTRICT="network-sandbox"

DEPEND=""
RDEPEND=""

S=${WORKDIR}/${P}/rust

src_compile() {
	cargo_src_compile

	if use syntect; then
		cargo build -v -j $(makeopts_jobs) $(usex debug "" --release) \
			--manifest-path syntect-plugin/Cargo.toml \
			|| die "cargo build failed"
	fi
}

src_install() {
	cargo_src_install --path .

	if use syntect; then
		insinto /usr/share/xi/plugins/syntect
		doins syntect-plugin/manifest.toml
		exeinto /usr/share/xi/plugins/syntect/bin
		doexe target/release/xi-syntect-plugin
	fi
}
