# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils cmake-utils git-r3

DESCRIPTION="C/C++ implementation of Ethash – the Ethereum Proof of Work algorithm"
HOMEPAGE="https://github.com/chfast/ethash"
EGIT_REPO_URI="https://github.com/chfast/${PN}.git"
EGIT_SUBMODULES=( cmake/cable )

if [[ ${PV} == 9999 ]]; then
	KEYWORDS=""
else
	KEYWORDS="~x86 ~amd64"
fi

LICENSE="Apache-2.0"
SLOT="0"
IUSE="debug test"

RDEPEND=""
DEPEND="${RDEPEND}"

CMAKE_MIN_VERSION="3.5"

src_unpack() {
	if [[ ${PV} != 9999 ]]; then
		EGIT_COMMIT_DATE="$(date -ud ${PV##*_p} +%s)"
	fi

	git-r3_src_unpack
}

src_prepare() {
	rm cmake/cable/HunterGate.cmake || die

	sed -r -i \
		-e 's/include(\(HunterGate\))/function\1\nendfunction\(\)/' \
		CMakeLists.txt || die

	sed -r -i \
		-e 's/^[[:space:]]*ethash$/\0 SHARED/' \
		lib/ethash/CMakeLists.txt || die

	sed -r -i \
		-e '/hunter_add_package/d' \
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
