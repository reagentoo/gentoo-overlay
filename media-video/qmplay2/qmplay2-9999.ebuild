# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PLOCALES="de es fr hu pl ru uk zh"

inherit cmake-utils l10n xdg

MY_PN="QMPlay2"

DESCRIPTION="Qt-based video player, which can play all formats and stream"
HOMEPAGE="https://github.com/zaps166/${MY_PN}"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/zaps166/${MY_PN}.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/zaps166/${MY_PN}/releases/download/${PV}/${MY_PN}-src-${PV}.tar.xz"
	KEYWORDS="~amd64 ~x86"
	S=${WORKDIR}/${MY_PN}-src-${PV}
fi

LICENSE="LGPL-3"
SLOT="0"

CHIPTUNE=( gme sid )
CORE=( avresample libass )
EXTENSIONS=( animeodcinki myfreemp3 lastfm tekstowo wbijam )
FFMPEG=( avdevice vaapi vdpau )
GUI=( jemalloc taglib )
MODULES=( alsa audiofilters cuvid extensions ffmpeg inputs modplug portaudio pulseaudio videofilters visualizations )

IUSE="${CHIPTUNE[@]} ${CORE[@]} ${EXTENSIONS[@]} ${FFMPEG[@]} ${GUI[@]} ${MODULES[@]} cdio dbus libav mpris notifications opengl xv"

REQUIRED_USE="
	animeodcinki? ( extensions )
	avdevice? ( ffmpeg )
	myfreemp3? ( extensions )
	lastfm? ( extensions )
	mpris? ( extensions )
	tekstowo? ( extensions )
	vaapi? ( ffmpeg )
	vdpau? ( ffmpeg )
	wbijam? ( extensions )
"

RDEPEND="
	avresample? ( >=media-video/ffmpeg-4.1 )
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
	dev-qt/qtx11extras:5
	dbus? ( dev-qt/qtdbus:5 )
	gme? ( media-libs/game-music-emu )
	cdio? ( dev-libs/libcdio[cddb] )
	jemalloc? ( dev-libs/jemalloc )
	libass? ( media-libs/libass )
	libav? ( media-video/libav:= )
	!libav? ( >=media-video/ffmpeg-3.1:= )
	mpris? ( dev-qt/qtdbus:5 )
	portaudio? ( media-libs/portaudio )
	pulseaudio? ( media-sound/pulseaudio )
	sid? ( media-libs/libsidplayfp )
	taglib? ( media-libs/taglib )
	vaapi? ( x11-libs/libva[opengl,X] )
	vdpau? ( x11-libs/libvdpau )
	xv? ( x11-libs/libXv )
"
DEPEND="${RDEPEND}
	dev-qt/linguist-tools:5
	virtual/pkgconfig
"

CMAKE_MIN_VERSION="3.1"

src_prepare() {
	l10n_find_plocales_changes "${S}/lang" "" '.ts'

	sed -i -r \
		-e 's/if\(GZIP\)/if\(TRUE\)/' \
		-e 's/(install.+QMPlay2\.1)\.gz/\1/' \
		src/gui/CMakeLists.txt

	# Delete Ubuntu Unity shortcut group
	sed -i -e '/X-Ayatana-Desktop-Shortcuts/,$d' \
		src/gui/Unix/QMPlay2.desktop || die

	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DLANGUAGES="$(l10n_get_locales)"
		-DUSE_AUDIOCD=$(usex cdio)
		-DUSE_FREEDESKTOP_NOTIFICATIONS=$(usex dbus)
		-DUSE_MPRIS2=$(usex mpris)
		-DUSE_NOTIFY=$(usex notifications)
		-DUSE_OPENGL2=$(usex opengl)
		-DUSE_XVIDEO=$(usex xv)
	)

	if [[ ${PV} == 9999 ]]; then
		mycmakeargs+=( USE_GIT_VERSION=ON )
	else
		mycmakeargs+=( USE_GIT_VERSION=OFF )
	fi

	for x in ${CORE[@]} ${EXTENSIONS[@]} ${GUI[@]} ${MODULES[@]}; do
		mycmakeargs+=( -DUSE_${x^^}=$(usex $x) )
	done

	for x in ${CHIPTUNE[@]}; do
		mycmakeargs+=( -DUSE_CHIPTUNE_${x^^}=$(usex $x) )
	done

	if use ffmpeg; then
		for x in ${FFMPEG[@]}; do
			mycmakeargs+=( -DUSE_FFMPEG_${x^^}=$(usex $x) )
		done
	fi

	cmake-utils_src_configure
}
