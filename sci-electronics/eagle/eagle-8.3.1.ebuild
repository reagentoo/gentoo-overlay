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
	app-crypt/mit-krb5
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
	local extralibs=$(ls -1 lib | grep -vE "^(libcrypto|libicu|libQt5|libssl)")
	for f in ${extralibs}; do
		rm lib/$f
	done

	ln -s libssl.so.1.0.0 lib/libssl.so || die

	default
}

src_install() {
	local installdir="/opt/eagle"

	exeinto ${installdir}
	doexe eagle
	rm eagle

	exeinto ${installdir}/libexec
	doexe libexec/QtWebEngineProcess
	rm libexec/QtWebEngineProcess

	doman doc/eagle.1
	rm doc/eagle.1

	use doc && dodoc README
	rm README

	insinto ${installdir}
	doins -r .

	echo -e "ROOTPATH=${installdir}\nPRELINK_PATH_MASK=${installdir}" > "${S}/90${P}"
	doenvd "${S}/90${P}"

	newicon bin/${PN}icon50.png ${PF}-icon50.png
	make_wrapper ${PN} "${EROOT}opt/${PN}/eagle" "${EROOT}opt/${PN}" "${EROOT}opt/${PN}/lib"
	make_desktop_entry ${PN} "EAGLE PCB Designer" ${PF}-icon50 "Development;Electronics"
}

pkg_postinst() {
	elog "Run \`env-update && source /etc/profile\` from within \${ROOT}"
	elog "now to set up the correct paths."
}
