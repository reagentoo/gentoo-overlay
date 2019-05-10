# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo desktop git-r3 xdg

DESCRIPTION="GTK 3 terminal emulator based on the GPU-accelerated Alacritty core"
HOMEPAGE="https://github.com/myfreeweb/galacritty"
EGIT_REPO_URI="https://github.com/myfreeweb/${PN}.git"

if [[ ${PV} == 9999 ]]; then
	KEYWORDS=""
else
	EGIT_COMMIT="${MY_PV}"
	KEYWORDS="~amd64 ~x86"
fi

RESTRICT="network-sandbox"

LICENSE="Unlicense"
SLOT="0"
IUSE=""

RDEPEND=">=x11-libs/gtk+-3.20.0"
DEPEND="${RDEPEND}"

src_install() {
	cargo_src_install --path .

	insinto "/usr/share/icons/hicolor/scalable/apps"
	doins "res/icons/hicolor/scalable/apps/technology.unrelenting.galacritty.svg"

	insinto "/usr/share/icons/hicolor/symbolic/apps"
	doins "res/icons/hicolor/symbolic/apps/technology.unrelenting.galacritty-symbolic.svg"

	make_desktop_entry "${PN}" "${PN}" 'technology.unrelenting.galacritty' \
		'GTK;TerminalEmulator'

	einstalldocs
}
