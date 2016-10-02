# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
PLOCALES="de es pl ru uk"

inherit cmake-utils git-r3 l10n

DESCRIPTION="Qt4 Crossplatform Jabber client"
HOMEPAGE="http://www.vacuum-im.org/"
EGIT_REPO_URI="https://github.com/Vacuum-IM/vacuum-im.git"

LICENSE="GPL-3"
SLOT="0/31" # subslot = libvacuumutils soname version
KEYWORDS=""
PLUGINS=( adiummessagestyle annotations autostatus avatars birthdayreminder bitsofbinary bookmarks captchaforms chatstates clientinfo commands compress console dataforms datastreamsmanager emoticons filemessagearchive filestreamsmanager filetransfer gateways inbandstreams iqauth jabbersearch messagearchiver messagecarbons multiuserchat pepmanager privacylists privatestorage recentcontacts registration remotecontrol rosteritemexchange rostersearch servermessagearchive servicediscovery sessionnegotiation shortcutmanager socksstreams urlprocessor vcard xmppuriqueries )
SPELLCHECKER_BACKENDS="aspell +enchant hunspell"
IUSE="${PLUGINS[@]/#/+} ${SPELLCHECKER_BACKENDS} +qt4 qt5 +spell webengine"

REQUIRED_USE="
	^^ ( qt4 qt5 )
	qt4? ( !webengine )
	adiummessagestyle? ( webengine )
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
		filemessagearchive? ( dev-qt/qtsql:5[sqlite] )
		messagearchiver? ( dev-qt/qtsql:5[sqlite] )
		webengine? ( dev-qt/qtwebengine:5 )
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

DOCS=( AUTHORS CHANGELOG README TRANSLATORS )

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
	local mycmakeargs=(
		-DINSTALL_LIB_DIR="$(get_libdir)"
		-DINSTALL_SDK=ON
		-DLANGS="$(l10n_get_locales)"
		-DINSTALL_DOCS=OFF
		-DFORCE_BUNDLED_MINIZIP=OFF
		-DPLUGIN_statistics=OFF
	)

	if use qt5; then
		mycmakeargs+=( -DNO_WEBENGINE=$(usex webengine NO YES) )
	fi

	for x in ${PLUGINS}; do
		mycmakeargs+=( -DPLUGIN_${x}=$(usex $x) )
	done
	mycmakeargs+=( -DPLUGIN_spellchecker=$(usex spell) )

	for i in ${SPELLCHECKER_BACKENDS//+/}; do
		use "${i}" && mycmakeargs+=( -DSPELLCHECKER_BACKEND="${i}" )
	done

	cmake-utils_src_configure
}
