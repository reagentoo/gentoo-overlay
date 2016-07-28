# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
LANGS="de es fr pl ru zh"

inherit cmake-utils
[ "$PV" == "9999" ] && inherit git-r3

MY_PN="QMPlay2"

DESCRIPTION="QMPlay2 is a video player, it can plays all formats and stream"
HOMEPAGE="https://github.com/zaps166/QMPlay2"
if [ "$PV" != "9999" ]; then
	SRC_URI="https://github.com/zaps166/QMPlay2/releases/download/${PV}/${MY_PN}-src-${PV}.tar.xz"
	KEYWORDS="~amd64 ~x86"
else
	EGIT_REPO_URI="https://github.com/zaps166/${MY_PN}.git"
	KEYWORDS=""
fi

LICENSE="LGPL"
SLOT="0"
IUSE="alsa cdio +ffmpeg jemalloc libass modplug mpris opengl portaudio -pulseaudio qt4 +qt5 taglib vaapi vdpau +xv"
for x in ${LANGS}; do
	IUSE+=" linguas_${x}"
done

CMAKE_MIN_VERSION="2.8.11"

REQUIRED_USE="
	^^ ( qt4 qt5 )
"

RDEPEND="
	media-libs/game-music-emu
	media-libs/libsidplayfp
	media-libs/mesa
	cdio? ( dev-libs/libcdio[cddb] )
	ffmpeg? ( >=media-video/ffmpeg-2.2.0 )
	jemalloc? ( dev-libs/jemalloc )
	libass? ( media-libs/libass )
	portaudio? ( media-libs/portaudio )
	pulseaudio? ( media-sound/pulseaudio )
	qt4? (
		dev-qt/qtcore:4
		dev-qt/qtgui:4
		dev-qt/qtscript:4
	)
	qt5? (
		>=dev-qt/qtcore-5.6.1:5
		>=dev-qt/qtgui-5.6.1:5
		>=dev-qt/qtnetwork-5.6.1:5
		>=dev-qt/qtscript-5.6.1:5
		>=dev-qt/qtwidgets-5.6.1:5
	)
	taglib? ( >=media-libs/taglib-1.9.1 )
	vaapi? ( x11-libs/libva )
	vdpau? ( x11-libs/libvdpau )
	xv? ( x11-libs/libXv )
"
DEPEND="${RDEPEND}
	dev-qt/linguist-tools:5
"

DOCS="AUTHORS ChangeLog README.md"

S=${WORKDIR}/${MY_PN}-src-${PV}

src_configure() {
	local langs="" x
	for x in ${LANGS}; do
		use linguas_${x} && langs+=" ${x}"
	done

	local mycmakeargs=(
		-DLANGUAGES="\"${langs}\""
		-DUSE_AUDIOCD=$(usex cdio ON OFF)
		-DUSE_MPRIS2=$(usex mpris ON OFF)
		-DUSE_OPENGL2=$(usex opengl ON OFF)
		-DUSE_XVIDEO=$(usex xv ON OFF)
	)

	for x in {alsa,ffmpeg,jemalloc,libass,modplug,portaudio,pulseaudio,qt5,taglib}; do
		mycmakeargs+=( -DUSE_${x^^}=$(usex $x ON OFF) )
	done

	if use ffmpeg; then
		for x in {vaapi,vdpau}; do
			mycmakeargs+=( -DUSE_FFMPEG_${x^^}=$(usex $x ON OFF) )
		done
	fi

	cmake-utils_src_configure
}
