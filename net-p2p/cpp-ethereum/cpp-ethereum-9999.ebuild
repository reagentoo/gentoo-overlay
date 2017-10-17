# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils cmake-utils git-r3

DESCRIPTION="Ethereum and other technologies to provide a decentralised application framework"
HOMEPAGE="https://www.ethereum.org"
EGIT_REPO_URI="https://github.com/ethereum/${PN}.git"

# TODO: unbundle submodules
# EGIT_SUBMODULES=( evmjit test/tests )

LICENSE="MIT ISC GPL-3+ LGPL-3+ BSD-2 public-domain"
SLOT="0"
KEYWORDS=""
IUSE="jit tests tools"

RDEPEND="
	<dev-cpp/libjson-rpc-cpp-1.0.0[stubgen,http-client,http-server]
	dev-libs/boost
	dev-libs/crypto++
	>=dev-libs/gmp-6:=
	dev-libs/jsoncpp
	dev-libs/leveldb[snappy]
	dev-libs/libsecp256k1
	dev-util/lcov
	dev-util/scons
	net-libs/libmicrohttpd
	net-libs/miniupnpc
	net-misc/curl
	sys-libs/libcpuid
	sys-libs/ncurses:0[tinfo]
	sys-libs/readline:0
	virtual/opencl
	jit? ( >=sys-devel/llvm-4.0.0 )
"
DEPEND="${RDEPEND}"

# TODO: unbundle github.com/chfast forks:
# dev-cpp/libff
# dev-libs/libsecp256k1

CMAKE_MIN_VERSION="3.5.1"

src_prepare() {
	rm cmake/HunterGate.cmake || die

	unset EGIT_SUBMODULES

	EGIT_REPO_URI="https://github.com/chfast/libff.git"
	EGIT_BRANCH="master"
	EGIT_CHECKOUT_DIR="${S}/cmake/libff"

	git-r3_src_unpack

	EGIT_REPO_URI="https://github.com/chfast/secp256k1.git"
	EGIT_BRANCH="develop"
	EGIT_CHECKOUT_DIR="${S}/cmake/secp256k1"

	git-r3_src_unpack

	sed -r -i \
		-e '/cmake_minimum_required/a set\(CMAKE_CXX_STANDARD 11\)' \
		-e 's/include(\(HunterGate\))/function\1\nendfunction\(\)/' \
		-e 's/include.+EthCompilerSettings.+/add_compile_options\(-fPIC\)/' \
		-e '/hunter_add_package\(.*\)/d' \
		-e 's/(find_package\(.*) CONFIG (.*\))/\1 \2/' \
		-e '/find_package.+cryptopp/d' \
		-e '/include.+ProjectJsonRpcCpp/d' \
		-e 's/include.+ProjectSecp256k1.+/add_subdirectory\(cmake\/secp256k1 EXCLUDE_FROM_ALL\)/' \
		-e 's/include.+ProjectSnark.+/add_subdirectory\(cmake\/libff EXCLUDE_FROM_ALL\)/' \
		CMakeLists.txt || die

	sed -r -i \
		-e 's/\$\{CMAKE_SOURCE_DIR\}/$\{CMAKE_CURRENT_LIST_DIR\}/' \
		-e 's/\$\{CMAKE_SOURCE_DIR\}\/src/$\{CMAKE_CURRENT_LIST_DIR\}\/src/' \
		cmake/secp256k1/CMakeLists.txt || die

	sed -r -i \
		-e 's/(target_include_directories.+PRIVATE)(.+)/\1 \.\.\/cmake\/libff\2/' \
		-e 's/(target_include_directories.+PRIVATE)(.+)/\1 \.\.\/cmake\/libff\/libff\2/' \
		-e 's/(target_include_directories.+PRIVATE)(.+)/\1 \.\.\/cmake\/secp256k1\/include\2/' \
		-e 's/(target_link_libraries.+)Secp256k1(.+)/\1secp256k1\2/' \
		-e 's/(target_link_libraries.+)Snark(.+)/\1ff\2/' \
		-e 's/(target_link_libraries.+)cryptopp-static(.+)/\1crypto\+\+\2/' \
		libdevcrypto/CMakeLists.txt || die

	sed -r -i \
		-e 's/(PRIVATE)(.+)/\1 jsoncpp\2/' \
		eth/CMakeLists.txt

	sed -r -i \
		-e 's/(target_link_libraries.+PRIVATE)(.+)/\1 jsoncpp\2/' \
		ethvm/CMakeLists.txt

	sed -r -i \
		-e 's/(jsoncpp)_lib_static/\1/' \
		-e 's/(target_include_directories.+PRIVATE)(.+)/\1 \/usr\/include\/jsoncpp\2/' \
		eth/CMakeLists.txt \
		ethvm/CMakeLists.txt \
		libethereum/CMakeLists.txt \
		libevm/CMakeLists.txt \
		libweb3jsonrpc/CMakeLists.txt || die

	sed -r -i \
		-e 's/JsonRpcCpp::Server/jsonrpccpp-server jsonrpccpp-common microhttpd/' \
		libweb3jsonrpc/CMakeLists.txt || die

	sed -r -i \
		-e 's/(add_library.+scrypt)(.+)/\1 STATIC\2/' \
		utils/libscrypt/CMakeLists.txt || die

	sed -r -i \
		-e 's/add_library[[:space:]]*\([[:space:]]*([a-z0-9]+).+/\0\ninstall\(TARGETS \1 DESTINATION \$\{CMAKE_INSTALL_LIBDIR\}\)/' \
		lib*/CMakeLists.txt || die

	default
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=ON
		-DCMAKE_BUILD_TYPE="Release"
		-DEVMJIT=$(usex jit)
		-DMINIUPNPC=OFF
		-DROCKSDB=OFF
		-DTESTS=$(usex tests)
		-DTOOLS=$(usex tools)
		-DUSE_LD_GOLD=OFF
	)

	cmake-utils_src_configure
}
