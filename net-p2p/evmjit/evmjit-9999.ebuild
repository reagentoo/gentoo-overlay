# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils cmake-utils git-r3

DESCRIPTION="A library for just-in-time compilation of Ethereum EVM code"
HOMEPAGE="https://github.com/ethereum/evmjit"
EGIT_REPO_URI="https://github.com/ethereum/${PN}.git"
EGIT_SUBMODULES=( evmc )

if [[ ${PV} == 9999 ]]; then
	KEYWORDS=""
else
	KEYWORDS="~x86 ~amd64"
fi

LICENSE="MIT"
SLOT="0"
IUSE="debug examples test"

LLVM_SLOT=5
RDEPEND="sys-devel/llvm:${LLVM_SLOT}"
DEPEND="${RDEPEND}"

CMAKE_MIN_VERSION="3.4.0"

src_unpack() {
	if [[ ${PV} != 9999 ]]; then
		EGIT_COMMIT_DATE="$(date -ud ${PV##*_p} +%s)"
	fi

	git-r3_src_unpack
}

src_prepare() {
	sed -r -i \
		-e 's/find_package.+LLVM/\0 '${LLVM_SLOT}'/' \
		-e 's/llvm_map_components_to_libnames.+LIBS/\0 all/' \
		cmake/ProjectLLVM.cmake || die

	sed -r -i \
		-e 's/add_library.+evmjit/\0 SHARED/' \
		libevmjit/CMakeLists.txt || die

	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE=$(usex debug "Debug" "Release")
		-DEVMJIT_EXAMPLES=$(usex examples)
		-DEVMJIT_TESTS=$(usex test)
		-DLLVM_DIR="/usr/lib/llvm/${LLVM_SLOT}/${get_libdir}/cmake"
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	default

	if use examples; then
		exeinto /usr/share/${PN}/examples
		doexe ${S}_build/examples/example-capi
	fi
}
