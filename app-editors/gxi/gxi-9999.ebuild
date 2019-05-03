# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson git-r3 xdg

DESCRIPTION="GTK frontend, written in Rust, for the xi editor"
HOMEPAGE="https://github.com/Cogitri/gxi"
EGIT_REPO_URI="https://github.com/Cogitri/${PN}.git"

if [[ ${PV} == 9999 ]]; then
	KEYWORDS=""
else
	EGIT_COMMIT="${MY_PV}"
	KEYWORDS="~amd64 ~x86"
fi

RESTRICT="network-sandbox"

LICENSE="MIT"
SLOT="0"
IUSE=""

RDEPEND="
	>=dev-libs/glib-2.38
	x11-libs/cairo
	>=x11-libs/gtk+-3.20.0
	>=x11-libs/pango-1.38"
DEPEND="${DEPEND}
	virtual/cargo"
