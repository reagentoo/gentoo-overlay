# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

MY_PN="RxCpp"

DESCRIPTION="Library of algorithms for values-distributed-in-time"
HOMEPAGE="https://github.com/Reactive-Extensions/RxCpp"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/Reactive-Extensions/${MY_PN}.git"
	EGIT_SUBMODULES=()
	KEYWORDS=""
else
	MY_PV=$(replace_version_separator 3 '-')
	MY_P=${MY_PN}-${MY_PV}

	SRC_URI="https://github.com/Reactive-Extensions/${MY_PN}/archive/v${MY_PV}.tar.gz -> ${MY_P}.tar.gz"
	KEYWORDS="~amd64 ~x86"

	S=${WORKDIR}/${MY_P}
fi

LICENSE="Apache-2.0"
SLOT="0"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"

CMAKE_MIN_VERSION="3.2"

DOCS=( README.md )

src_prepare() {
	sed -r -i \
		-e 's/catch\.h/catch\/\0/' \
		Rx/v2/examples/tests/main.cpp \
		Rx/v2/examples/tests/take.cpp \
		Rx/v2/test/test.h || die

	sed -r -i \
		-e '/add_subdirectory.+Rx\/v2\/test/d' \
		-e '/add_subdirectory.+Rx\/v2\/doxygen/d' \
		-e '/set.+EXAMPLES_DIR.+Rx\/v2\/examples/d' \
		-e '/add_subdirectory.+EXAMPLES_DIR.+examples/d' \
		-e 's/(install.+DESTINATION).+rxcpp/\1 \$\{CMAKE_INSTALL_PREFIX\}\/include\/rxcpp/' \
		projects/CMake/CMakeLists.txt || die

	cmake-utils_src_prepare
}
