# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit gnome2-utils xdg-utils meson

DESCRIPTION="A simple GTK+ frontend for mpv"
HOMEPAGE="https://github.com/celluloid-player/celluloid"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/${PN}-player/${PN}.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/${PN}-player/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-3+"
SLOT="0"

RDEPEND="
	>=dev-libs/glib-2.44
	media-libs/libepoxy
	>=media-video/mpv-0.27[libmpv]
	>=x11-libs/gtk+-3.22.23:3
"

DEPEND="${RDEPEND}
	dev-util/desktop-file-utils
"

src_prepare() {
	# drop unnecessary cflags/ldflags
	sed -i \
		-e "s/if cc.has_multi_arguments.*/if false/" \
		-e "s/if cc.has_argument.*/if false/" \
		meson.build || die

	default
}

pkg_postinst() {
	xdg_desktop_database_update
	gnome2_icon_cache_update
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_desktop_database_update
	gnome2_icon_cache_update
	gnome2_schemas_update
}

