# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic qmake-utils xdg

DESCRIPTION="A free, open source, cross-platform video editor"
HOMEPAGE="https://www.shotcut.org/"

if [[ ${PV} == 9999 ]]
then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/mltframework/${PN}.git"
else
	SRC_URI="https://github.com/mltframework/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE="webkit webvfx"

REQUIRED_USE="
	webvfx? ( webkit )
"

BDEPEND="
	dev-qt/linguist-tools:5
"
RDEPEND="
	dev-qt/qtcore:5
	dev-qt/qtdeclarative:5
	dev-qt/qtgraphicaleffects:5
	dev-qt/qtgui:5
	dev-qt/qtmultimedia:5
	dev-qt/qtnetwork:5
	dev-qt/qtopengl:5
	dev-qt/qtprintsupport:5
	dev-qt/qtquickcontrols:5[widgets]
	dev-qt/qtsql:5
	dev-qt/qtwebsockets:5
	dev-qt/qtwidgets:5
	dev-qt/qtxml:5
	media-libs/ladspa-sdk
	media-libs/libsdl:0
	media-libs/libvpx
	>=media-libs/mlt-6.16.0-r1[ffmpeg,frei0r,qt5,sdl,xml]
	media-libs/x264
	media-plugins/frei0r-plugins
	media-sound/lame
	media-video/ffmpeg
	virtual/jack
	webkit? ( dev-qt/qtwebkit:5 )
	webvfx? ( media-libs/webvfx )
"
DEPEND="${RDEPEND}
	dev-qt/qtconcurrent:5
	dev-qt/qtx11extras:5
"

src_prepare() {
	if use webvfx
	then
		default
		return
	fi

	sed -i \
		-e '/webvfx.*\.cpp/d' \
		-e '/webvfx.*\.h/d' \
		-e '/webvfx.*\.ui/d' \
		src/src.pro || die

	sed -i \
		-e '/qmlRegisterType.*Webvfx/d' \
		src/qmltypes/qmlutilities.cpp || die

	sed -i \
		-e '/else.*if.*webvfx/d' \
		-e '/new.*WebvfxProducer/d' \
		src/mainwindow.cpp || die

	rm -r \
		src/qml/filters/webvfx* || die

	sed -i \
		-e '/webvfx/d' \
		translations/shotcut_*.ts || die

	if use webkit
	then
		default
		return
	fi

	sed -i \
		-e 's/webkitwidgets//' \
		-e '/htmleditor.*\.cpp/d' \
		-e '/htmleditor.*\.h/d' \
		-e '/htmleditor.*\.ui/d' \
		src/src.pro || die

	sed -i \
		-e '/qmlRegisterType.*HtmlEditor/d' \
		src/qmltypes/qmlutilities.cpp || die

	sed -i \
		-e '/HtmlEditor/d' \
		-e '/editHTML/d' \
		src/mainwindow.h || die

	sed -i \
		-e 's/if.*m_htmlEditor.*/if(true)\{/' \
		-e '/^void.*MainWindow::editHTML.*QString/,/^\}$/d' \
		src/mainwindow.cpp || die

	rm -r \
		src/qml/htmleditor || die

	sed -i \
		-e '/htmleditor/d' \
		translations/shotcut_*.ts \
		other-resources.qrc || die

	default
}

src_configure() {
	local mycxxflags=(
		-Wno-deprecated-declarations
	)

	append-cxxflags ${mycxxflags[@]}

	eqmake5 \
		PREFIX="${EPREFIX}/usr" \
		SHOTCUT_VERSION="${PV}"
}

src_install() {
	emake INSTALL_ROOT="${D}" install
	einstalldocs
}
