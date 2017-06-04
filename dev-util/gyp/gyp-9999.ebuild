# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 )

inherit distutils-r1 git-r3

DESCRIPTION="A build system that generates other build systems"
HOMEPAGE="https://gyp.gsrc.io/"
EGIT_REPO_URI="https://chromium.googlesource.com/external/${PN}"

if [[ ${PV} == 9999 ]]; then
	KEYWORDS=""
else
	EGIT_COMMIT="a478c1ab51ea3e04e79791ac3d1dad01b3f57434"
	KEYWORDS="~x86 ~amd64"
fi

LICENSE="BSD"
SLOT="0"
IUSE=""

RDEPEND=""

DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
"
