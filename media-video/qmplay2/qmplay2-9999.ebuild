# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-utils xdg-utils

DESCRIPTION="A Qt-based video player, which can play most formats and codecs"
HOMEPAGE="https://github.com/zaps166/QMPlay2"

if [[ ${PV} == *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/zaps166/QMPlay2"
else
	SRC_URI="https://github.com/zaps166/QMPlay2/releases/download/${PV}/QMPlay2-src-${PV}.tar.xz"
	KEYWORDS="~amd64 ~x86"
	S="${WORKDIR}/QMPlay2-src-${PV}"
fi

LICENSE="LGPL-3"
SLOT="0"

CORE=( avresample libass )
MODULES=( +audiofilters cuvid +extensions inputs modplug portaudio pulseaudio +videofilters +visualizations )
EXTENSIONS=( +lastfm lyrics mediabrowser mpris2 )
FFMPEG=( avdevice vaapi vdpau )
GUI=( taglib )
CHIPTUNE=( gme sid )

IUSE="${CHIPTUNE[*]} ${CORE[*]} ${EXTENSIONS[*]} ${FFMPEG[*]} ${GUI[*]} ${MODULES[*]} cdio dbus notifications opengl xv"

REQUIRED_USE="
	lastfm? ( extensions )
	lyrics? ( extensions )
	mediabrowser? ( extensions )
	mpris2? ( extensions )"

RDEPEND="
	dev-libs/jansson
	dev-qt/qtcore:5
	dev-qt/qtgui:5[png]
	dev-qt/qtwidgets:5
	dev-qt/qtx11extras:5
	dbus? ( dev-qt/qtdbus:5 )
	gme? ( media-libs/game-music-emu )
	cdio? ( dev-libs/libcdio[cddb] )
	libass? ( media-libs/libass[harfbuzz] )
	media-video/ffmpeg[encode]
	mpris2? ( dev-qt/qtdbus:5 )
	portaudio? ( media-libs/portaudio[alsa] )
	pulseaudio? ( media-sound/pulseaudio[alsa] )
	sid? ( media-libs/libsidplayfp )
	taglib? ( media-libs/taglib )
	vaapi? ( media-video/ffmpeg[vaapi] )
	vdpau? ( media-video/ffmpeg[vdpau] )
	xv? ( x11-libs/libXv )"

DEPEND="${RDEPEND}"
BDEPEND="
	dev-qt/linguist-tools:5
	virtual/pkgconfig"

src_prepare() {
	# Disable "Check for updates automatically"
	eapply "${FILESDIR}"/disable_autoupdates.patch

	# Disable preparing man pages
	sed -r \
		-e 's/if\(GZIP\)/if\(TRUE\)/' \
		-e 's/(install.+QMPlay2\.1)\.gz/\1/' \
		-i src/gui/CMakeLists.txt || die 'sed filed!'

	# Delete Ubuntu Unity shortcut group
	sed -e '/X-Ayatana-Desktop-Shortcuts/,$d' \
		-i src/gui/Unix/QMPlay2.desktop || die 'sed filed!'

	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DUSE_ALSA=ON
		-DUSE_AUDIOCD=$(usex cdio)
		-DUSE_FFMPEG=ON
		-DUSE_FREEDESKTOP_NOTIFICATIONS=$(usex dbus)
		-DUSE_NOTIFY=$(usex notifications)
		-DUSE_OPENGL2=$(usex opengl)
		-DUSE_XVIDEO=$(usex xv)
	)

	if [[ ${PV} == *9999 ]]; then
		mycmakeargs+=( USE_GIT_VERSION=ON )
	else
		mycmakeargs+=( USE_GIT_VERSION=OFF )
	fi

	for x in ${CORE[@]} ${EXTENSIONS[@]} ${GUI[@]} ${MODULES[@]}; do
		x="${x#[[:punct:]]}"
		mycmakeargs+=( -DUSE_${x^^}=$(usex $x) )
	done

	for x in ${CHIPTUNE[@]}; do
		x="${x#[[:punct:]]}"
		mycmakeargs+=( -DUSE_CHIPTUNE_${x^^}=$(usex $x) )
	done

	for x in ${FFMPEG[@]}; do
		x="${x#[[:punct:]]}"
		mycmakeargs+=( -DUSE_FFMPEG_${x^^}=$(usex $x) )
	done

	cmake-utils_src_configure
}

pkg_postinst() {
	xdg_icon_cache_update
	xdg_mimeinfo_database_update
	xdg_desktop_database_update
}

pkg_postrm() {
	xdg_icon_cache_update
	xdg_mimeinfo_database_update
	xdg_desktop_database_update
}
