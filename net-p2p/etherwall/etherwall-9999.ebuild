# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3 qmake-utils

DESCRIPTION="A free software wallet/front-end for Ethereum"
HOMEPAGE="https://www.etherwall.com/"
EGIT_REPO_URI="https://github.com/almindor/etherwall.git"
EGIT_SUBMODULES=(
	src/ew-node
	src/trezor/trezor-common
)

if [[ ${PV} == 9999 ]]; then
	KEYWORDS=""
else
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~x86 ~amd64"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE=""

RDEPEND="
	dev-libs/hidapi
	dev-libs/protobuf
	dev-qt/qtcore:5
	dev-qt/qtdeclarative:5
	dev-qt/qtgraphicaleffects:5
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
	./generate_protobuf.sh || die
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
