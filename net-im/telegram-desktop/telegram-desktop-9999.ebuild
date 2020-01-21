# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{5,6,7} )

inherit cmake desktop flag-o-matic python-any-r1 toolchain-funcs xdg

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
		'-Telegram/ThirdParty/lz4'
	)

	KEYWORDS=""
else
	MY_PN="tdesktop"
	MY_P="${MY_PN}-${PV}-full"

	QTBASE_VER="5.14.0"
	RANGE_V3_VER="0.10.0"

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
IUSE="alsa crashreporter custom-api-id debug +effects gtk3 +pulseaudio +spell test"

REQUIRED_USE="
	|| ( alsa pulseaudio )
"

RDEPEND="
	app-arch/lz4
	app-arch/xz-utils
	dev-libs/openssl:0
	dev-qt/qtcore:5
	dev-qt/qtdbus:5
	dev-qt/qtgui:5[jpeg,png,X]
	dev-qt/qtnetwork:5
	dev-qt/qtimageformats:5
	dev-qt/qtwidgets:5[png,X]
	media-libs/openal
	media-libs/opus
	sys-libs/zlib[minizip]
	virtual/ffmpeg
	x11-libs/libva[X,drm]
	x11-libs/libX11
	!net-im/telegram-desktop-bin
	crashreporter? ( dev-util/google-breakpad )
	gtk3? (
		dev-libs/libappindicator:3
		x11-libs/gtk+:3
	)
	pulseaudio? ( media-sound/pulseaudio )
	spell? ( app-text/enchant )
	test? ( dev-cpp/catch )
"
DEPEND="${RDEPEND}"
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

	unset EGIT_COMMIT
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
	if [[ ${PV} == 9999 ]]
	then
		git_unpack
		return
	fi

	default

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
		sed '/^QStringList.*qt_make_filter_list.*QString/,/^\}$/!d' \
			"${qt_src}"/widgets/dialogs/qfiledialog.cpp >> "${qt_fun}"
	fi

	sed '/^QTextItemInt::QTextItemInt.*QGlyphLayout/,/^\}$/!d' \
		"${qt_src}"/gui/text/qtextengine.cpp >> "${qt_fun}"

	sed '/^void.*QTextItemInt::initWithScriptItem.*QScriptItem/,/^\}$/!d' \
		"${qt_src}"/gui/text/qtextengine.cpp >> "${qt_fun}"

}

src_prepare() {
	qt_prepare

	cp "${FILESDIR}"/breakpad.cmake \
		cmake/external/crash_reports/breakpad/CMakeLists.txt || die

	sed -i \
		-e 's/if.*DESKTOP_APP_USE_PACKAGED.*/if(False)/' \
		cmake/external/ranges/CMakeLists.txt \
		cmake/external/xxhash/CMakeLists.txt || die

	sed -i \
		-e '/include.*options/d' \
		cmake/options.cmake || die

	sed -i \
		-e '/ayatana-appindicator/d' \
		-e 's/\(pkg_search_module.*\)gtk+-2[^[:space:]]*/\1/' \
		-e 's/\(pkg_check_modules.*APPIND[^[:space:]]\+\)/\1 REQUIRED/' \
		-e 's/if.*build_macstore.*build_winstore.*/if(False)/' \
		Telegram/CMakeLists.txt || die

	local qt_plugins=/usr/$(get_libdir)/qt5/plugins
	local qt_add_lib_path="QCoreApplication::addLibraryPath(\"${qt_plugins}\");"

	sed -i \
		-e "/void.*Launcher::init/a ${qt_add_lib_path}" \
		Telegram/SourceFiles/core/launcher.cpp || die

	sed -i \
		-e '1s:^:#include <QtCore/QVersionNumber>\n:' \
		Telegram/SourceFiles/platform/linux/notifications_manager_linux.cpp || die

	if use !effects
	then
		sed -i -e 's/AL_ALEXT_PROTOTYPES/TDESKTOP_DISABLE_OPENAL_EFFECTS/' \
			external/openal/CMakeLists.txt || die
	fi

	# TDESKTOP_API_{ID,HASH} related:

	sed -i -e 's/if.*TDESKTOP_API_[A-Z]*.*/if(False)/' \
		Telegram/cmake/telegram_options.cmake || die

	sed -i -e '/TDESKTOP_API_[A-Z]*=\${[_A-Z]*}/d' \
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
		-DDESKTOP_APP_USE_PACKAGED_RLOTTIE=OFF
		-DTDESKTOP_DISABLE_DESKTOP_FILE_GENERATION=ON
		-DTDESKTOP_USE_PACKAGED_TGVOIP=OFF

		-DDESKTOP_APP_DISABLE_CRASH_REPORTS=$(usex !crashreporter)
		-DDESKTOP_APP_DISABLE_SPELLCHECK=$(usex !spell)
		-DTDESKTOP_DISABLE_GTK_INTEGRATION=$(usex !gtk3)
		-DTDESKTOP_FORCE_GTK_FILE_DIALOG=$(usex gtk3)
	)

	cmake_src_configure
}

src_install() {
	newbin "${BUILD_DIR}"/bin/Telegram ${PN}
	domenu lib/xdg/telegramdesktop.desktop
	einstalldocs

	local icon_size
	for icon_size in 16 32 48 64 128 256 512
	do
		newicon -s ${icon_size} \
			Telegram/Resources/art/icon${icon_size}.png telegram.png
	done
}
