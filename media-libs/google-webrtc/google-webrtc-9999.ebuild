# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit ninja-utils

DESCRIPTION="Library that provides browsers and mobile applications with Real-Time Communications"
HOMEPAGE="https://webrtc.org/"

if [[ ${PV} == 9999 ]]
then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/open-webrtc-toolkit/owt-deps-webrtc.git"
	EGIT_SUBMODULES=()
	KEYWORDS=""
else
	MY_PN="webrtc"

	OWT_DEPS_WEBRTC_COMMIT="18721dffbee8b3d946ddbccabb8d636de7e8f197"
	DESKTOP_APP_PATCHES_COMMIT="deeea06da209ee10c0d37cb37a8a24d54a3f7758"

	# src:
	BASE_COMMIT="a5f2765fd085a35030d74628e0e3cc9823d44b02"
	BUILD_COMMIT="6c78d6d61b5f8d289732b32669e16b1492bbc110"
	BUILDTOOLS_COMMIT="2c41dfb19abe40908834803b6fed797b0f341fe1"
	TESTING_COMMIT="7de0cb8411d4bb6aa9bf3a219e0ce32986cd635a"
	THIRD_PARTY_COMMIT="c74a355b7874d5931571475fa66c2a7420cea092"
	TOOLS_COMMIT="5ababc8f331d80e195b114e9d6dc91729757fb76"

	# src/buildtools:
	CLANG_FORMAT_COMMIT="96636aa0e9f047f17447f2d45a094d0b59ed7917"
	LIBCXX_COMMIT="d9040c75cfea5928c804ab7c235fed06a63f743a"
	LIBCXXABI_COMMIT="196ba1aaa8ac285d94f4ea8d9836390a45360533"
	LIBUNWIND_COMMIT="43bb9f872232f531bac80093ceb4de61c64b9ab7"

	# src/third_party:
	AOM_COMMIT="c25910f6d213ec5ec45ae53caa5e40bd7ebd218f"
	BORINGSSL_COMMIT="5298ef99bf2b2d77600b3bb74dd572027bf495be"
	BREAKPAD_COMMIT="f32b83eb08e9ee158d3037b2114357187fd45a05"
	CATAPULT_COMMIT="395a627b8ad8b48dc4119fb6d309d29ec5d5fda0"
	COLORAMA_COMMIT="799604a1041e9b3bc5d2789ecbd7e8db2e18e6b8"
	COMPACT_ENC_DET_COMMIT="ba412eaaacd3186085babcd901679a48863c7dd5"
	DEPOT_TOOLS_COMMIT="cd454025b331ae93e83270fcb53db532c6731228"
	FFMPEG_COMMIT="31886e8f39a47a9d7107d4c937bb053dcf5699ce"
	FUZZER_COMMIT="debe7d2d1982e540fbd6bd78604bf001753f9e74"
	FONTCONFIG_COMMIT="452be8125f0e2a18a7dfef469e05d19374d36307"
	FREETYPE2_COMMIT="13c0df80dca59ce2ef3ec125b08c5b6ea485535c"
	GOOGLETEST_COMMIT="10b1902d893ea8cc43c69541d70868f91af3646b"
	GTEST_PARALLEL_COMMIT="df0b4e476f98516cea7d593e5dbb0fca44f6ee7f"
	HARFBUZZ_COMMIT="014e038b2c2fd55e0bffbe5c5adc893c07df187a"
	ICU_COMMIT="13cfcd5874f6c39c34ec57fa5295e7910ae90b8d"
	JSONCPP_COMMIT="645250b6690785be60ab6780ce4b58698d884d11"
	LIBJPEG_TURBO_COMMIT="7e3ad79800a7945fb37173149842b494ab8982b2"
	LIBSRTP_COMMIT="650611720ecc23e0e6b32b0e3100f8b4df91696c"
	LIBVPX_COMMIT="667138e1f0581772de2b990e144bcd6c49a6adb8"
	LIBYUV_COMMIT="6afd9becdf58822b1da6770598d8597c583ccfad"
	LINUX_SYSCALL_SUPPORT_COMMIT="f70e2f1641e280e777edfdad7f73a2cfa38139c7"
	NASM_COMMIT="21eb595319746a669a742d210eaa413c728e7fad"
	OPENH264_COMMIT="6f26bce0b1c4e8ce0e13332f7c0083788def5fdf"
	PATCHED_YASM_COMMIT="720b70524a4424b15fc57e82263568c8ba0496ad"
	USRSCTP_COMMIT="bee946a606752a443bd70bca1cb296527fed706d"

	SRC_URI="
		https://github.com/open-webrtc-toolkit/owt-deps-webrtc/archive/${OWT_DEPS_WEBRTC_COMMIT}.tar.gz -> owt-deps-webrtc-${OWT_DEPS_WEBRTC_COMMIT::7}.tar.gz
		https://github.com/desktop-app/patches/archive/${DESKTOP_APP_PATCHES_COMMIT}.tar.gz -> desktop-app-patches-${DESKTOP_APP_PATCHES_COMMIT::7}.tar.gz

		https://chromium.googlesource.com/chromium/src/base/+archive/${BASE_COMMIT}.tar.gz -> webrtc-base-${BASE_COMMIT::7}.tar.gz
		https://chromium.googlesource.com/chromium/src/build/+archive/${BUILD_COMMIT}.tar.gz -> webrtc-build-${BUILD_COMMIT::7}.tar.gz
		https://chromium.googlesource.com/chromium/src/buildtools/+archive/${BUILDTOOLS_COMMIT}.tar.gz -> webrtc-buildtools-${BUILDTOOLS_COMMIT::7}.tar.gz
		https://chromium.googlesource.com/chromium/src/testing/+archive/${TESTING_COMMIT}.tar.gz -> webrtc-testing-${TESTING_COMMIT::7}.tar.gz
		https://chromium.googlesource.com/chromium/src/third_party/+archive/${THIRD_PARTY_COMMIT}.tar.gz -> webrtc-third_party-${THIRD_PARTY_COMMIT::7}.tar.gz
		https://chromium.googlesource.com/chromium/src/tools/+archive/${TOOLS_COMMIT}.tar.gz -> webrtc-tools-${TOOLS_COMMIT::7}.tar.gz

		https://chromium.googlesource.com/chromium/llvm-project/cfe/tools/clang-format.git/+archive/${CLANG_FORMAT_COMMIT}.tar.gz -> clang-format-${CLANG_FORMAT_COMMIT::7}.tar.gz
		https://chromium.googlesource.com/external/github.com/llvm/llvm-project/libcxx.git/+archive/${LIBCXX_COMMIT}.tar.gz -> libcxx-${LIBCXX_COMMIT::7}.tar.gz
		https://chromium.googlesource.com/external/github.com/llvm/llvm-project/libcxxabi.git/+archive/${LIBCXXABI_COMMIT}.tar.gz -> libcxxabi-${LIBCXXABI_COMMIT::7}.tar.gz
		https://chromium.googlesource.com/external/github.com/llvm/llvm-project/libunwind.git/+archive/${LIBUNWIND_COMMIT}.tar.gz -> libunwind-${LIBUNWIND_COMMIT::7}.tar.gz

		https://aomedia.googlesource.com/aom.git/+archive/${AOM_COMMIT}.tar.gz -> aom-${AOM_COMMIT::7}.tar.gz
		https://boringssl.googlesource.com/boringssl.git/+archive/${BORINGSSL_COMMIT}.tar.gz -> boringssl-${BORINGSSL_COMMIT::7}.tar.gz
		https://chromium.googlesource.com/breakpad/breakpad.git/+archive/${BREAKPAD_COMMIT}.tar.gz -> breakpad-${BREAKPAD_COMMIT::7}.tar.gz
		https://chromium.googlesource.com/catapult.git/+archive/${CATAPULT_COMMIT}.tar.gz -> catapult-${CATAPULT_COMMIT::7}.tar.gz
		https://chromium.googlesource.com/chromium/deps/icu.git/+archive/${ICU_COMMIT}.tar.gz -> icu-${ICU_COMMIT::7}.tar.gz
		https://chromium.googlesource.com/chromium/deps/libjpeg_turbo.git/+archive/${LIBJPEG_TURBO_COMMIT}.tar.gz -> libjpeg_turbo-${LIBJPEG_TURBO_COMMIT::7}.tar.gz
		https://chromium.googlesource.com/chromium/deps/libsrtp.git/+archive/${LIBSRTP_COMMIT}.tar.gz -> libsrtp-${LIBSRTP_COMMIT::7}.tar.gz
		https://chromium.googlesource.com/chromium/deps/nasm.git/+archive/${NASM_COMMIT}.tar.gz -> nasm-${NASM_COMMIT::7}.tar.gz
		https://chromium.googlesource.com/chromium/deps/yasm/patched-yasm.git/+archive/${PATCHED_YASM_COMMIT}.tar.gz -> patched-yasm-${PATCHED_YASM_COMMIT::7}.tar.gz
		https://chromium.googlesource.com/chromium/llvm-project/compiler-rt/lib/fuzzer.git/+archive/${FUZZER_COMMIT}.tar.gz -> fuzzer-${FUZZER_COMMIT::7}.tar.gz
		https://chromium.googlesource.com/chromium/src/third_party/freetype2.git/+archive/${FREETYPE2_COMMIT}.tar.gz -> freetype2-${FREETYPE2_COMMIT::7}.tar.gz
		https://chromium.googlesource.com/chromium/third_party/ffmpeg.git/+archive/${FFMPEG_COMMIT}.tar.gz -> ffmpeg-${FFMPEG_COMMIT::7}.tar.gz
		https://chromium.googlesource.com/chromium/tools/depot_tools.git/+archive/${DEPOT_TOOLS_COMMIT}.tar.gz -> depot_tools-${DEPOT_TOOLS_COMMIT::7}.tar.gz
		https://chromium.googlesource.com/external/colorama.git/+archive/${COLORAMA_COMMIT}.tar.gz -> colorama-${COLORAMA_COMMIT::7}.tar.gz
		https://chromium.googlesource.com/external/fontconfig.git/+archive/${FONTCONFIG_COMMIT}.tar.gz -> fontconfig-${FONTCONFIG_COMMIT::7}.tar.gz
		https://chromium.googlesource.com/external/github.com/cisco/openh264/+archive/${OPENH264_COMMIT}.tar.gz -> openh264-${OPENH264_COMMIT::7}.tar.gz
		https://chromium.googlesource.com/external/github.com/google/compact_enc_det.git/+archive/${COMPACT_ENC_DET_COMMIT}.tar.gz -> compact_enc_det-${COMPACT_ENC_DET_COMMIT::7}.tar.gz
		https://chromium.googlesource.com/external/github.com/google/googletest.git/+archive/${GOOGLETEST_COMMIT}.tar.gz -> googletest-${GOOGLETEST_COMMIT::7}.tar.gz
		https://chromium.googlesource.com/external/github.com/google/gtest-parallel/+archive/${GTEST_PARALLEL_COMMIT}.tar.gz -> gtest-parallel-${GTEST_PARALLEL_COMMIT::7}.tar.gz
		https://chromium.googlesource.com/external/github.com/harfbuzz/harfbuzz.git/+archive/${HARFBUZZ_COMMIT}.tar.gz -> harfbuzz-${HARFBUZZ_COMMIT::7}.tar.gz
		https://chromium.googlesource.com/external/github.com/open-source-parsers/jsoncpp.git/+archive/${JSONCPP_COMMIT}.tar.gz -> jsoncpp-${JSONCPP_COMMIT::7}.tar.gz
		https://chromium.googlesource.com/external/github.com/sctplab/usrsctp/+archive/${USRSCTP_COMMIT}.tar.gz -> usrsctp-${USRSCTP_COMMIT::7}.tar.gz
		https://chromium.googlesource.com/libyuv/libyuv.git/+archive/${LIBYUV_COMMIT}.tar.gz -> libyuv-${LIBYUV_COMMIT::7}.tar.gz
		https://chromium.googlesource.com/linux-syscall-support.git/+archive/${LINUX_SYSCALL_SUPPORT_COMMIT}.tar.gz -> linux-syscall-support-${LINUX_SYSCALL_SUPPORT_COMMIT::7}.tar.gz
		https://chromium.googlesource.com/webm/libvpx.git/+archive/${LIBVPX_COMMIT}.tar.gz -> libvpx-${LIBVPX_COMMIT::7}.tar.gz
	"

	KEYWORDS="~amd64 ~x86"
	S="${WORKDIR}/${MY_PN}"
fi

LICENSE="BSD"
SLOT="0"
IUSE=""

BDEPEND="
	dev-util/gn
"
RDEPEND="
"
DEPEND="${RDEPEND}"

src_unpack() {
	local -A sources=(
		[base]="webrtc-base-${BASE_COMMIT::7}.tar.gz"
		[build]="webrtc-build-${BUILD_COMMIT::7}.tar.gz"
		[buildtools]="webrtc-buildtools-${BUILDTOOLS_COMMIT::7}.tar.gz"
		[testing]="webrtc-testing-${TESTING_COMMIT::7}.tar.gz"
		[third_party]="webrtc-third_party-${THIRD_PARTY_COMMIT::7}.tar.gz"
		[tools]="webrtc-tools-${TOOLS_COMMIT::7}.tar.gz"

		[buildtools/clang_format/script]="clang-format-${CLANG_FORMAT_COMMIT::7}.tar.gz"
		[buildtools/third_party/libc++/trunk]="libcxx-${LIBCXX_COMMIT::7}.tar.gz"
		[buildtools/third_party/libc++abi/trunk]="libcxxabi-${LIBCXXABI_COMMIT::7}.tar.gz"
		[buildtools/third_party/libunwind/trunk]="libunwind-${LIBUNWIND_COMMIT::7}.tar.gz"

		[third_party/boringssl/src]="boringssl-${BORINGSSL_COMMIT::7}.tar.gz"
		[third_party/breakpad/breakpad]="breakpad-${BREAKPAD_COMMIT::7}.tar.gz"
		[third_party/catapult]="catapult-${CATAPULT_COMMIT::7}.tar.gz"
		[third_party/ced/src]="compact_enc_det-${COMPACT_ENC_DET_COMMIT::7}.tar.gz"
		[third_party/colorama/src]="colorama-${COLORAMA_COMMIT::7}.tar.gz"
		[third_party/depot_tools]="depot_tools-${DEPOT_TOOLS_COMMIT::7}.tar.gz"
		[third_party/ffmpeg]="ffmpeg-${FFMPEG_COMMIT::7}.tar.gz"
		[third_party/fontconfig/src]="fontconfig-${FONTCONFIG_COMMIT::7}.tar.gz"
		[third_party/freetype/src]="freetype2-${FREETYPE2_COMMIT::7}.tar.gz"
		[third_party/googletest/src]="googletest-${GOOGLETEST_COMMIT::7}.tar.gz"
		[third_party/gtest-parallel]="gtest-parallel-${GTEST_PARALLEL_COMMIT::7}.tar.gz"
		[third_party/harfbuzz-ng/src]="harfbuzz-${HARFBUZZ_COMMIT::7}.tar.gz"
		[third_party/icu]="icu-${ICU_COMMIT::7}.tar.gz"
		[third_party/jsoncpp/source]="jsoncpp-${JSONCPP_COMMIT::7}.tar.gz"
		[third_party/libFuzzer/src]="fuzzer-${FUZZER_COMMIT::7}.tar.gz"
		[third_party/libaom/source/libaom]="aom-${AOM_COMMIT::7}.tar.gz"
		[third_party/libjpeg_turbo]="libjpeg_turbo-${LIBJPEG_TURBO_COMMIT::7}.tar.gz"
		[third_party/libsrtp]="libsrtp-${LIBSRTP_COMMIT::7}.tar.gz"
		[third_party/libvpx/source/libvpx]="libvpx-${LIBVPX_COMMIT::7}.tar.gz"
		[third_party/libyuv]="libyuv-${LIBYUV_COMMIT::7}.tar.gz"
		[third_party/lss]="linux-syscall-support-${LINUX_SYSCALL_SUPPORT_COMMIT::7}.tar.gz"
		[third_party/nasm]="nasm-${NASM_COMMIT::7}.tar.gz"
		[third_party/openh264/src]="openh264-${OPENH264_COMMIT::7}.tar.gz"
		[third_party/usrsctp/usrsctplib]="usrsctp-${USRSCTP_COMMIT::7}.tar.gz"
		[third_party/yasm/source/patched-yasm]="patched-yasm-${PATCHED_YASM_COMMIT::7}.tar.gz"
	)

	unpack owt-deps-webrtc-${OWT_DEPS_WEBRTC_COMMIT::7}.tar.gz
	mv owt-deps-webrtc-${OWT_DEPS_WEBRTC_COMMIT} ${MY_PN}

	unpack desktop-app-patches-${DESKTOP_APP_PATCHES_COMMIT::7}.tar.gz
	mv patches-${DESKTOP_APP_PATCHES_COMMIT} patches || die

	pushd ${MY_PN} >/dev/null

	for a in ${!sources[@]}
	do
		mkdir -p ${a} || die
		pushd ${a} >/dev/null || die
		unpack "${sources[${a}]}"
		popd >/dev/null
	done

	popd >/dev/null
}

src_prepare() {
	default

	cd "${WORKDIR}"/webrtc || die
	eapply "${WORKDIR}"/patches/webrtc/src.diff

	cd "${WORKDIR}"/webrtc/build || die
	eapply "${WORKDIR}"/patches/webrtc/build.diff

	cd "${WORKDIR}"/webrtc/third_party || die
	eapply "${WORKDIR}"/patches/webrtc/third_party.diff

	cd "${WORKDIR}"/webrtc/third_party/libsrtp || die
	eapply "${WORKDIR}"/patches/webrtc/libsrtp.diff

	cd "${WORKDIR}"/webrtc
	touch build/config/gclient_args.gni || die
	printf "1585847443" >build/util/LASTCHANGE.committime
	echo "LASTCHANGE=6c78d6d61b5f8d289732b32669e16b1492bbc110" >build/util/LASTCHANGE
	sed -i \
		-e 's/#.*overloaded-virtual.*/"-Wno-error=stringop-truncation",/' \
		BUILD.gn || die

	sed -i \
		-e 's/rtc_build_ssl/true/' \
		-e 's/boringssl/boringssl:boringssl/' \
		-e '/boringssl/ s:\+\=:=:' \
		third_party/libsrtp/BUILD.gn
}

src_configure() {
	ArgumentsList=`echo \
		host_cpu=\"x64\" \
		target_os=\"linux\" \
		is_component_build=false \
		is_debug=false \
		is_clang=false \
		symbol_level=2 \
		proprietary_codecs=true \
		use_custom_libcxx=false \
		use_system_libjpeg=false \
		use_rtti=true \
		use_gold=false \
		use_sysroot=false \
		linux_use_bundled_binutils=false \
		enable_dsyms=true \
		rtc_include_tests=false \
		rtc_build_examples=false \
		rtc_build_tools=false \
		rtc_build_opus=false \
		rtc_build_ssl=false \
		rtc_ssl_root=\"/usr/include/openssl\" \
		rtc_ssl_libs=[\"/usr/lib64/libssl.so\",\"/usr/lib64/libcrypto.so\",\"/usr/lib64/libdl.so\",\"/usr/lib64/libpthread.so\"] \
		rtc_builtin_ssl_root_certificates=true \
		rtc_build_ffmpeg=true \
		rtc_opus_root=\"/usr/include/opus\" \
		rtc_enable_protobuf=false`

	gn gen out/Release --args="$ArgumentsList"
}

src_compile() {
	eninja -C out/Release webrtc
}

src_install() {
	DESTDIR="${D}" eninja -C out/Release install
}
