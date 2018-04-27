# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils git-r3

DESCRIPTION="eWASM virtual machine implemented in C++ conforming to the Ethereum VM API"
HOMEPAGE="https://github.com/ewasm/hera"
EGIT_REPO_URI="https://github.com/ewasm/${PN}.git"
EGIT_SUBMODULES=( evmc )

if [[ ${PV} == 9999 ]]; then
	KEYWORDS=""
else
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="MIT"
SLOT="0"
IUSE="debug evm2wasm metering"

RDEPEND="dev-util/binaryen"
DEPEND="${RDEPEND}"

CMAKE_MIN_VERSION="3.5"

src_unpack() {
	if [[ ${PV} != 9999 ]]; then
		EGIT_COMMIT_DATE="$(date -ud ${PV##*_p} +%s)"
	fi

	git-r3_src_unpack
}

src_prepare() {
	sed -r -i \
		-e '/include.+ProjectBinaryen/d' \
		CMakeLists.txt || die

	sed -r -i \
		-e 's/add_library.+hera/\0 SHARED/' \
		-e 's/target_include_directories.+hera.+PUBLIC/\0 \/usr\/include\/binaryen/' \
		-e 's/(target_link_libraries.+hera.+binaryen)::binaryen/\1/' \
		src/CMakeLists.txt || die

	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DHERA_DEBUGGING=$(usex debug)
		-DHERA_EVM2WASM=$(usex evm2wasm)
		-DHERA_METERING_CONTRACT=$(usex metering)
	)

	cmake-utils_src_configure
}

src_install() {
	doheader "${S}/src/hera.h"
	dolib "${S}_build/src/lib${PN}.so"
}
