# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
LANGS="de pl ru uk"

inherit cmake-utils git-r3

DESCRIPTION="Qt4 Crossplatform Jabber client"
HOMEPAGE="http://www.vacuum-im.org/"
EGIT_REPO_URI="https://github.com/Vacuum-IM/vacuum-im.git"

LICENSE="GPL-3"
SLOT="0/31" # subslot = libvacuumutils soname version
KEYWORDS=""
PLUGINS=" adiummessagestyle annotations autostatus avatars birthdayreminder bitsofbinary bookmarks captchaforms chatstates clientinfo commands compress console dataforms datastreamsmanager emoticons filemessagearchive filestreamsmanager filetransfer gateways inbandstreams iqauth jabbersearch messagearchiver messagecarbons multiuserchat pepmanager privacylists privatestorage recentcontacts registration remotecontrol rosteritemexchange rostersearch servermessagearchive servicediscovery sessionnegotiation shortcutmanager socksstreams urlprocessor vcard xmppuriqueries"
SPELLCHECKER_BACKENDS="aspell +enchant hunspell"
IUSE="${PLUGINS// / +} ${SPELLCHECKER_BACKENDS} +qt4 qt5 +spell vcs-revision"
for x in ${LANGS}; do
	IUSE+=" linguas_${x}"
done

REQUIRED_USE="
	annotations? ( privatestorage )
	avatars? ( vcard )
	birthdayreminder? ( vcard )
	bookmarks? ( privatestorage )
	captchaforms? ( dataforms )
	commands? ( dataforms )
	datastreamsmanager? ( dataforms )
	filemessagearchive? ( messagearchiver )
	filestreamsmanager? ( datastreamsmanager )
	filetransfer? ( filestreamsmanager datastreamsmanager )
	messagecarbons? ( servicediscovery )
	pepmanager? ( servicediscovery )
	recentcontacts? ( privatestorage )
	registration? ( dataforms )
	remotecontrol? ( commands dataforms )
	servermessagearchive? ( messagearchiver )
	sessionnegotiation? ( dataforms )
	spell? ( ^^ ( ${SPELLCHECKER_BACKENDS//+/} ) )
	^^ ( qt4 qt5 )
"

RDEPEND="
	qt4? (
		>=dev-qt/qtcore-4.8:4[ssl]
		>=dev-qt/qtgui-4.8:4
		dev-qt/qtlockedfile[qt4(+)]
		adiummessagestyle? ( >=dev-qt/qtwebkit-4.8:4 )
		filemessagearchive? ( >=dev-qt/qtsql-4.8:4[sqlite] )
		messagearchiver? ( >=dev-qt/qtsql-4.8:4[sqlite] )
	)
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtlockedfile[qt5(+)]
		dev-qt/qtmultimedia:5
		dev-qt/qtnetwork:5[ssl]
		dev-qt/qtxml:5
		adiummessagestyle? ( dev-qt/qtwebengine:5 )
		filemessagearchive? ( dev-qt/qtsql:5[sqlite] )
		messagearchiver? ( dev-qt/qtsql:5[sqlite] )
	)
	spell? (
		aspell? ( app-text/aspell )
		enchant? ( app-text/enchant )
		hunspell? ( app-text/hunspell )
	)
	net-dns/libidn
	x11-libs/libXScrnSaver
	sys-libs/zlib[minizip]
	!net-im/vacuum-spellchecker
"
DEPEND="${RDEPEND}"

DOCS="AUTHORS CHANGELOG README TRANSLATORS"

src_unpack() {
	if use qt5; then
		EGIT_BRANCH="dev_qt5"
	fi
	git-r3_src_unpack
}

src_prepare() {
	# Force usage of system libraries
	rm -rf src/thirdparty/{idn,hunspell,minizip,zlib}

	cmake-utils_src_prepare
}

src_configure() {
	local langs="none;" x
	for x in ${LANGS}; do
		use linguas_${x} && langs+="${x};"
	done

	local mycmakeargs=(
		-DINSTALL_LIB_DIR="$(get_libdir)"
		-DINSTALL_SDK=ON
		-DLANGS="${langs}"
		-DINSTALL_DOCS=OFF
		-DFORCE_BUNDLED_MINIZIP=OFF
		-DPLUGIN_statistics=OFF
	)

	for x in ${PLUGINS}; do
		mycmakeargs+=( "$(cmake-utils_use ${x} PLUGIN_${x})" )
	done
	mycmakeargs+=( "$(cmake-utils_use spell PLUGIN_spellchecker)" )

	for i in ${SPELLCHECKER_BACKENDS//+/}; do
		use "${i}" && mycmakeargs+=( -DSPELLCHECKER_BACKEND="${i}" )
	done

	if use vcs-revision; then
		subversion_wc_info # eclass is broken
		mycmakeargs+=( -DVER_STRING="${ESVN_WC_REVISION}" )
	fi

	cmake-utils_src_configure
}
