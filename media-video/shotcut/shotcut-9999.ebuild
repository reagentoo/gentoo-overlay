# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic qmake-utils xdg

DESCRIPTION="A free, open source, cross-platform video editor"
HOMEPAGE="https://www.shotcut.org/ https://github.com/mltframework/shotcut/"

if [[ ${PV} == 9999 ]]
then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/mltframework/${PN}.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/mltframework/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE="webkit"

BDEPEND="
	dev-qt/linguist-tools:5
"
COMMON_DEPEND="
	dev-qt/qtcore:5
	dev-qt/qtdeclarative:5[widgets]
	dev-qt/qtgui:5
	dev-qt/qtmultimedia:5
	dev-qt/qtnetwork:5
	dev-qt/qtopengl:5
	dev-qt/qtprintsupport:5
	dev-qt/qtsql:5
	dev-qt/qtwebkit:5
	dev-qt/qtwebsockets:5
	dev-qt/qtwidgets:5
	dev-qt/qtxml:5
	>=media-libs/mlt-6.16.0-r1[ffmpeg,frei0r,jack,qt5,sdl,xml]
	media-video/ffmpeg
	!webkit? ( media-libs/mlt[melt] )
	webkit? (
		dev-qt/qtwebkit:5
		media-libs/webvfx
	)
"
DEPEND="${COMMON_DEPEND}
	dev-qt/qtconcurrent:5
	dev-qt/qtx11extras:5
"
RDEPEND="${COMMON_DEPEND}
	dev-qt/qtgraphicaleffects:5
	dev-qt/qtquickcontrols:5
	virtual/jack
"

src_prepare() {
	default

	sed -i -e '/QT.*private/d' \
		src/src.pro || die

	use webkit && return

	sed -i \
		-e 's/webkitwidgets//' \
		-e '/htmleditor.*\.cpp/d' \
		-e '/htmleditor.*\.h/d' \
		-e '/htmleditor.*\.ui/d' \
		-e '/webvfx.*\.cpp/d' \
		-e '/webvfx.*\.h/d' \
		-e '/webvfx.*\.ui/d' \
		src/src.pro || die

	sed -i \
		-e 's/qmelt/melt/' \
		src/jobs/meltjob.cpp

	sed -i \
		-e '/qmlRegisterType.*HtmlEditor/d' \
		-e '/qmlRegisterType.*Webvfx/d' \
		src/qmltypes/qmlutilities.cpp || die

	sed -i \
		-e '/HtmlEditor/d' \
		-e '/editHTML/d' \
		src/mainwindow.h || die

	sed -i \
		-e 's/if.*m_htmlEditor.*/if(true)\{/' \
		-e '/^void.*MainWindow::editHTML.*QString/,/^\}/d' \
		-e '/else.*if.*webvfx/d' \
		-e '/new.*WebvfxProducer/d' \
		src/mainwindow.cpp || die

	rm -r \
		src/qml/htmleditor \
		src/qml/filters/webvfx* || die

	sed -i \
		-e '/htmleditor/d' \
		-e '/webvfx/d' \
		translations/shotcut_*.ts \
		other-resources.qrc || die

	default
}

src_configure() {
	append-cxxflags -Wno-deprecated-declarations

	eqmake5 \
		PREFIX="${EPREFIX}/usr" \
		SHOTCUT_VERSION="${PV}"
}

src_install() {
	emake INSTALL_ROOT="${D}" install
	einstalldocs
}
