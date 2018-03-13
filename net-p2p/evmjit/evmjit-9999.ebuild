# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils cmake-utils git-r3

DESCRIPTION="A library for just-in-time compilation of Ethereum EVM code"
HOMEPAGE="https://github.com/ethereum/evmjit"
EGIT_REPO_URI="https://github.com/ethereum/${PN}.git"
EGIT_SUBMODULES=()

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE="examples tests"

LLVM_SLOT=5
RDEPEND="sys-devel/llvm:${LLVM_SLOT}"
DEPEND="${RDEPEND}"

CMAKE_MIN_VERSION="3.4.0"

src_prepare() {
	sed -r -i \
		-e 's/(find_package.+LLVM)(.+)/\1 '${LLVM_SLOT}'\2/' \
		cmake/ProjectLLVM.cmake || die

	default
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE="Release"
		-DEVMJIT_EXAMPLES=$(usex examples)
		-DEVMJIT_TESTS=$(usex tests)
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
