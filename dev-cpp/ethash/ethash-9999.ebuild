# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils cmake-utils

DESCRIPTION="C/C++ implementation of Ethash – the Ethereum Proof of Work algorithm"
HOMEPAGE="https://github.com/chfast/ethash"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/chfast/${PN}.git"
	EGIT_SUBMODULES=( cmake/cable )
	KEYWORDS=""
else
	SRC_URI="https://github.com/chfast/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~x86 ~amd64"
fi

LICENSE="Apache-2.0"
SLOT="0"
IUSE="debug test"

RDEPEND=""
DEPEND="${RDEPEND}"

CMAKE_MIN_VERSION="3.5"

src_prepare() {
	rm cmake/cable/HunterGate.cmake || die

	sed -i -e 's/include(HunterGate)/function(HunterGate)\nendfunction()/' \
		CMakeLists.txt || die

	sed -i -e 's/^[[:space:]]*ethash$/\0 SHARED/' \
		lib/ethash/CMakeLists.txt || die

	sed -i -e '/hunter_add_package/d' \
		test/benchmarks/CMakeLists.txt || die

	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE=$(usex debug "Debug" "Release")
		-DETHASH_BUILD_TESTS=$(usex test)
	)

	cmake-utils_src_configure
}
