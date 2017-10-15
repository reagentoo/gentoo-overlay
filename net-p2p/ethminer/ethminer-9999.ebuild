# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils cmake-utils

DESCRIPTION="Ethereum miner with CUDA and stratum support"
HOMEPAGE="https://github.com/ethereum-mining/ethminer"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/ethereum-mining/${PN}.git"
	EGIT_SUBMODULES=()
	KEYWORDS=""
else
	SRC_URI="https://github.com/ethereum-mining/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-3+ LGPL-3+"
SLOT="0"
IUSE="apicore cuda dbus +opencl +stratum"

RDEPEND="
	dev-cpp/libjson-rpc-cpp[http-client]
	dev-libs/boost
	dev-libs/jsoncpp
	apicore? ( dev-cpp/libjson-rpc-cpp[tcp-socket-server] )
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
	rm cmake/HunterGate.cmake || die

	sed -r -i \
		-e '/hunter_add_package\(.*\)/d' \
		-e 's/(find_package\(.*) CONFIG (.*\))/\1 \2/' \
		libethash-cl/CMakeLists.txt \
		CMakeLists.txt || die

	sed -r -i \
		-e '1s/^/set\(CMAKE_CXX_STANDARD 14\)\n\n/' \
		-e 's/include(\(HunterGate\))/function\1\nendfunction\(\)/' \
		-e '/find_package.+libjson-rpc-cpp/d' \
		-e '/include.+EthCompilerSettings/d' \
		CMakeLists.txt || die

	sed -r -i \
		-e 's/libjson-rpc-cpp\:\:client/Boost::system jsoncpp jsonrpccpp\-client jsonrpccpp\-common/' \
		ethminer/CMakeLists.txt || die

	sed -r -i \
		-e 's/libjson-rpc-cpp\:\:server/jsonrpccpp\-server/' \
		libapicore/CMakeLists.txt || die

	sed -r -i \
		-e '1s/^/include_directories\(\/usr\/include\/jsoncpp\)\n\n/' \
		ethminer/CMakeLists.txt \
		libstratum/CMakeLists.txt || die

	sed -r -i \
		-e 's/(jsoncpp)_lib_static/\1/' \
		libstratum/CMakeLists.txt || die

	default
}

src_configure() {
	local mycmakeargs=(
		-DAPICORE=$(usex apicore)
		-DETHASHCL=$(usex opencl)
		-DETHASHCUDA=$(usex cuda)
		-DETHDBUS=$(usex dbus)
		-DETHSTRATUM=$(usex stratum)
	)

	cmake-utils_src_configure
}
