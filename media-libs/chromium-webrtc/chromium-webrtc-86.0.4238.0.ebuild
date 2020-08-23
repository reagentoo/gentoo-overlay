# Copyright 2009-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6..8} )

inherit ninja-utils python-any-r1 toolchain-funcs

DESCRIPTION="Library that provides browsers and mobile applications with Real-Time Communications"
HOMEPAGE="https://webrtc.org/"
MY_PN="webrtc"
SRC_URI="https://commondatastorage.googleapis.com/chromium-browser-official/chromium-${PV}.tar.xz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="libevent +proprietary-codecs protobuf tcmalloc"

COMMON_DEPEND="
	media-libs/libjpeg-turbo:=
	>=media-libs/libvpx-1.8.2:=
	>=media-libs/openh264-1.6.0:=
	>=media-libs/opus-1.3.1:=
	>=media-video/ffmpeg-4:=
	sys-libs/zlib:=[minizip]
	libevent? ( dev-libs/libevent:= )
"
RDEPEND="${COMMON_DEPEND}"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	>=dev-util/gn-0.1807
	>=dev-util/ninja-1.7.2
	virtual/pkgconfig
"

S="${WORKDIR}/${MY_PN}"

src_unpack() {
	default

	ln -s "${WORKDIR}/chromium-${PV}/third_party/webrtc" "${MY_PN}"
	ln -s "${WORKDIR}/chromium-${PV}/"{base,build,buildtools} "${MY_PN}"
	ln -s "${WORKDIR}/chromium-${PV}/"{testing,third_party,tools} "${MY_PN}"
}

src_prepare() {
	default

	echo >build/config/gclient_args.gni

	sed -i \
		-e '/complete_static_lib/d' \
		-e 's/rtc_static_library/rtc_shared_library/' \
		BUILD.gn || die

	sed -i -e 's/symbol_visibility_hidden/symbol_visibility_default/' \
		build/config/BUILDCONFIG.gn || die

	local mycflags_rx='s:\(cflags[ ].*\)\[\]:\1\["-Wno-address"\]:'

	# Prevent -Waddress related QA Notice
	sed -i -e "/^config.*default_warnings/,/^}/ ${mycflags_rx}" \
		build/config/compiler/BUILD.gn || die

	sed -i -e '/#include.*opus/ s:"\(.*\)":<opus/\1>:' \
		modules/audio_coding/codecs/opus/opus_inst.h || die

	sed -i -e '/#include/ s:"third_party/ffmpeg/\(.*\)":<\1>:' \
		modules/video_coding/codecs/h264/h264_color_space.h \
		modules/video_coding/codecs/h264/h264_decoder_impl.cc \
		modules/video_coding/codecs/h264/h264_decoder_impl.h || die

	if tc-is-clang
	then
		# Supress messages about unknown warning options.
		sed -i -e 's/if.*current_toolchain.*host_toolchain.*{/if (false) {/' \
			build/config/compiler/BUILD.gn
	fi
}

src_configure() {
	# Make sure the build system will use the right tools, bug #340795.
	tc-export AR CC CXX NM

	local mygnsyslibs=(
		ffmpeg
		fontconfig
		freetype
		harfbuzz-ng
		lib{drm,event,jpeg,png,vpx,webp,xml,xslt}
		openh264
		opus
		re2
		snappy
		zlib
	)

	local mygnargs=(
		custom_toolchain=\"//build/toolchain/linux/unbundle:default\"

		# Disable fatal linker warnings, bug 506268.
		fatal_linker_warnings=false

		# TODO: introduce "component-build" USE similar in www-client/chromium
		is_component_build=false

		# GN needs explicit config for Debug/Release as opposed to inferring it
		# from build directory.
		is_debug=false

		proprietary_codecs=$(usex proprietary-codecs true false)
		rtc_build_examples=false
		rtc_build_json=false

		# Using build/linux/unbundle/libevent.gn
		# rtc_build_libevent=true

		# libsrtp can't be unbundled due missing srtp_priv.h in net-libs/libsrtp
		# rtc_build_libsrtp=true

		# Using build/linux/unbundle/libvpx.gn
		# rtc_build_libvpx=true

		# Using build/linux/unbundle/opus.gn
		# rtc_build_opus=true

		# TODO: unbundle third_party/boringssl
		# rtc_build_ssl=true

		rtc_build_tools=false

		# TODO: unbundle third_party/usrsctp
		# rtc_build_usrsctp=true

		rtc_builtin_ssl_root_certificates=true
		rtc_enable_libevent=$(usex libevent true false)
		rtc_enable_protobuf=$(usex protobuf true false)

		# Unconditionally required by rtc_pc_base.
		rtc_enable_sctp=true

		rtc_include_tests=false
		rtc_jsoncpp_root=\"/usr/include/jsoncpp\"
		rtc_libvpx_build_vp9=true
		rtc_ssl_root=\"/usr/include/openssl\"
		symbol_level=0
		target_cpu=\"$(echo $(tc-arch) | sed 's/amd/x/')\"
		target_os=\"linux\"

		# Make sure that -Werror doesn't get added to CFLAGS by the build system.
		# Depending on GCC version the warnings are different and we don't want
		# the build to fail because of that.
		treat_warnings_as_errors=false

		use_allocator=$(usex tcmalloc \"tcmalloc\" \"none\")
		use_custom_libcxx=false
		use_gold=false
		use_lld=false
		use_sysroot=false
	)

	if tc-is-clang
	then
		mygnargs+=( is_clang=true clang_use_chrome_plugins=false )
	else
		mygnargs+=( is_clang=false )
	fi

	# Define a custom toolchain for GN
	if tc-is-cross-compiler
	then
		tc-export BUILD_{AR,CC,CXX,NM}
		mygnargs+=( host_toolchain=\"//build/toolchain/linux/unbundle:host\" )
	else
		mygnargs+=( host_toolchain=\"//build/toolchain/linux/unbundle:default\" )
	fi

	einfo "Replacing gn files..."
	set -- build/linux/unbundle/replace_gn_files.py \
		--system-libraries "${mygnsyslibs[@]}"
	echo "$@"
	"$@" || die

	einfo "Configuring WebRTC..."
	set -- gn gen --args="${mygnargs[*]}" "${S}_build"
	echo "$@"
	"$@" || die
}

src_compile() {
	eninja -C "${S}_build" webrtc
}

src_install() {
	dolib.so "${S}_build/libwebrtc.so"

	local include_root_dir="${D}/usr/include/${MY_PN}"
	mkdir -p "${include_root_dir}"

	local webrtc_dirs=(
		api
		audio
		base
		call
		common_audio
		common_video
		logging
		media
		modules
		p2p
		rtc_base
		rtc_tools
		system_wrappers
		video
	)

	local webrtc_hdr_list=$(
		find ${webrtc_dirs[@]} -name "*.h" | sed \
			-e "/\/android/d" \
			-e "/\/ios/d" \
			-e "/\/mac/d" \
			-e "/\/test/d" \
			-e "/\/win/d"
	)

	rsync --relative ${webrtc_hdr_list[@]} "${include_root_dir}"

	pushd "third_party/abseil-cpp" >/dev/null || die
	local absl_hdr_list=$(find absl -name "*.h")
	rsync --relative ${absl_hdr_list[@]} "${include_root_dir}"
	popd >/dev/null
}
