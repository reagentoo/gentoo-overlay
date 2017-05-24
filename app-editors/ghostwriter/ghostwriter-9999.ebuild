# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PLOCALES="de en it ja pt_BR ru"

inherit l10n qmake-utils

DESCRIPTION="A cross-platform, aesthetic, distraction-free Markdown editor"
HOMEPAGE="http://wereturtle.github.io/${PN}/"

if [ "$PV" != "9999" ]; then
	SRC_URI="https://github.com/wereturtle/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~x86 ~amd64"
else
	inherit git-r3
	EGIT_REPO_URI="https://github.com/wereturtle/${PN}.git"
	KEYWORDS=""
fi

LICENSE="GPL-3"
SLOT="0"
IUSE="qt5"

RDEPEND="
	app-text/hunspell
	qt5? (
		dev-qt/qtconcurrent:5
		dev-qt/qtmultimedia:5
		dev-qt/qtprintsupport:5
		dev-qt/qtwebkit:5
		dev-qt/qtwidgets:5
	)
	!qt5? ( dev-qt/qtwebkit:4 )
"
DEPEND="${RDEPEND}"

DOCS=( CREDITS.md README.md )

src_prepare() {
	local mylrelease="$(qt$(usex qt5 5 4)_get_bindir)"/lrelease

	prepare_locale() {
		"${mylrelease}" "translations/${PN}_${1}.ts" || die "preparing ${1} locale failed"
	}

	l10n_find_plocales_changes translations ${PN}_ .ts
	l10n_for_each_locale_do prepare_locale

	default
}

src_configure() {
	if use qt5; then
		eqmake5 "PREFIX=/usr"
	else
		eqmake4 "PREFIX=/usr"
	fi
}

src_install() {
	emake INSTALL_ROOT="${D}" install
	einstalldocs
}
