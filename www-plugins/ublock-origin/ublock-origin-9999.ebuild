# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils git-r3

MY_PN="uBlock"

DESCRIPTION="The Fastest, Most-Powerful Ad Blocker"
HOMEPAGE="https://www.ublock.org/"
EGIT_REPO_URI="https://github.com/gorhill/${MY_PN}.git"

if [[ ${PV} == 9999 ]]; then
	KEYWORDS=""
else
	MY_PV="${PV/_pre/b}"
	MY_PV="${PV/_rc/rc}"
	EGIT_COMMIT="${MY_PV}"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE="chromium firefox opera thunderbird"
REQUIRED_USE="|| ( chromium firefox opera thunderbird )"

RDEPEND=""
DEPEND="${RDEPEND}"

DOCS=( MANIFESTO.md README.md )

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
	use chromium && ( tools/make-chromium.sh || die )
	use firefox && ( tools/make-firefox.sh all || die )
	use opera && ( tools/make-opera.sh || die )
	use thunderbird && ( tools/make-thunderbird.sh all || die )

	default
}

src_install() {
	if use chromium; then
		insinto "/usr/share/chromium/extensions/${PN}"
		doins -r dist/build/uBlock0.chromium/.
	fi

	if use firefox; then
		insinto "/usr/$(get_libdir)/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
		newins dist/build/uBlock0.firefox.xpi uBlock0@raymondhill.net.xpi
	fi

	if use opera; then
		insinto "/usr/$(get_libdir)/opera/extensions/${PN}"
		doins -r dist/build/uBlock0.opera/.
	fi

	if use thunderbird; then
		insinto "/usr/$(get_libdir)/thunderbird/extensions/{3550f703-e582-4d05-9a08-453d09bdfdc6}"
		newins dist/build/uBlock0.thunderbird.xpi uBlock0@raymondhill.net.xpi
	fi

	default
}
