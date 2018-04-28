# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils cmake-utils git-r3

DESCRIPTION="Ethereum and other technologies to provide a decentralised application framework"
HOMEPAGE="https://www.ethereum.org"
EGIT_REPO_URI="https://github.com/ethereum/${PN}.git"
EGIT_SUBMODULES=(
	evmc
	test/tests
)

if [[ ${PV} == 9999 ]]; then
	KEYWORDS=""
else
	KEYWORDS="~x86 ~amd64"
fi

LICENSE="MIT ISC GPL-3+ LGPL-3+ BSD-2 public-domain"
SLOT="0"
IUSE="ctest debug examples +fatdb hera evmjit +optimize test +tools upnp vmtrace"

RDEPEND="
	app-crypt/libscrypt
	dev-cpp/libff[curve_alt_bn128]
	<dev-cpp/libjson-rpc-cpp-1.0.0[http-client,http-server,stubgen]
	dev-libs/boost[context,threads]
	dev-libs/crypto++
	>=dev-libs/gmp-6:=
	dev-libs/jsoncpp
	dev-libs/leveldb[snappy]
	dev-libs/libsecp256k1
	dev-util/lcov
	dev-util/scons
	net-libs/libmicrohttpd
	net-misc/curl
	sys-libs/libcpuid
	sys-libs/ncurses:0[tinfo]
	sys-libs/readline:0
	virtual/opencl
	evmjit? ( net-p2p/evmjit )
	hera? ( net-p2p/hera )
	upnp? ( net-libs/miniupnpc )
"
DEPEND="${RDEPEND}"

# TODO: unbundle:
# dev-libs/libsecp256k1

CMAKE_MIN_VERSION="3.5.1"

src_unpack() {
	if [[ ${PV} != 9999 ]]; then
		EGIT_COMMIT_DATE="$(date -ud ${PV##*_p} +%s)"
	fi

	git-r3_src_unpack

	EGIT_REPO_URI="https://github.com/chfast/secp256k1.git"
	EGIT_BRANCH="develop"
	EGIT_CHECKOUT_DIR="${S}/cmake/secp256k1"
	unset EGIT_SUBMODULES

	git-r3_src_unpack
}

src_prepare() {
	rm cmake/HunterGate.cmake \
		evmc/cmake/cable/HunterGate.cmake || die

	sed -r -i \
		-e 's/include(\(HunterGate\))/function\1\nendfunction\(\)/' \
		evmc/CMakeLists.txt \
		CMakeLists.txt || die

	sed -r -i \
		-e 's/target_include_directories.+evmc.+include/\0\/evmc/' \
		evmc/CMakeLists.txt || die

	sed -r -i \
		-e '/cmake_minimum_required/a set\(CMAKE_CXX_STANDARD 11\)' \
		-e '/include.+EthCompilerSettings/d' \
		-e '/set.+Boost_USE_STATIC_LIBS/d' \
		-e '/hunter_add_package/d' \
		-e 's/(find_package.+)CONFIG/\1/' \
		-e '/find_package.+cryptopp/d' \
		-e '/find_package.+libjson-rpc-cpp/d' \
		-e '/find_package.+libscrypt/d' \
		-e 's/include.+ProjectSecp256k1.+/add_subdirectory\(cmake\/secp256k1 EXCLUDE_FROM_ALL\)/' \
		-e '/include.+ProjectLibFF/d' \
		-e '/include.+hera/d' \
		-e 's/if.+NOT EXISTS.+evmjit\/\.git.+/if \(FALSE\)/' \
		-e 's/if.+EVMJIT.+/if \(FALSE\)/' \
		-e 's/if.+HERA.+/if \(FALSE\)/' \
		CMakeLists.txt || die

	sed -r -i \
		-e 's/\$\{CMAKE_SOURCE_DIR\}/$\{CMAKE_CURRENT_LIST_DIR\}/' \
		-e 's/\$\{CMAKE_SOURCE_DIR\}\/src/$\{CMAKE_CURRENT_LIST_DIR\}\/src/' \
		cmake/secp256k1/CMakeLists.txt || die

	sed -r -i \
		-e 's/target_include_directories.+PRIVATE/\0 \/usr\/include\/libff/' \
		-e 's/target_include_directories.+PRIVATE/\0 \.\.\/cmake\/secp256k1\/include/' \
		-e 's/(target_link_libraries.+)Secp256k1/\1secp256k1/' \
		-e 's/(target_link_libraries.+)libff::(ff)/\1\2/' \
		-e 's/(target_link_libraries.+)cryptopp-static/\1crypto\+\+/' \
		-e 's/(target_link_libraries.+)libscrypt::(scrypt)/\1\2/' \
		-e 's/target_link_libraries.+PRIVATE/\0 gmp/' \
		libdevcrypto/CMakeLists.txt || die

	sed -r -i \
		-e 's/^[[:space:]]+PRIVATE/\0 jsoncpp/' \
		eth/CMakeLists.txt

	sed -r -i \
		-e 's/target_link_libraries.+PRIVATE/\0 jsoncpp/' \
		ethvm/CMakeLists.txt

	sed -r -i \
		-e 's/(jsoncpp)_lib_static/\1/' \
		-e 's/libjson-rpc-cpp::server/libjsonrpccpp-server/' \
		-e 's/target_include_directories.+PRIVATE/\0 \/usr\/include\/jsoncpp/' \
		eth/CMakeLists.txt \
		ethvm/CMakeLists.txt \
		libethereum/CMakeLists.txt \
		libevm/CMakeLists.txt || die

	sed -r -i \
		-e 's/libjson-rpc-cpp::server/jsonrpccpp-server jsonrpccpp-common/' \
		-e '/add_library/a target_include_directories(web3jsonrpc PRIVATE \/usr\/include\/jsoncpp)' \
		libweb3jsonrpc/CMakeLists.txt || die

	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=OFF
		-DCMAKE_BUILD_TYPE=$(usex debug "Debug" "Release")
		-DEVM_OPTIMIZE=$(usex optimize)
		-DEVMC_BUILD_EXAMPLES=$(usex examples)
		-DEVMC_BUILD_TESTS=$(usex test)
		-DEVMJIT=$(usex evmjit)
		-DFATDB=$(usex fatdb)
		-DFASTCTEST=$(usex ctest)
		-DHERA=$(usex hera)
		-DMINIUPNPC=$(usex upnp)
		-DPARANOID=OFF
		-DTESTS=$(usex test)
		-DTOOLS=$(usex tools)
		-DVMTRACE=$(usex vmtrace)
	)

	cmake-utils_src_configure
}
