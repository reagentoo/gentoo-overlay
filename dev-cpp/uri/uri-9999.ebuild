# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils git-r3

DESCRIPTION="Implements a generic URI parser, compatible with RFC 3986 and RFC 3987"
HOMEPAGE="https://github.com/cpp-netlib/uri"
EGIT_REPO_URI="https://github.com/cpp-netlib/${PN}.git"
EGIT_SUBMODULES=()

if [[ ${PV} == 9999 ]]; then
	KEYWORDS=""
else
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="BSL-1.0"
SLOT="0"
IUSE="doc test"

RDEPEND=""
DEPEND="${RDEPEND}
	dev-libs/boost
"

CMAKE_MIN_VERSION="2.8"

src_unpack() {
	if [[ ${PV} != 9999 ]]; then
		EGIT_COMMIT_DATE="$(date -ud ${PV##*_p} +%s)"
	fi

	git-r3_src_unpack
}

src_prepare() {
	rm -fr src/boost || die

	sed -r -i \
		-e 's/add_library.+network-uri/\0 SHARED/' \
		-e 's/(DESTINATION.+)lib/\1\$\{CMAKE_INSTALL_LIBDIR\}/' \
		src/CMakeLists.txt || die

	sed -r -i \
		-e 's/(#include[[:space:]]+)"\.\.\/(boost.+)"/\1<\2>/' \
		-e 's/network_(boost::)/\1/' \
		src/detail/uri_normalize.cpp \
		src/detail/uri_resolve.cpp || die

	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DUri_BUILD_DOCS=$(usex doc)
		-DUri_BUILD_TESTS=$(usex test)
	)

	cmake-utils_src_configure
}
