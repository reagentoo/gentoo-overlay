# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit cmake-utils versionator

DESCRIPTION="Restbed is a comprehensive and consistent programming model for building applications that require seamless and secure communication over HTTP"
HOMEPAGE="https://github.com/Corvusoft/restbed"
if [ "$PV" != "9999" ]; then
	SRC_URI="https://github.com/Corvusoft/${PN}/archive/4.0.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
else
	inherit git-r3
	EGIT_REPO_URI="https://github.com/Corvusoft/${PN}.git"
	KEYWORDS=""
fi

LICENSE="AGPL"
SLOT="0"
IUSE="examples ssl static-libs test"

CMAKE_MIN_VERSION="2.8.10"

RDEPEND="
	dev-cpp/asio
	dev-cpp/catch
	ssl? ( dev-libs/openssl )
	sys-libs/pam
"
DEPEND="${RDEPEND}
"

DOCS="README.md"
version_compare "${PV}" "4.5"
[[ $? -ne 1 ]] && \
	DOCS+="
		documentation/API.md
		documentation/STANDARDS.md
		documentation/UML.md
	"

src_prepare() {
	sed -r -i \
		-e 's/(LIBRARY DESTINATION) "library"/\1 "lib"/' \
		-e 's/(ARCHIVE DESTINATION) "library"/\1 "lib"/' \
		CMakeLists.txt || die

	if use examples; then
		sed -r -i \
			-e 's/\$\{CMAKE_INSTALL_PREFIX\}/\0\/share\/corvusoft\/restbed/' \
			-e 's/(DESTINATION) "resource"/\1 "${CMAKE_INSTALL_PREFIX}\/share\/corvusoft\/restbed\/resource"/' \
			example/CMakeLists.txt || die
	fi

	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED=$(usex static-libs OFF ON)
		-DBUILD_TESTS=$(usex test ON OFF)
	)

	for x in {examples,ssl}; do
		mycmakeargs+=( -DBUILD_${x^^}=$(usex $x ON OFF) )
	done

	cmake-utils_src_configure
}
