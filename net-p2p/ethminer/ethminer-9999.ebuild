# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils cmake-utils git-r3

DESCRIPTION="Ethereum miner with CUDA and stratum support"
HOMEPAGE="https://github.com/ethereum-mining/ethminer"
EGIT_REPO_URI="https://github.com/ethereum-mining/${PN}.git"
EGIT_SUBMODULES=( cmake/cable )

if [[ ${PV} == 9999 ]]; then
	KEYWORDS=""
else
	MY_PV="${PV/_pre/.dev}"
	MY_PV="${PV/_rc/rc}"
	EGIT_COMMIT="v${MY_PV}"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-3+ LGPL-3+"
SLOT="0"
IUSE="apicore cuda dbus +opencl"

RDEPEND="
	>=dev-cpp/libjson-rpc-cpp-1.0.0[http-client]
	dev-cpp/uri
	dev-libs/boost
	dev-libs/jsoncpp
	cuda? ( dev-util/nvidia-cuda-toolkit )
	dbus? ( sys-apps/dbus )
	opencl? ( virtual/opencl )
"
DEPEND="${RDEPEND}
	dbus? ( virtual/pkgconfig )
"

CMAKE_MIN_VERSION="3.3"

pkg_setup() {
	einfo
	einfo "If you have problems with finding the OpenCL library"
	einfo "please ensure that you select opencl library from"
	einfo "eselect opencl list"
	einfo
}

src_prepare() {
	rm cmake/cable/HunterGate.cmake || die

	sed -r -i \
		-e '/hunter_add_package/d' \
		-e 's/(find_package.+)CONFIG/\1/' \
		libethash-cl/CMakeLists.txt \
		libpoolprotocols/CMakeLists.txt \
		CMakeLists.txt || die

	sed -r -i \
		-e 's/include(\(HunterGate\))/function\1\nendfunction\(\)/' \
		-e '/find_package.+libjson-rpc-cpp/d' \
		-e '/find_package.+CppNetlibUri/d' \
		-e '/include.+EthCompilerSettings/d' \
		CMakeLists.txt || die

	sed -r -i \
		-e 's/include_directories.+BEFORE.+\.\./\0 \./' \
		-e 's/target_link_libraries.+ethminer(.+ethcore.+)/set\(ETHMINER_LINK_LIBRARIES\1/' \
		-e 's/(find_package.+)PkgConfig(.+)/\1DBus1 REQUIRED\2/' \
		-e '/set.+ENV/d' \
		-e '/pkg_check_modules.+DBUS/d' \
		-e '/link_directories.+DBUS/d' \
		-e 's/(include_directories.+)DBUS_INCLUDE_DIRS/\1DBus1_INCLUDE_DIRS/' \
		-e 's/target_link_libraries.+EXECUTABLE.+DBUS_LIBRARIES.+/list\(APPEND ETHMINER_LINK_LIBRARIES \$\{DBus1_LIBRARY\}\)/' \
		-e 's/target_link_libraries.+ethminer.+apicore.+/list\(APPEND ETHMINER_LINK_LIBRARIES apicore\)/' \
		-e '/include.+GNUInstallDirs/i target_link_libraries\(\$\{EXECUTABLE\} PRIVATE \$\{ETHMINER_LINK_LIBRARIES\}\)\n' \
		ethminer/CMakeLists.txt || die

	sed -r -i \
		-e 's/libjson-rpc-cpp\:\:server/jsonrpccpp\-server/' \
		libapicore/CMakeLists.txt || die

	sed -r -i \
		-e 's/(jsoncpp_lib)_static/\1/' \
		-e 's/libjson-rpc-cpp::client/jsonrpccpp-client jsonrpccpp-common/' \
		-e 's/target_include_directories.+poolprotocols/\0 PUBLIC \/usr\/include\/jsoncpp/' \
		libpoolprotocols/CMakeLists.txt || die

	sed -r -i \
		-e 's/\*(m_uri\..+\(\))/\1\.data\(\)/' \
		libpoolprotocols/PoolURI.cpp || die

	if use dbus; then
		sed -r -i \
			-e '/find_package/a find_package\(DBus1 REQUIRED\)' \
			-e 's/target_include_directories.+poolprotocols/\0 PUBLIC \$\{DBus1_INCLUDE_DIRS\}/' \
			-e 's/target_include_directories.+poolprotocols.+PRIVATE/\0 ..\/ethminer/' \
			libpoolprotocols/CMakeLists.txt || die
	fi

	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DAPICORE=$(usex apicore)
		-DETHASHCL=$(usex opencl)
		-DETHASHCUDA=$(usex cuda)
		-DETHDBUS=$(usex dbus)
	)

	cmake-utils_src_configure
}
