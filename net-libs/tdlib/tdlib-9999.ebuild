# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Cross-platform library for building Telegram clients"
HOMEPAGE="https://core.telegram.org/tdlib https://github.com/tdlib/td"

if [[ ${PV} == 9999 ]]
then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/${PN}/td.git"
	EGIT_SUBMODULES=()
	KEYWORDS=""
else
	SRC_URI="https://github.com/${PN}/td/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="Boost-1.0"
SLOT="0"
IUSE="doc java test"

BDEPEND="
	dev-util/gperf
	doc? ( app-doc/doxygen )
	java? ( virtual/jdk )
"
RDEPEND="
	dev-db/sqlite
	dev-libs/openssl
	sys-libs/zlib
"
DEPEND="${RDEPEND}"

src_prepare() {
	sed -i -e '/^install/,/^)/d' \
		td{actor,db,net,utils}/CMakeLists.txt || die

	sed -i -e '/example/d' \
		tdactor/CMakeLists.txt || die

	local findPkgConfig="find_package(PkgConfig REQUIRED)"
	local pkgCheckModules="pkg_check_modules(SQLITE3 REQUIRED sqlite3)"

	sed -i \
		-e "/add_library.*tddb/i ${findPkgConfig}" \
		-e "/add_library.*tddb/i ${pkgCheckModules}" \
		-e 's/target_include_directories.*PUBLIC/& ${SQLITE3_INCLUDE_DIRS}/' \
		-e 's/\(target_link_libraries.*\)tdsqlite/\1${SQLITE3_LIBRARIES}/' \
		-e '/binlog_dump/d' \
		tddb/CMakeLists.txt || die

	sed -i \
		-e 's/\(include.*sqlite\).*sqlite/\1/' \
		tddb/td/db/detail/RawSqliteDb.cpp \
		tddb/td/db/SqliteStatement.cpp \
		tddb/td/db/SqliteDb.cpp || die

	sed -i \
		-e '/add_subdirectory.*benchmark/d' \
		-e '/add_subdirectory.*sqlite/d' \
		-e 's/install.*TARGETS/& tg_cli/' \
		-e '/install.*TARGETS/ s/tdcore[a-z]*//g' \
		-e '/install.*TARGETS/ s/tdjson_[a-z]*//g' \
		-e '/install.*TARGETS/ s/Td[A-Za-z]*Static//g' \
		CMakeLists.txt || die

	if use test
	then
		sed -i -e '/run_all_tests/! {/all_tests/d}' \
			test/CMakeLists.txt || die
	else
		sed -i \
			-e '/enable_testing/d' \
			-e '/add_subdirectory.*test/d' \
			CMakeLists.txt || die
	fi

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DTD_ENABLE_DOTNET=OFF
		-DTD_ENABLE_JNI=$(usex java)
	)

	cmake_src_configure
}

src_compile() {
	cmake_src_compile

	if use doc
	then
		doxygen Doxyfile || die
	fi
}

src_install() {
	cmake_src_install

	use doc && local HTML_DOCS=( docs/html/. )
	einstalldocs
}
