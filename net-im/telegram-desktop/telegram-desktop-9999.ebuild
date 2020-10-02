# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6..9} )

inherit cmake flag-o-matic python-any-r1 toolchain-funcs xdg

DESCRIPTION="Official desktop client for Telegram"
HOMEPAGE="https://desktop.telegram.org"

if [[ ${PV} == 9999 ]]
then
	inherit git-r3

	EGIT_BRANCH="dev"
	EGIT_REPO_URI="https://github.com/telegramdesktop/tdesktop.git"
	EGIT_SUBMODULES=(
		'*'
		'-Telegram/ThirdParty/Catch'
		'-Telegram/ThirdParty/libdbusmenu-qt'
		'-Telegram/ThirdParty/lz4'
	)

	KEYWORDS=""
else
	MY_PN="tdesktop"
	MY_P="${MY_PN}-${PV}-full"

	QTBASE_VER="5.15.1"
	RANGE_V3_VER="0.11.0"

	SRC_URI="
		https://github.com/telegramdesktop/${MY_PN}/releases/download/v${PV}/${MY_P}.tar.gz
		https://github.com/ericniebler/range-v3/archive/${RANGE_V3_VER}.tar.gz -> range-v3-${RANGE_V3_VER}.tar.gz
		https://download.qt.io/official_releases/qt/${QTBASE_VER%.*}/${QTBASE_VER}/submodules/qtbase-everywhere-src-${QTBASE_VER}.tar.xz
	"

	KEYWORDS="~amd64 ~x86"
	S="${WORKDIR}/${MY_P}"
fi

LICENSE="GPL-3-with-openssl-exception"
SLOT="0"
IUSE="alsa crashreporter custom-api-id dbus debug enchant gtk3 +hunspell +pulseaudio test +webrtc +X"

REQUIRED_USE="
	|| ( alsa pulseaudio )
	enchant? ( !hunspell )
"

RDEPEND="
	app-arch/lz4:=
	app-arch/xz-utils
	dev-libs/openssl:0
	dev-qt/qtcore:5
	dev-qt/qtgui:5[dbus?,jpeg,png,wayland,X(-)?]
	dev-qt/qtimageformats:5
	dev-qt/qtnetwork:5
	dev-qt/qtwidgets:5[png,X(-)?]
	media-libs/fontconfig:=
	media-libs/openal[alsa?,pulseaudio?]
	media-libs/opus:=
	media-video/ffmpeg:=[alsa?,opus,pulseaudio?]
	sys-libs/zlib[minizip]
	virtual/libiconv
	x11-libs/libxcb:=
	!net-im/telegram-desktop-bin
	crashreporter? ( dev-util/google-breakpad )
	dbus? (
		dev-qt/qtdbus:5
		dev-libs/libdbusmenu-qt[qt5(+)]
	)
	enchant? ( app-text/enchant:= )
	gtk3? (
		dev-libs/glib:2
		x11-libs/gdk-pixbuf:2[jpeg,X?]
		x11-libs/gtk+:3[X?]
		x11-libs/libX11
	)
	hunspell? ( >=app-text/hunspell-1.7:= )
	pulseaudio? ( media-sound/pulseaudio )
	test? ( dev-cpp/catch )
	webrtc? (
		media-libs/google-webrtc[absl,c++17,libevent,owt,proprietary-codecs,x265]
	)
"
DEPEND="
	${PYTHON_DEPS}
	${RDEPEND}
"
BDEPEND="
	>=dev-util/cmake-3.16
	virtual/pkgconfig
"

pkg_pretend() {
	if use custom-api-id
	then
		[[ -n "${TDESKTOP_API_ID}" ]] && \
		[[ -n "${TDESKTOP_API_HASH}" ]] && (
			einfo "Will be used custom 'api_id' and 'api_hash':"
			einfo "TDESKTOP_API_ID=${TDESKTOP_API_ID}"
			einfo "TDESKTOP_API_HASH=${TDESKTOP_API_HASH//[!\*]/*}"
		) || (
			eerror "It seems you did not set one or both of"
			eerror "TDESKTOP_API_ID and TDESKTOP_API_HASH variables,"
			eerror "which are required for custom-api-id USE-flag."
			eerror "You can set them either in your env or bashrc."
			die
		)

		echo ${TDESKTOP_API_ID} | grep -q "^[0-9]\+$" || (
			eerror "Please check your TDESKTOP_API_ID variable"
			eerror "It should consist of decimal numbers only"
			die
		)

		echo ${TDESKTOP_API_HASH} | grep -q "^[0-9A-Fa-f]\{32\}$" || (
			eerror "Please check your TDESKTOP_API_HASH variable"
			eerror "It should consist of 32 hex numbers only"
			die
		)
	fi

	if tc-is-gcc && [[ $(gcc-major-version) -lt 7 ]]
	then
		die "At least gcc 7.0 is required"
	fi
}

git_unpack() {
	git-r3_src_unpack

	unset EGIT_BRANCH
	unset EGIT_SUBMODULES

	EGIT_COMMIT_DATE=$(GIT_DIR="${S}/.git" git show -s --format=%ct || die)

	EGIT_REPO_URI="https://code.qt.io/qt/qtbase.git"
	EGIT_CHECKOUT_DIR="${WORKDIR}"/Libraries/qtbase

	git-r3_src_unpack

	EGIT_REPO_URI="https://github.com/ericniebler/range-v3.git"
	EGIT_CHECKOUT_DIR="${WORKDIR}"/Libraries/range-v3

	git-r3_src_unpack
}

src_unpack() {
	default

	if [[ ${PV} == 9999 ]]
	then
		git_unpack
		return
	fi

	mkdir Libraries || die
	mv range-v3-${RANGE_V3_VER} Libraries/range-v3 || die
	mv qtbase-everywhere-src-${QTBASE_VER} Libraries/qtbase || die
}

qt_prepare() {
	local qt_src="${WORKDIR}"/Libraries/qtbase/src
	local qt_fun="${S}"/Telegram/SourceFiles/qt_functions.cpp

	echo "#include <QtGui/private/qtextengine_p.h>" > "${qt_fun}"

	if use gtk3
	then
		sed '/^QStringList.*qt_make_filter_list.*QString/,/^\}/!d' \
			"${qt_src}"/widgets/dialogs/qfiledialog.cpp >> "${qt_fun}"
	fi

	sed '/^QTextItemInt::QTextItemInt.*QGlyphLayout/,/^\}/!d' \
		"${qt_src}"/gui/text/qtextengine.cpp >> "${qt_fun}"

	sed '/^void.*QTextItemInt::initWithScriptItem.*QScriptItem/,/^\}/!d' \
		"${qt_src}"/gui/text/qtextengine.cpp >> "${qt_fun}"

}

src_prepare() {
	qt_prepare

	cp "${FILESDIR}"/breakpad.cmake \
		cmake/external/crash_reports/breakpad/CMakeLists.txt || die

	sed -i -e 's/if.*DESKTOP_APP_USE_PACKAGED.*/if(False)/' \
		cmake/external/{expected,gsl,ranges,rlottie,variant,webrtc,xxhash}/CMakeLists.txt || die

	local webrtc_loc="${EPREFIX}/usr/include/webrtc"

	sed -i \
		-e '/third_party\/abseil-cpp/d' \
		-e "s:\${webrtc_loc}:${webrtc_loc/:/\\:}:" \
		-e 's:\${webrtc_libs_list}:webrtc:' \
		cmake/external/webrtc/CMakeLists.txt || die

	sed -i -e '/include.*options/d' \
		cmake/options.cmake || die

	if use !alsa
	then
		sed -i -e '/alsa/Id' \
			Telegram/cmake/lib_tgvoip.cmake
	fi

	if use !pulseaudio
	then
		sed -i -e '/pulse/Id' \
			Telegram/cmake/lib_tgvoip.cmake
	fi

	# TDESKTOP_API_{ID,HASH} related:

	sed -i -e 's/if.*TDESKTOP_API_[A-Z]*.*/if(False)/' \
		Telegram/cmake/telegram_options.cmake || die

	sed -i -e '/TDESKTOP_API_[A-Z]*/d' \
		Telegram/CMakeLists.txt || die

	if use !custom-api-id
	then
		sed -i -e '/#error.*API_ID.*API_HASH/d' \
			Telegram/SourceFiles/config.h || die
	else
		local -A api_defs=(
			[ID]="#define TDESKTOP_API_ID ${TDESKTOP_API_ID}"
			[HASH]="#define TDESKTOP_API_HASH ${TDESKTOP_API_HASH}"
		)

		sed -i \
			-e "/#if.*defined.*TDESKTOP_API_ID/i ${api_defs[ID]}" \
			-e "/#if.*defined.*TDESKTOP_API_HASH/i ${api_defs[HASH]}" \
			Telegram/SourceFiles/config.h || die
	fi

	cmake_src_prepare
}

src_configure() {
	local mycxxflags=(
		-Wno-deprecated-declarations
		-Wno-error=deprecated-declarations
		-Wno-switch
		$(usex !alsa -DWITHOUT_ALSA '')
		$(usex !pulseaudio -DWITHOUT_PULSE '')
	)

	append-cxxflags ${mycxxflags[@]}

	local mycmakeargs=(
		-DDESKTOP_APP_USE_PACKAGED=ON

		-DDESKTOP_APP_DISABLE_CRASH_REPORTS=$(usex !crashreporter)
		-DDESKTOP_APP_DISABLE_DBUS_INTEGRATION=$(usex !dbus)
		-DDESKTOP_APP_DISABLE_SPELLCHECK=$(usex !enchant $(usex !hunspell))
		-DDESKTOP_APP_DISABLE_WEBRTC_INTEGRATION=$(usex !webrtc)
		-DDESKTOP_APP_USE_ENCHANT=$(usex enchant)
		-DTDESKTOP_DISABLE_GTK_INTEGRATION=$(usex !gtk3)
	)

	cmake_src_configure
}
