# Copyright 2009-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 )

CHECKREQS_DISK_BUILD="500M"
CHECKREQS_MEMORY="400M"

inherit check-reqs ninja-utils python-any-r1 toolchain-funcs

DESCRIPTION="Library that provides browsers and mobile applications with Real-Time Communications"
HOMEPAGE="https://webrtc.org/"
MY_PN="webrtc"
OWT_COMMIT="18721dffbee8b3d946ddbccabb8d636de7e8f197"
SRC_URI="
	https://commondatastorage.googleapis.com/chromium-browser-official/chromium-${PV}.tar.xz
	https://github.com/open-webrtc-toolkit/owt-deps-webrtc/archive/${OWT_COMMIT}.tar.gz -> owt-deps-webrtc-${OWT_COMMIT::7}.tar.gz
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="absl c++17 +libevent owt +proprietary-codecs protobuf x265"
REQUIRED_USE="
	!owt? ( !x265 )
"

COMMON_DEPEND="
	dev-libs/openssl:0=
	media-libs/libjpeg-turbo:=
	>=media-libs/libvpx-1.8.2:=
	>=media-libs/openh264-1.6.0:=
	>=media-libs/opus-1.3.1:=
	>=media-video/ffmpeg-4:=
	sys-libs/zlib:=[minizip]
	libevent? ( dev-libs/libevent:= )
	x265? ( media-libs/x265 )
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
	local chromium_extraction_list=(
		{base,build,buildtools,testing,tools}

		third_party/abseil-cpp
		third_party/googletest/BUILD.gn
		third_party/harfbuzz-ng/BUILD.gn
		third_party/jsoncpp/BUILD.gn
		third_party/lib{aom,srtp,yuv}
		third_party/nasm
		third_party/pffft
		third_party/rnnoise
		third_party/usrsctp
		third_party/BUILD.gn

		third_party/ffmpeg/BUILD.gn
		third_party/harfbuzz-ng/harfbuzz.gni
		third_party/libjpeg.gni
		third_party/libvpx/BUILD.gn
		third_party/openh264/BUILD.gn
		third_party/opus/BUILD.gn
	)

	tar xf "${DISTDIR}/chromium-${PV}.tar.xz" \
		${chromium_extraction_list[@]/#/"chromium-${PV}/"} || die

	if use owt
	then
		tar xf "${DISTDIR}/owt-deps-webrtc-${OWT_COMMIT::7}.tar.gz" || die
		mv "owt-deps-webrtc-${OWT_COMMIT}" "${MY_PN}" || die
	else
		mv "chromium-${PV}/third_party/webrtc" "${MY_PN}" || die
	fi

	mv "chromium-${PV}"/* "${MY_PN}" || die
	rmdir "chromium-${PV}" || die
}

src_prepare() {
	default

	echo >build/config/gclient_args.gni

	sed -i \
		-e '/complete_static_lib/d' \
		-e 's/rtc_static_library/rtc_shared_library/' \
		BUILD.gn || die

	# Make visible all symbols.
	sed -i -e 's/symbol_visibility_hidden/symbol_visibility_default/' \
		build/config/BUILDCONFIG.gn || die

	# This rx enable custom symbol exports by the RTC_EXPORT macros.
	# But it is not enough for applications which uses libwebrtc.so.
	# sed -i -e '/rtc_enable_symbol_export/s:false:true:' webrtc.gni

	# Use external ssl lib.
	sed -i -e '/include_dirs.*rtc_ssl_root/a libs = ["crypto","ssl"]' \
		rtc_base/BUILD.gn || die
	sed -i -e '/boringssl/d' \
		third_party/libsrtp/BUILD.gn || die
	sed -i \
		-e '1 i\import("//webrtc.gni")' \
		-e 's#deps.*boringssl.*#configs += [ "//rtc_base:external_ssl_library" ]#' \
		third_party/usrsctp/BUILD.gn || die

	local mycflags=(
		-Wno-address
		-Wno-array-bounds
	)

	local mycflags_str=\"$(echo ${mycflags[*]} | sed 's/[[:space:]]\+/","/g')\"
	local mycflags_rx="s:\(cflags[ ].*\)\[\]:\1\[${mycflags_str}\]:"

	# Prevent -W* QA Notice.
	sed -i -e "/^config.*default_warnings/,/^}/ ${mycflags_rx}" \
		build/config/compiler/BUILD.gn || die

	# Fix compilation using GCC>=10 and Clang>=10.0.1.
	sed -i -e '/#define.*_H_$/a #include <cstddef>' \
		modules/audio_processing/aec3/clockdrift_detector.h || die
	sed -i -e '/#define.*_H_$/a #include <stdint.h>' \
		call/rtx_receive_stream.h \
		common_video/h264/pps_parser.h \
		common_video/h264/prefix_parser.h \
		common_video/h264/sps_parser.h \
		common_video/h265/h265_common.h \
		common_video/h265/h265_pps_parser.h \
		modules/congestion_controller/rtp/transport_feedback_demuxer.h \
		modules/rtp_rtcp/source/receive_statistics_impl.h || die

	# Don't use third_party headers.
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
			build/config/compiler/BUILD.gn || die
	fi

	if use c++17
	then
		sed -i -e '/cflags_cc.*standard_prefix/ s:14:17:' \
			build/config/compiler/BUILD.gn || die

		sed -i -e '/#define.*_H_$/a #include <memory>' \
			modules/audio_processing/aec3/reverb_model_estimator.h || die
	fi

	if use x265
	then
		sed -i -e '/rtc_use_h265/ s:false:true:' \
			build_overrides/build.gni || die
	fi

	if use owt
	then
		sed -i -e 's/build_with_owt/false/' \
			BUILD.gn || die

		sed -i \
			-e '/import.*build_overrides.*ssl\.gni/d' \
			-e 's/owt_openssl_header_root/""/' \
			-e 's/owt_use_openssl/build_with_mozilla/' \
			webrtc.gni || die

		cat third_party/webrtc/build_overrides/build.gni \
			| sed '/^declare_args.*{/,/^}/!d' \
			>>build_overrides/build.gni || die
	fi
}

src_configure() {
	# Make sure the build system will use the right tools, bug #340795.
	tc-export AR CC CXX NM

	local mygnlibs=(
		ffmpeg
		freetype
		harfbuzz-ng
		lib{event,jpeg,vpx}
		openh264
		opus
	)

	einfo "Replacing gn files..."
	set -- build/linux/unbundle/replace_gn_files.py \
		--system-libraries "${mygnlibs[@]}"
	echo "$@"
	"$@" || die

	local mygnargs=(
		custom_toolchain=\"//build/toolchain/linux/unbundle:default\"

		# Disable fatal linker warnings, bug 506268.
		fatal_linker_warnings=false
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

		rtc_build_ssl=false
		rtc_build_tools=false

		# TODO: unbundle third_party/usrsctp
		# rtc_build_usrsctp=true

		rtc_builtin_ssl_root_certificates=true
		rtc_enable_libevent=$(usex libevent true false)
		rtc_enable_protobuf=$(usex protobuf true false)

		# Unconditionally required by rtc_pc_base.
		rtc_enable_sctp=true

		rtc_include_tests=false
		rtc_jsoncpp_root=\"${EPREFIX}/usr/include/jsoncpp\"
		rtc_libvpx_build_vp9=true
		rtc_ssl_root=\"${EPREFIX}/usr/include/openssl\"
		symbol_level=0
		target_cpu=\"$(echo $(tc-arch) | sed 's/amd/x/')\"
		target_os=\"linux\"

		# Make sure that -Werror doesn't get added to CFLAGS by the build system.
		# Depending on GCC version the warnings are different and we don't want
		# the build to fail because of that.
		treat_warnings_as_errors=false

		use_custom_libcxx=false
		use_gold=false
		use_lld=false

		# Enable rtti to avoid "undefined reference typeinfo"
		use_rtti=true

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

	local include_install_dir="${D}/usr/include/${MY_PN}"
	mkdir -p "${include_install_dir}" || die

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
		pc
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

	webrtc_hdr_list+=( "common_types.h" )
	rsync --relative ${webrtc_hdr_list[@]} "${include_install_dir}" || die

	if use absl
	then
		pushd "third_party/abseil-cpp" >/dev/null || die
		local absl_hdr_list=$(find absl -name "*.h" -o -name "*.inc")
		rsync --relative ${absl_hdr_list[@]} "${include_install_dir}" || die
		popd >/dev/null
	fi
}
