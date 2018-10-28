# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils git-r3

MY_PN="uBlock"

DESCRIPTION="The Fastest, Most-Powerful Ad Blocker"
HOMEPAGE="https://www.ublock.org/"
EGIT_REPO_URI="https://github.com/gorhill/${MY_PN}.git"

if [[ ${PV} == 9999 ]]; then
	KEYWORDS=""
else
	MY_PV="${PV/_pre/b}"
	EGIT_COMMIT="${MY_PV}"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"

src_unpack() {
	git-r3_src_unpack

	unset EGIT_COMMIT
	unset EGIT_SUBMODULES

	EGIT_REPO_URI="https://github.com/uBlockOrigin/uAssets.git"
	EGIT_CHECKOUT_DIR="${WORKDIR}/uAssets"
	EGIT_COMMIT_DATE=$(GIT_DIR=${S}/.git git show -s --format=%ct || die)

	git-r3_src_unpack
}

src_prepare() {
	sed -r -i \
		-e 's/(git.+clone.+)https.+/\1\.\.\/uAssets/' \
		tools/make-assets.sh || die

	default
}

src_compile() {
	./tools/make-chromium.sh || die

	default
}

src_install() {
	insinto /etc/chromium
	newins "${FILESDIR}/chromium-ublock-origin" ublock-origin

	insinto "/usr/share/${PN}"
	doins -r dist/build/uBlock0.chromium/.

	default
}
