# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
PLOCALES="ca de el es et fr gl it ja ko nl pt ru zh_CN zh_TW"

inherit l10n qmake-utils versionator

DESCRIPTION="A full featured webcam capture application"
HOMEPAGE="https://webcamoid.github.io"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/webcamoid/${PN}.git"
	KEYWORDS=""
else
	MY_PV=$(replace_version_separator 3 '-')

	SRC_URI="https://github.com/webcamoid/${PN}/archive/${MY_PV}.tar.gz -> ${PN}-${MY_PV}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE="doc headers jack pulseaudio"

RDEPEND="
	dev-qt/qtcore:5
	dev-qt/qtdeclarative:5
	dev-qt/qtgui:5
	dev-qt/qtmultimedia:5
	dev-qt/qtnetwork:5
	dev-qt/qtopengl:5
	dev-qt/qtwidgets:5
	>=media-libs/gstreamer-1.6.0
	>=media-video/ffmpeg-3.1.0:=
	media-libs/libv4l
	jack? ( virtual/jack )
	pulseaudio? ( media-sound/pulseaudio )
"

DEPEND="${RDEPEND}
	>=sys-kernel/linux-headers-3.6
	virtual/pkgconfig
	doc? ( dev-qt/qdoc )
"

DOCS=( AUTHORS CONTRIBUTING.md ChangeLog README.md THANKS )

src_prepare() {
	local tsdir="${S}/StandAlone/share/ts"
	local mylrelease="$(qt5_get_bindir)"/lrelease

	prepare_locale() {
		"${mylrelease}" "${tsdir}/${1}.ts" || die "preparing ${1} locale failed"
	}

	rm_locale() {
		sed -i \
			-e '/.*share\/ts\/'${1}'\.qm.*/d' \
			StandAlone/translations.qrc || die
	}

	rm ${tsdir}/*.qm

	l10n_find_plocales_changes "${tsdir}" "" '.ts'
	l10n_for_each_locale_do prepare_locale
	l10n_for_each_disabled_locale_do rm_locale

	default
}

src_configure() {
	eqmake5 "PREFIX=/usr" \
		"BUILDDOCS=$(usex doc 1 0)" \
		"INSTALLDEVHEADERS=$(usex headers 1 0)" \
		"LIBDIR=/usr/$(get_libdir)"
}

src_install() {
	emake INSTALL_ROOT="${D}" install
	use doc && einstalldocs
}
