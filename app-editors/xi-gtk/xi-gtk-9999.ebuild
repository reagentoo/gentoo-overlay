# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson vala git-r3

DESCRIPTION="A GTK+ front-end for the Xi editor"
HOMEPAGE="https://github.com/eyelash/xi-gtk"

EGIT_REPO_URI="https://github.com/eyelash/${PN}.git"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS=""
IUSE=""
RESTRICT="network-sandbox"

DEPEND="$(vala_depend)
	>=x11-libs/gtk+-3.20.0
	dev-libs/json-glib"
RDEPEND="${DEPEND}
	app-editors/xi-core"

src_prepare() {
	sed -r \
		-e 's/(config.*PLUGIN_DIR.*xi)-gtk/\1/' \
		meson.build || die

	vala_src_prepare
	default
}
