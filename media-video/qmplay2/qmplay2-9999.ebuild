# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
LANGS="de es fr pl ru zh"

inherit cmake-utils

MY_PN="QMPlay2"

DESCRIPTION="Qt-based video player, which can play all formats and stream"
HOMEPAGE="https://github.com/zaps166/${MY_PN}"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/zaps166/${MY_PN}.git"
	KEYWORDS=""
else
	MY_PV=$(replace_version_separator 3 '-')

	SRC_URI="https://github.com/zaps166/${MY_PN}/releases/download/${MY_PV}/${MY_PN}-src-${MY_PV}.tar.xz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="LGPL"
SLOT="0"
IUSE="alsa cdio +ffmpeg gme jemalloc libass modplug mpris opengl portaudio -pulseaudio qt4 +qt5 sid taglib vaapi vdpau +xv"
IUSE="${IUSE} +avdevice -avresample +audiofilters extensions inputs lastfm prostopleer +videofilters visualizations"
for x in ${LANGS}; do
	IUSE+=" l10n_${x}"
done

REQUIRED_USE="
	^^ ( qt4 qt5 )
	avdevice? ( ffmpeg )
	lastfm? ( extensions )
	mpris? ( extensions )
	prostopleer? ( extensions )
	vaapi? ( ffmpeg )
	vdpau? ( ffmpeg )
"

RDEPEND="
	media-libs/mesa
	>=media-video/ffmpeg-2.2.0
	gme? ( media-libs/game-music-emu )
	cdio? ( dev-libs/libcdio[cddb] )
	jemalloc? ( dev-libs/jemalloc )
	libass? ( media-libs/libass )
	portaudio? ( media-libs/portaudio )
	pulseaudio? ( media-sound/pulseaudio )
	qt4? (
		dev-qt/qtcore:4
		dev-qt/qtgui:4
		opengl? ( dev-qt/qtopengl:4 )
	)
	qt5? (
		>=dev-qt/qtcore-5.6.1:5
		>=dev-qt/qtgui-5.6.1:5
		>=dev-qt/qtwidgets-5.6.1:5
	)
	sid? ( media-libs/libsidplayfp )
	taglib? ( >=media-libs/taglib-1.9.1 )
	vaapi? ( x11-libs/libva )
	vdpau? ( x11-libs/libvdpau )
	xv? ( x11-libs/libXv )
"
DEPEND="${RDEPEND}
	dev-qt/linguist-tools:5
"

CMAKE_MIN_VERSION="2.8.11"
DOCS=( AUTHORS ChangeLog README.md )

S=${WORKDIR}/${MY_PN}-src-${PV}

src_configure() {
	local langs=() x
	for x in ${LANGS}; do
		use l10n_${x} && langs+="${x}"
	done

	local mycmakeargs=(
		-DLANGUAGES="\"${langs}\""
		-DUSE_AUDIOCD=$(usex cdio ON OFF)
		-DUSE_OPENGL2=$(usex opengl ON OFF)
		-DUSE_XVIDEO=$(usex xv ON OFF)
	)

	if use extensions; then
		mycmakeargs+=( -DUSE_MPRIS2=$(usex mpris ON OFF) )
	fi

	for x in {alsa,ffmpeg,jemalloc,libass,modplug,portaudio,pulseaudio,qt5,taglib}; do
		mycmakeargs+=( -DUSE_${x^^}=$(usex $x ON OFF) )
	done

	for x in {avresample,audiofilters,extensions,inputs,lastfm,prostopleer,videofilters,visualizations}; do
		mycmakeargs+=( -DUSE_${x^^}=$(usex $x ON OFF) )
	done

	for x in {gme,sid}; do
		mycmakeargs+=( -DUSE_CHIPTUNE_${x^^}=$(usex $x ON OFF) )
	done

	if use ffmpeg; then
		for x in {avdevice,vaapi,vdpau}; do
			mycmakeargs+=( -DUSE_FFMPEG_${x^^}=$(usex $x ON OFF) )
		done
	fi

	cmake-utils_src_configure
}
