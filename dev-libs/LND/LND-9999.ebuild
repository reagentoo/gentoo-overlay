# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

MY_PN="UELinuxNativeDialogs"
MY_PV=$(replace_version_separator 2 '-')
MY_P="${MY_PN}-${MY_PV}"

DESCRIPTION="Linux file dialog implementations dedicated for Unreal Engine"
HOMEPAGE="https://github.com/encharm/${MY_PN}"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/encharm/${MY_PN}.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/encharm/${MY_PN}/archive/${MY_PV}.tar.gz -> ${MY_P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="MIT"
SLOT="0"
IUSE="gtk2 gtk3 qt4 qt5 sdl tests"

REQUIRED_USE="
	|| ( gtk2 gtk3 qt4 qt5 )
"

RDEPEND="
	gtk2? ( x11-libs/gtk+:2 )
	gtk3? ( x11-libs/gtk+:3 )
	qt4? ( dev-qt/qtgui:4 )
	qt5? ( dev-qt/qtgui:5 )
	sdl? ( media-libs/libsdl2 )
"
DEPEND="${RDEPEND}
	gtk3? ( sdl? ( dev-util/pkgconfig ) )
"

src_prepare() {
	local sedargs

	use gtk2 || sedargs+=( -e '/find_package.*GTK2/d' )
	use gtk3 || sedargs+=( -e '/pkg_check_modules.*GTK3/d' )
	use qt4 || sedargs+=( -e '/find_package.*Qt4/d' )
	use qt5 || sedargs+=( -e '/find_package.*Qt5/d' )
	use sdl || sedargs+=( -e '/pkg_check_modules.*SDL2/d' )

	use gtk3 || use sdl \
		|| sedargs+=( -e '/find_package.*PkgConfig/d' )

	use tests || sedargs+=(
		-e '/add_executable.*test[[:space:]]/d'
		-e '/target_link_libraries.*test[[:space:]]/d'
	)

	sed -i "${sedargs[@]}" \
		CMakeLists.txt || die

	epatch "${FILESDIR}/${PN}-drop-strdup-decl.patch"

	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_SKIP_BUILD_RPATH=TRUE
	)

	cmake-utils_src_configure
}

src_install() {
	dolib "${BUILD_DIR}/libLND.so"

	for f in {gtk2,gtk3,qt4,qt5}; do
		if use ${f}; then
			dolib "${BUILD_DIR}/libLND-${f}.so"

			if use sdl; then
				newbin "${BUILD_DIR}/${f}sdltest" ${PN}-${f}sdltest
			fi

			if use tests; then
				newbin "${BUILD_DIR}/${f}test" ${PN}-${f}test
			fi
		fi
	done

	insinto "/usr/include/${PN}"
	doins UNativeDialogs.h
	dodoc README.md
}
