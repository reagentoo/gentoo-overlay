# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{5,6,7} )
inherit desktop git-r3 python-r1 xdg-utils

MY_PN="${PN^}"

DESCRIPTION="Small and highly customizable twin-panel file manager with plugin-support"
HOMEPAGE="https://github.com/MeanEYE/Sunflower http://sunflower-fm.org/"

EGIT_REPO_URI="https://github.com/MeanEYE/${MY_PN}.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="${PYTHON_DEPS}"
RDEPEND="${DEPEND}
	gnome-base/librsvg:2
	dev-python/chardet[${PYTHON_USEDEP}]
	dev-python/pycairo[${PYTHON_USEDEP}]
	dev-python/pygobject[${PYTHON_USEDEP}]
"

src_prepare() {
	default

	sed -i -e "s/\(base_path.*\)os.path.dirname(\(.*\))/\1\2/" \
		sunflower/gui/about_window.py || die

	# TODO: sed base_path in:
	# sunflower/icons.py
	# sunflower/indicator.py
	# sunflower/notifications.py

	find "${S}"/translations -name "*.po" -delete || die
	rm "${S}"/translations/${PN}.pot || die
}

src_compile() { :; }

src_install() {
	installme() {
		# install modules
		python_moduleinto ${PN}
		python_domodule images ${PN}/*

		# generate and install startup scripts
		sed -i -e "s#@SITEDIR@#$(python_get_sitedir)/${PN}#" \
			dist/${PN} || die
		python_doscript dist/${PN}
	}

	# install for all enabled implementations
	python_foreach_impl installme

	insinto /usr/share/locale
	# correct gettext behavior
	if [[ -n "${LINGUAS+x}" ]] ; then
		for i in $(cd "${S}"/translations ; echo *) ; do
			if has ${i} ${LINGUAS} ; then
				doins -r "${S}"/translations/${i}
			fi
		done
	else
		doins -r "${S}"/translations/*
	fi

	doicon -s scalable images/${PN}.svg
	newicon -s 64 images/${PN}_64.png ${PN}.png
	newmenu ${MY_PN}.desktop ${PN}.desktop
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update

	# TODO: better description
	elog "optional dependencies:"
	elog "  dev-python/libgnome-python"
	elog "  media-libs/mutagen"
	elog "  x11-libs/vte:0[python] (terminal support)"
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}
