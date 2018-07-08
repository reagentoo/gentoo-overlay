# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

MY_PN="HLSLCrossCompiler"

DESCRIPTION="Cross compiles HLSL bytecode to GLSL or GLSL ES"
HOMEPAGE="https://github.com/James-Jones/${MY_PN}"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/James-Jones/${MY_PN}.git"
	KEYWORDS=""
else
	MY_P="${MY_PN}-${PV}"
	SRC_URI="https://github.com/James-Jones/${MY_PN}/archive/${PV}.tar.gz -> ${MY_P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="MIT"
SLOT="0"
IUSE="debug static-libs"

CMAKE_MIN_VERSION="2.8.0"

RDEPEND="
"
DEPEND="${RDEPEND}
"

CMAKE_USE_DIR="${S}/mk"

src_prepare() {
	cp "${FILESDIR}/minmaxdef.h" "${S}/include" || die

	sed -i '1i #include "minmaxdef.h"' \
		"${S}/src/toGLSLInstruction.c" \
		"${S}/src/toGLSLOperand.c" || die

	sed -i \
		-e '/i386/d' \
		-e '/CMAKE_ARCHIVE_OUTPUT_DIRECTORY/d' \
		-e '/CMAKE_RUNTIME_OUTPUT_DIRECTORY/d' \
		-e '$ aSET_TARGET_PROPERTIES(libHLSLcc PROPERTIES OUTPUT_NAME '${PN}' )' \
		-e '$ aSET_TARGET_PROPERTIES(HLSLcc PROPERTIES OUTPUT_NAME '${PN}' )' \
			"${S}/mk/CMakeLists.txt" || die

	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_SKIP_BUILD_RPATH=TRUE
		-DCMAKE_BUILD_TYPE=$(usex debug Debug Release)
		-DBUILD_SHARED_LIBS=$(usex static-libs OFF ON)
	)

	cmake-utils_src_configure
}

src_install() {
	dobin "${BUILD_DIR}/${PN}"
	dolib "${BUILD_DIR}/lib${PN}$(usex static-libs .a .so)"
	insinto "/usr/include/${PN}"
	doins include/{hlslcc.h,hlslcc.hpp,pstdint.h}
	dodoc README
}
