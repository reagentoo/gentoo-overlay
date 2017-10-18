# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils gnome2-utils xdg cmake-utils toolchain-funcs flag-o-matic multilib git-r3

DESCRIPTION="Official desktop client for Telegram"
HOMEPAGE="https://desktop.telegram.org"
EGIT_REPO_URI="https://github.com/telegramdesktop/tdesktop.git"
EGIT_SUBMODULES=(
	Telegram/ThirdParty/libtgvoip
	Telegram/ThirdParty/variant
	Telegram/ThirdParty/GSL
)

if [[ ${PV} == 9999 ]]; then
	KEYWORDS=""
else
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~x86 ~amd64"
fi

LICENSE="GPL-3-with-openssl-exception"
SLOT="0"
IUSE="+crashreporter custom-api-id debug test"

RDEPEND="
	dev-libs/libappindicator:3
	dev-libs/openssl:0
	dev-util/google-breakpad
	dev-qt/qtcore:5
	dev-qt/qtgui:5[gtk(+),jpeg,png,xcb]
	dev-qt/qtnetwork
	dev-qt/qtimageformats
	dev-qt/qtwidgets[png,xcb]
	media-libs/openal
	media-libs/opus
	media-sound/pulseaudio
	sys-libs/zlib[minizip]
	virtual/ffmpeg
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libva[X,drm]
	x11-libs/libX11
	!net-im/telegram
	!net-im/telegram-desktop-bin
	test? ( dev-cpp/catch )
"

DEPEND="${RDEPEND}
	virtual/pkgconfig
"

CMAKE_MIN_VERSION="3.8"
CMAKE_USE_DIR="${S}/Telegram"

PATCHES=( "${FILESDIR}/patches" )

src_prepare() {
	# FIXME: drop this sed if AUTOMOC_MOC_OPTIONS works in cmake
	sed -i -e '/\#pragma once/a \#include "stdafx.h"' \
		Telegram/SourceFiles/application.h || die

	local CMAKE_MODULES_DIR="${S}/Telegram/cmake"
	local THIRD_PARTY_DIR="${S}/Telegram/ThirdParty"
	local LIBTGVOIP_DIR="${THIRD_PARTY_DIR}/libtgvoip"

	cp "${FILESDIR}/Telegram.cmake" "${S}/Telegram/CMakeLists.txt"
	cp "${FILESDIR}/ThirdParty-libtgvoip.cmake" "${LIBTGVOIP_DIR}/CMakeLists.txt"

	mkdir "${CMAKE_MODULES_DIR}"
	cp "${FILESDIR}/FindBreakpad.cmake" "${CMAKE_MODULES_DIR}"
	cp "${FILESDIR}/TelegramCodegen.cmake" "${CMAKE_MODULES_DIR}"
	cp "${FILESDIR}/TelegramCodegenTools.cmake" "${CMAKE_MODULES_DIR}"

	rm -fr "${LIBTGVOIP_DIR}/webrtc_dsp/webrtc"

	unset EGIT_COMMIT
	unset EGIT_SUBMODULES

	EGIT_REPO_URI="https://chromium.googlesource.com/external/webrtc"
	EGIT_CHECKOUT_DIR="${LIBTGVOIP_DIR}/webrtc_dsp/webrtc"

	git-r3_src_unpack
	cp "${FILESDIR}/ThirdParty-libtgvoip-webrtc.cmake" \
		"${LIBTGVOIP_DIR}/webrtc_dsp/webrtc/CMakeLists.txt"

	if use custom-api-id; then
		if [[ -n "${TELEGRAM_CUSTOM_API_ID}" ]] && [[ -n "${TELEGRAM_CUSTOM_API_HASH}" ]]; then
			(
				echo 'static const int32 ApiId = '"${TELEGRAM_CUSTOM_API_ID}"';'
				echo 'static const char *ApiHash = "'"${TELEGRAM_CUSTOM_API_HASH}"'";'
			) > custom_api_id.h
		else
			eerror ""
			eerror "It seems you did not set one or both of TELEGRAM_CUSTOM_API_ID and TELEGRAM_CUSTOM_API_HASH variables,"
			eerror "which are required for custom-api-id USE-flag."
			eerror "You can set them either in:"
			eerror "- /etc/portage/make.conf (globally, so all applications you'll build will see that ID and HASH"
			eerror "- /etc/portage/env/${CATEGORY}/${PN} (privately for this package builds)"
			eerror ""
			die "You should correctly set TELEGRAM_CUSTOM_API_ID && TELEGRAM_CUSTOM_API_HASH variables if you want custom-api-id USE-flag"
		fi
	fi

	cmake-utils_src_prepare

	mv "${S}"/lib/xdg/telegram{,-}desktop.desktop || die "Failed to fix .desktop-file name"
}

src_configure() {
	local mycxxflags=(
#		$(usex custom-api-id '-DCUSTOM_API_ID' "$(usex upstream-api-id '' '-DGENTOO_API_ID')") # Variant for moving ebuild in the tree.
		$(usex custom-api-id '-DCUSTOM_API_ID' '')
		-DLIBDIR="$(get_libdir)"
		# If you will copy this ebuild from my overlay, please don't forget to uncomment -DGENTOO_API_ID definition here and fix the patch (and manifest).
		# And also, don't forget to get your (or Gentoo's, in case you'll move ot to the portage tree) unique ID and HASH
	)

	local mycmakeargs=(
		-DCMAKE_CXX_FLAGS:="${mycxxflags[*]}"
		-DBREAKPAD_INCLUDE_DIR="/usr/include/breakpad"
		-DBREAKPAD_LIBRARY_DIR="/usr/$(get_libdir)/libbreakpad_client.a"
		-DBUILD_TESTS=$(usex test)
		-DTDESKTOP_DISABLE_CRASH_REPORTS=$(usex crashreporter OFF ON)
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	default

	local icon_size
	for icon_size in 16 32 48 64 128 256 512; do
		newicon -s "${icon_size}" \
			"${S}/Telegram/Resources/art/icon${icon_size}.png" \
			telegram-desktop.png
	done
}

pkg_preinst() {
	xdg_pkg_preinst
	gnome2_icon_savelist
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_icon_cache_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_icon_cache_update
}
