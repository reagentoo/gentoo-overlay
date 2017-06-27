# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit qmake-utils versionator

DESCRIPTION="A free software wallet/front-end for Ethereum"
HOMEPAGE="https://www.etherwall.com/"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/almindor/${PN}.git"
	KEYWORDS=""
else
	MY_PV=$(replace_version_separator 3 '-')
	MY_P=${PN}-${MY_PV}

	SRC_URI="https://github.com/almindor/${PN}/archive/v${MY_PV}.tar.gz -> ${MY_P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE=""

RDEPEND="
	dev-libs/hidapi
	dev-libs/protobuf
	dev-qt/qtcore:5
	dev-qt/qtdeclarative:5
	dev-qt/qtgui:5
	dev-qt/qtnetwork:5
	dev-qt/qtwebsockets:5
	dev-qt/qtwidgets:5
	net-p2p/go-ethereum
	virtual/libudev
"

DEPEND="${RDEPEND}
	virtual/pkgconfig
"

DOCS=( CHANGELOG README.md )

src_prepare() {
	default
	mv Etherwall.pro ${PN}.pro
}

src_configure() {
	eqmake5 "target.path=/usr/bin"
}

src_install() {
	emake INSTALL_ROOT="${D}" install
	einstalldocs

	# TODO: convert ico to png
	# newicon icon.ico ${PN}.png
	make_desktop_entry ${PN} \
		"Ethereum QT5 Wallet" ${PN} "Network"
}
