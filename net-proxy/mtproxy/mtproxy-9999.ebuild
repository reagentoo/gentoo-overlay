# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-utils git-r3

MY_PN="MTProxy"

DESCRIPTION="Simple MT-Proto proxy"
HOMEPAGE="https://github.com/TelegramMessenger/MTProxy"
EGIT_REPO_URI="https://github.com/TelegramMessenger/${PN}.git"

if [[ ${PV} == 9999 ]]; then
	KEYWORDS=""
else
	EGIT_COMMIT="${MY_PV}"
	KEYWORDS="~amd64 ~x86"
	S="${WORKDIR}/${MY_PN}-${PV}"
fi

LICENSE="GPL-2"
SLOT="0"

DEPEND=""
RDEPEND="${DEPEND}"

src_prepare() {
	cp "${FILESDIR}/mtproxy.cmake" "${S}/CMakeLists.txt"

	cmake-utils_src_prepare
}
