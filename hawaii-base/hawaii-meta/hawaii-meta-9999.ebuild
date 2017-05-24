# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Meta ebuild for Hawaii Desktop Environment"
HOMEPAGE="http://hawaiios.org/"

LICENSE="metapackage"
SLOT="0"
if [[ ${PV} == 9999 ]]; then
	KEYWORDS=""
else
	KEYWORDS="~amd64 ~x86"
fi

IUSE="+eyesight +icons plymouth +preferences sddm +terminal +wallpapers"

RDEPEND="
	=hawaii-base/hawaii-shell-${PV}*
	=hawaii-base/hawaii-workspace-${PV}*
	eyesight? ( hawaii-base/eyesight )
	icons? ( =hawaii-base/hawaii-icon-theme-${PV}* )
	plymouth? ( hawaii-base/hawaii-plymouth-theme )
	preferences? ( =hawaii-base/hawaii-system-preferences-${PV}* )
	sddm? ( >=x11-misc/sddm-0.11.0 )
	terminal? ( hawaii-base/hawaii-terminal )
	wallpapers? ( =hawaii-base/hawaii-wallpapers-${PV}* )
"

S="${WORKDIR}"
