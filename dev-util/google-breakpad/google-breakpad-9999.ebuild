# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic git-r3

DESCRIPTION="An open-source multi-platform crash reporting system"
HOMEPAGE="http://code.google.com/p/google-breakpad/"
EGIT_REPO_URI="https://chromium.googlesource.com/breakpad/breakpad"

if [[ ${PV} == 9999 ]]; then
	KEYWORDS=""
else
	KEYWORDS="~x86 ~amd64"
fi

LICENSE="BSD"
SLOT="0"
IUSE=""

DEPEND=""

src_unpack() {
	if [[ ${PV} != 9999 ]]; then
		EGIT_COMMIT_DATE="$(date -ud ${PV##*_p} +%s)"
	fi

	git-r3_src_unpack
	git-r3_fetch https://chromium.googlesource.com/linux-syscall-support
	git-r3_checkout https://chromium.googlesource.com/linux-syscall-support \
		"${S}/src/third_party/lss"
}

src_prepare() {
	sed -i -e 's#\(docdir.*share/doc/\).*#\1'${P}'#' Makefile.in || die
	default
}

src_compile() {
	append-flags -fPIC
	default
}

src_install() {
	default
	einstalldocs

	insinto /usr/include/breakpad
	doins src/client/linux/handler/exception_handler.h

	insinto /usr/include/breakpad/common
	doins src/google_breakpad/common/*.h

	insinto /usr/include/breakpad/client/linux/minidump_writer
	doins src/client/linux/minidump_writer/*.h

	insinto /usr/include/breakpad/client/linux/crash_generation
	doins src/client/linux/crash_generation/*.h

	insinto /usr/include/breakpad/client/linux/dump_writer_common
	doins src/client/linux/dump_writer_common/*.h
}
