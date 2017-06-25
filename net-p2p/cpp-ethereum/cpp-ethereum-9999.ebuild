# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils cmake-utils git-r3

DESCRIPTION="Ethereum and other technologies to provide a decentralised application framework"
HOMEPAGE="https://www.ethereum.org"
EGIT_REPO_URI="https://github.com/ethereum/${PN}.git"

# TODO: unbundle submodules
# EGIT_SUBMODULES=()

LICENSE="MIT ISC GPL-3+ LGPL-3+ BSD-2 public-domain"
SLOT="0"
KEYWORDS=""
IUSE="jit tests tools"

DEPEND="
	dev-cpp/libjson-rpc-cpp[stubgen,http-client,http-server]
	dev-libs/boost
	=dev-libs/crypto++-0_p20170106
	>=dev-libs/gmp-6:=
	dev-libs/jsoncpp
	dev-libs/leveldb[snappy]
	dev-util/lcov
	dev-util/scons
	net-libs/libmicrohttpd
	net-libs/miniupnpc
	net-misc/curl
	sys-libs/libcpuid
	sys-libs/ncurses:0[tinfo]
	sys-libs/readline:0
	virtual/opencl
	jit? ( sys-devel/llvm:4 )
"
# TODO: unbundle github.com/chfast forks:
# dev-cpp/libff
# dev-libs/libsecp256k1
# sci-libs/mpir

RDEPEND="${DEPEND}"

CMAKE_MIN_VERSION="3.4.3"

unbundle_project_lib() {
	sed -r -i \
		-e 's/(set\('${1^^}'_INCLUDE_DIR) .+\)/\1 \/usr\/include\/'${1,,}'\)/' \
		-e 's/(set\('${1^^}'_LIBRARY) .+\)/\1 \/usr\/'$(get_libdir)'\/lib'${1,,}'\.so\)/' \
		"cmake/Project${1}.cmake" || die
}

src_prepare() {
	cmake-utils_src_prepare

	cp ${FILESDIR}/ExternalProjectNull.cmake ${S}/cmake

	sed -r -i \
		-e 's/include\(ExternalProject\)/include\(ExternalProjectNull\)/' \
		-e '/include\(GNUInstallDirs\)/d' \
		-e '/file\(MAKE_DIRECTORY.*\)/d' \
		cmake/ProjectBoost.cmake \
		cmake/ProjectCryptopp.cmake \
		cmake/ProjectJsonCpp.cmake \
		cmake/ProjectJsonRpcCpp.cmake \
		cmake/ProjectLcov.cmake || die

	for pkg in {Cryptopp,JsonCpp,JsonRpcCpp}; do
		unbundle_project_lib ${pkg}
	done

	sed -r -i \
		-e '1s/^/find_package\(Boost REQUIRED\)\n\n/' \
		-e 's/(set\(BOOST_LIBRARY_SUFFIX) \.a\)/\1 \.so\)/' \
		-e 's/(set\(BOOST_INCLUDE_DIR) .+\)/\1 \$\{Boost_INCLUDE_DIRS\}\)/' \
		-e 's/(set\(BOOST_LIBRARY_DIR) .+\)/\1 \$\{Boost_LIBRARY_DIRS\}\)/' \
		cmake/ProjectBoost.cmake || die

	sed -r -i \
		-e '/add_dependencies\(jsonrpccpp jsoncpp\)/d' \
		-e 's/(IMPORTED_LOCATION) .+common.+\)/\1 \/usr\/'$(get_libdir)'\/libjsonrpccpp-common\.so\)/' \
		-e 's/(IMPORTED_LOCATION) .+server.+\)/\1 \/usr\/'$(get_libdir)'\/libjsonrpccpp-server\.so\)/' \
		cmake/ProjectJsonRpcCpp.cmake || die

	sed -r -i \
		-e 's/(set\(LCOV_TOOL) .+\)/\1 \/usr\/bin\/lcov\)/' \
		cmake/ProjectLcov.cmake || die

	sed -r -i \
		-e '/add_dependencies\(snark boost\)/d' \
		cmake/ProjectSnark.cmake || die

	default
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=OFF
		-DEVMJIT=$(usex jit)
		-DMINIUPNPC=OFF
		-DROCKSDB=OFF
		-DTESTS=$(usex tests)
		-DTOOLS=$(usex tools)
		-DUSE_LD_GOLD=OFF
	)

	cmake-utils_src_configure
}
