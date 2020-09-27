# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CRATES="
addr2line-0.13.0
adler-0.2.3
anyhow-1.0.32
arrayref-0.3.6
arrayvec-0.5.1
atk-0.9.0
atk-sys-0.10.0
autocfg-1.0.1
backtrace-0.3.50
base64-0.12.3
bitflags-1.2.1
blake2b_simd-0.5.10
block-buffer-0.9.0
cairo-rs-0.9.1
cairo-sys-rs-0.10.0
cc-1.0.60
cfg-if-0.1.10
constant_time_eq-0.1.5
core-foundation-0.9.1
core-foundation-sys-0.8.1
cpuid-bool-0.1.2
crossbeam-channel-0.4.4
crossbeam-utils-0.7.2
digest-0.9.0
directories-3.0.1
dirs-sys-0.3.5
either-1.6.1
failure-0.1.8
failure_derive-0.1.8
futures-0.3.5
futures-channel-0.3.5
futures-core-0.3.5
futures-executor-0.3.5
futures-io-0.3.5
futures-macro-0.3.5
futures-sink-0.3.5
futures-task-0.3.5
futures-util-0.3.5
gdk-0.13.2
gdk-pixbuf-0.9.0
gdk-pixbuf-sys-0.10.0
gdk-sys-0.10.0
generic-array-0.14.4
getrandom-0.1.15
gimli-0.22.0
gio-0.9.1
gio-sys-0.10.1
glib-0.10.2
glib-macros-0.10.1
glib-sys-0.10.1
gobject-sys-0.10.0
gstreamer-0.16.3
gstreamer-base-0.16.3
gstreamer-base-sys-0.9.1
gstreamer-player-0.16.3
gstreamer-player-sys-0.9.1
gstreamer-sys-0.9.1
gstreamer-video-0.16.3
gstreamer-video-sys-0.9.1
gtk-0.9.2
gtk-sys-0.10.0
heck-0.3.1
itertools-0.9.0
itoa-0.4.6
lazy_static-1.4.0
libc-0.2.77
maybe-uninit-2.0.0
memchr-2.3.3
miniz_oxide-0.4.2
muldiv-0.2.1
num-integer-0.1.43
num-rational-0.3.0
num-traits-0.2.12
object-0.20.0
once_cell-1.4.1
opaque-debug-0.3.0
pango-0.9.1
pango-sys-0.10.0
paste-1.0.1
pin-project-0.4.23
pin-project-internal-0.4.23
pin-utils-0.1.0
pkg-config-0.3.18
pretty-hex-0.2.1
proc-macro-crate-0.1.5
proc-macro-error-1.0.4
proc-macro-error-attr-1.0.4
proc-macro-hack-0.5.18
proc-macro-nested-0.1.6
proc-macro2-1.0.21
quote-1.0.7
redox_syscall-0.1.57
redox_users-0.3.5
rust-argon2-0.8.2
rustc-demangle-0.1.16
ryu-1.0.5
serde-1.0.116
serde_derive-1.0.116
serde_json-1.0.57
sha2-0.9.1
slab-0.4.2
strum-0.18.0
strum_macros-0.18.0
syn-1.0.41
synstructure-0.12.4
system-deps-1.3.2
thiserror-1.0.20
thiserror-impl-1.0.20
toml-0.5.6
typenum-1.12.0
unicode-segmentation-1.6.0
unicode-xid-0.2.1
version-compare-0.0.10
version_check-0.9.2
wasi-0.9.0+wasi-snapshot-preview1
winapi-0.3.9
winapi-i686-pc-windows-gnu-0.4.0
winapi-x86_64-pc-windows-gnu-0.4.0
"

inherit cargo meson xdg

DESCRIPTION="Cross-platform media player based on GStreamer and GTK+"
HOMEPAGE="https://github.com/philn/glide"

if [[ ${PV} == 9999 ]]
then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/philn/${PN}.git"
	RESTRICT="network-sandbox"
	KEYWORDS=""
else
	SRC_URI="https://github.com/philn/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz
		$(cargo_crate_uris ${CRATES})"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="MIT"
SLOT="0"
IUSE=""

RDEPEND="
	media-libs/gst-plugins-bad
	media-libs/gst-plugins-base
	media-plugins/gst-plugins-gtk
"
DEPEND="${RDEPEND}"

src_prepare() {
	default

	sed -i -e '/self_update/d' \
		Cargo.toml || die
	sed -i -e 's/\(Icon=.*\)\.svg/\1/' \
		data/net.baseart.Glide.desktop || die
	sed -i -e 's:/appdata:/metainfo:' \
		meson.build || die
	sed -i -e '/export.*CARGO_HOME/d' \
		scripts/cargo.sh || die
}

src_compile() {
	export CARGO_HOME="${ECARGO_HOME}"

	meson_src_compile
}

src_install() {
	meson_src_install
}

src_test() {
	meson_src_test
}
