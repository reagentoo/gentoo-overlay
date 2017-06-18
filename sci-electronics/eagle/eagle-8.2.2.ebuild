# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils

DESCRIPTION="Autodesk EAGLE schematic and printed circuit board (PCB) layout editor"
HOMEPAGE="http://www.autodesk.com/"
SRC_URI="http://trial2.autodesk.com/NET17SWDLD/2017/EGLPRM/ESD/Autodesk_EAGLE_${PV}_English_Linux_64bit.tar.gz"

# http://download.autodesk.com/us/FY17/Suites/LSA/en-US/lsa.html
LICENSE="Autodesk"
SLOT="0"
KEYWORDS="~amd64 -*"
IUSE="doc"

QA_PREBUILT="opt/eagle/eagle"
RESTRICT="mirror bindist"

RDEPEND="
	dev-libs/glib
	dev-libs/libgcrypt
	dev-libs/libxml2
	dev-libs/libxslt
	dev-libs/libtasn1
	dev-libs/nspr
	dev-libs/nss
	media-libs/jasper
	media-libs/mesa[egl,gbm]
	net-libs/gnutls
	sys-apps/dbus
	virtual/jpeg
	x11-libs/libX11
	x11-libs/libXau
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrender
	x11-libs/libXtst
	x11-libs/libXxf86vm
"

src_prepare() {
	ln -s libssl.so.10 lib/libssl.so
	default
}

src_install() {
	local installdir="/opt/eagle"

	exeinto $installdir
	doexe eagle
	exeinto $installdir/libexec
	doexe libexec/QtWebEngineProcess
	rm libexec/QtWebEngineProcess

	insinto $installdir
	doins -r {bin,cache,cam,dbl,dru,lbr,libexec,plugins,projects,resources,scr,ulp,web}
	doins eagle.def
	doins eagle_*.htm
	doins eagle_*.qm
	doins qt.conf
	doins qt_*.qm

	doman doc/eagle.1
	rm doc/eagle.1

	if use doc; then
		dodoc README
		doins -r doc
	else
		mkdir "${D}/opt/eagle/doc"
	fi

	insinto $installdir/lib
	doins lib/{libcrypto*,libicu*,libQt5*,libssl*}

	mkdir "${D}/opt/bin"
	ln -s ../eagle/eagle "${D}/opt/bin/eagle"

	echo -e "ROOTPATH=${installdir}\nPRELINK_PATH_MASK=${installdir}" > "${S}/90eagle-${PV}"
	doenvd "${S}/90eagle-${PV}"

	# Create desktop entry
	newicon bin/${PN}icon50.png ${PF}-icon50.png
	make_desktop_entry "${ROOT}/opt/bin/eagle" "Autodesk EAGLE Layout Editor" ${PF}-icon50 "Development;Electronics"
}

pkg_postinst() {
	elog "Run \`env-update && source /etc/profile\` from within \${ROOT}"
	elog "now to set up the correct paths."
}
