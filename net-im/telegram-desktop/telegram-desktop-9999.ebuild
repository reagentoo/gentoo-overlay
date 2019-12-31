# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{5,6,7} )
inherit cmake-utils flag-o-matic python-any-r1 toolchain-funcs \
	desktop gnome2-utils xdg \
	git-r3

DESCRIPTION="Official desktop client for Telegram"
HOMEPAGE="https://desktop.telegram.org"

EGIT_REPO_URI="https://github.com/telegramdesktop/tdesktop.git"
EGIT_SUBMODULES=(
	'*'
)

if [[ ${PV} == 9999 ]]
then
	inherit git-r3
	EGIT_BRANCH="dev"
else
	EGIT_COMMIT="v${PV}"
	RANGE_V3_VER="0.10.0"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-3-with-openssl-exception"
SLOT="0"
IUSE="crashreporter custom-api-id debug gtk3 pulseaudio test"

RDEPEND="
	app-text/enchant

	app-arch/lz4
	app-arch/xz-utils
	dev-libs/openssl:0
	dev-qt/qtcore:5
	dev-qt/qtdbus:5
	dev-qt/qtgui:5[jpeg,png,xcb]
	dev-qt/qtnetwork:5
	dev-qt/qtimageformats:5
	dev-qt/qtwidgets:5[png,xcb]
	media-libs/libexif
	media-libs/openal
	media-libs/opus
	sys-libs/zlib[minizip]
	virtual/ffmpeg
	x11-libs/libva[X,drm]
	x11-libs/libxkbcommon
	!net-im/telegram-desktop-bin
	crashreporter? ( dev-util/google-breakpad )
	gtk3? (
		x11-libs/gtk+:3
		dev-libs/libappindicator:3
	)
	pulseaudio? ( media-sound/pulseaudio )
	test? ( dev-cpp/catch )
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

CMAKE_MIN_VERSION="3.8"
#CMAKE_USE_DIR="${S}/Telegram"

PATCHES=( "${FILESDIR}/patches" )

pkg_pretend() {
	if use custom-api-id
	then
		[[ -n "${API_ID}" ]] && \
		[[ -n "${API_HASH}" ]] && (
			einfo "Will be used custom 'api_id' and 'api_hash':"
			einfo "API_ID=${API_ID}"
			einfo "API_HASH=${API_HASH//[!\*]/*}"
		) || (
			eerror "It seems you did not set one or both of"
			eerror "API_ID and API_HASH variables,"
			eerror "which are required for custom-api-id USE-flag."
			eerror "You can set them either in your env or bashrc."
			die
		)
	fi

	if tc-is-gcc && [[ $(gcc-major-version) -lt 7 ]]
	then
		die "At least gcc 7.0 is required"
	fi
}

src_unpack() {
	git-r3_src_unpack

	unset EGIT_COMMIT
	unset EGIT_COMMIT_DATE
	unset EGIT_SUBMODULES

	EGIT_REPO_URI="https://github.com/ericniebler/range-v3.git"
	EGIT_CHECKOUT_DIR="${WORKDIR}/Libraries/range-v3"

	if [[ ${PV} == 9999 ]]
	then
		EGIT_COMMIT_DATE=$(GIT_DIR="${S}/.git" git show -s --format=%ct || die)
	else
		EGIT_COMMIT="${RANGE_V3_VER}"
	fi

	git-r3_src_unpack
}

src_prepare() {
	cp "${FILESDIR}/external.cmake" "${S}/cmake"
	cat "${FILESDIR}/install.cmake" >> "${S}/Telegram/CMakeLists.txt"

	rm -fr Telegram/ThirdParty/variant/.mason
	echo > cmake/options_linux.cmake

	sed -i \
		-e 's#include.*cmake.*external.*#include(cmake/external.cmake)#' \
		CMakeLists.txt || die

#	sed -i \
#		-e '/add_subdirectory.*external/d' \
#		cmake/CMakeLists.txt || die

	sed -i \
		-e '/add_subdirectory.*crash_reports/d' \
		-e '/add_subdirectory.*ffmpeg/d' \
		-e '/add_subdirectory.*lz4/d' \
		-e '/add_subdirectory.*openal/d' \
		-e '/add_subdirectory.*openssl/d' \
		-e '/add_subdirectory.*opus/d' \
		-e '/add_subdirectory.*qt/d' \
		-e '/add_subdirectory.*zlib/d' \
		cmake/external/CMakeLists.txt || die

#	sed -i \
#		-e '/-Wno-unused-but-set-variable/d' \
#		-e '/-Wno-stringop-overflow/d' \
#		-e '/-Wno-maybe-uninitialized/d' \
#		-e '/-Wno-error=class-memaccess/d' \
#		cmake/options_linux.cmake || die

	sed -i \
		-e '/external_crash_reports/d' \
		Telegram/lib_base/CMakeLists.txt || die

	sed -i \
		-e '/LINK_SEARCH_START_STATIC/d' \
		cmake/init_target.cmake || die

	sed -i \
		-e '/qt_static_plugins/a qt_functions.cpp' \
		-e '/third_party_loc.*minizip/d' \
		Telegram/CMakeLists.txt || die

	sed -i \
		-e '1s:^:#include <QtCore/QVersionNumber>\n:' \
		Telegram/SourceFiles/platform/linux/notifications_manager_linux.cpp || die

	sed -i \
		-e '/Q_IMPORT_PLUGIN/d' \
		Telegram/SourceFiles/qt_static_plugins.cpp || die

	if use !custom-api-id
	then
		sed -i -e '/error.*API_ID.*API_HASH/d' \
			Telegram/SourceFiles/config.h || die
	fi

	cmake-utils_src_prepare
}

src_configure() {
	local mycxxflags=(
		-Wno-error=deprecated-declarations
	)

	local mycmakeargs=(
		-DCMAKE_CXX_FLAGS:="${mycxxflags[*]}"
		-DDESKTOP_APP_DISABLE_CRASH_REPORTS=ON
		-DTDESKTOP_DISABLE_GTK_INTEGRATION=ON
		-DTDESKTOP_API_ID=${API_ID}
		-DTDESKTOP_API_HASH=${API_HASH}
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
			telegram.png
	done

	newmenu "${S}"/lib/xdg/telegramdesktop.desktop telegram-desktop.desktop
}
