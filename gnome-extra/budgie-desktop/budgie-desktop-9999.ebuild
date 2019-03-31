# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{5,6,7} )
VALA_MIN_API_VERSION="0.40"
VALA_MAX_API_VERSION="0.40"

inherit gnome2-utils meson python-single-r1 vala

DESCRIPTION="Desktop Environment based on GNOME 3"
HOMEPAGE="https://getsol.us/categories/budgie/"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/UbuntuBudgie/${PN}.git"
	EGIT_BRANCH="mutter330reduxII"
	KEYWORDS=""
elif [[ ${PV} == 8888 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/solus-project/${PN}.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/solus-project/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"

IUSE="+bluetooth gtk-doc +introspection pm-utils +policykit"

COMMON_DEPEND="
	>=app-i18n/ibus-1.5.11[vala]
	>=dev-libs/glib-2.46.0
	>=dev-libs/gobject-introspection-1.44.0[${PYTHON_USEDEP}]
	>=dev-libs/libpeas-1.8.0:0[gtk]
	>=gnome-base/gnome-desktop-3.22.0:3
	media-libs/clutter:1.0
	media-libs/cogl:1.0
	media-sound/pulseaudio
	x11-wm/mutter

	bluetooth? ( >=net-wireless/gnome-bluetooth-3.18:= )
	policykit? ( >=sys-auth/polkit-0.110[introspection=] )
"

RDEPEND="
	${COMMON_DEPEND}

	gnome-base/gnome-menus:3[introspection]
	gnome-base/gnome-session
	gnome-base/gnome-settings-daemon

	>=sys-apps/accountsservice-0.6.40
	>=x11-libs/gtk+-3.22:3
	>=x11-libs/libnotify-0.7
	>=x11-libs/libwnck-3.14:3

	pm-utils? ( sys-power/upower-pm-utils[introspection=] )
	!pm-utils? ( sys-power/upower[introspection=] )
"

PDEPEND="
	>=gnome-base/gdm-3.5[introspection]
	>=gnome-base/gnome-control-center-3.26[bluetooth(+)?]
"

DEPEND="
	${COMMON_DEPEND}
	${PYTHON_DEPS}
	$(vala_depend)

	dev-lang/sassc
	dev-util/desktop-file-utils
	dev-util/meson

	gtk-doc? ( dev-util/gtk-doc )
"

src_prepare() {
	local desktop_files=$(find src/ -name *.desktop.in)

	sed -i -e "s/OnlyShowIn=Budgie/OnlyShowIn=X-Budgie/" \
		${desktop_files[@]} || die
	sed -i -e "/add_install_script.*meson_post_install\.sh/d" \
		meson.build || die

	vala_src_prepare
	default
}

src_configure() {
	local emesonargs=(
		$(meson_use bluetooth with-bluetooth)
		$(meson_use gtk-doc with-gtk-doc)
		$(meson_use policykit with-policykit)
	)
	meson_src_configure
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
