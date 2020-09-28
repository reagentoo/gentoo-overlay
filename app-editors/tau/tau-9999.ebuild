# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CRATES="
adler32-1.0.4
aho-corasick-0.7.10
arc-swap-0.4.5
arrayref-0.3.6
arrayvec-0.5.1
atk-0.8.0
atk-sys-0.9.1
atty-0.2.14
autocfg-1.0.0
backtrace-0.3.46
backtrace-sys-0.1.35
base64-0.10.1
base64-0.11.0
bincode-1.2.1
bitflags-1.2.1
blake2b_simd-0.5.10
byteorder-1.3.4
bytes-0.4.12
cairo-rs-0.8.1
cairo-sys-rs-0.9.2
cc-1.0.50
cfg-if-0.1.10
chrono-0.4.11
cloudabi-0.0.3
constant_time_eq-0.1.5
crc32fast-1.2.0
crossbeam-channel-0.4.2
crossbeam-deque-0.7.3
crossbeam-epoch-0.8.2
crossbeam-queue-0.1.2
crossbeam-queue-0.2.1
crossbeam-utils-0.6.6
crossbeam-utils-0.7.2
dirs-2.0.2
dirs-sys-0.3.4
env_logger-0.7.1
flate2-1.0.14
fnv-1.0.6
fuchsia-zircon-0.3.3
fuchsia-zircon-sys-0.3.3
futures-0.1.29
futures-channel-0.3.4
futures-core-0.3.4
futures-executor-0.3.4
futures-io-0.3.4
futures-macro-0.3.4
futures-task-0.3.4
futures-util-0.3.4
gdk-0.12.1
gdk-pixbuf-0.8.0
gdk-pixbuf-sys-0.9.1
gdk-sys-0.9.1
getrandom-0.1.14
gettext-rs-0.4.4
gettext-sys-0.19.9
gio-0.8.1
gio-sys-0.9.1
glib-0.9.3
glib-sys-0.9.1
gobject-sys-0.9.1
gtk-0.8.1
gtk-sys-0.9.2
hermit-abi-0.1.8
human-panic-1.0.3
humantime-1.3.0
iovec-0.1.4
itoa-0.4.5
kernel32-sys-0.2.2
lazy_static-1.4.0
lazycell-1.2.1
libc-0.2.68
libhandy-0.5.0
libhandy-sys-0.5.0
line-wrap-0.1.1
linked-hash-map-0.5.2
locale_config-0.2.3
lock_api-0.3.3
log-0.4.8
maybe-uninit-2.0.0
memchr-2.3.3
memoffset-0.5.4
miniz_oxide-0.3.6
mio-0.6.21
mio-named-pipes-0.1.6
mio-uds-0.6.7
miow-0.2.1
miow-0.3.3
net2-0.2.33
num-integer-0.1.42
num-traits-0.2.11
num_cpus-1.12.0
os_type-2.2.0
pango-0.8.0
pango-sys-0.9.1
pangocairo-0.9.0
pangocairo-sys-0.10.1
parking_lot-0.10.0
parking_lot-0.9.0
parking_lot_core-0.6.2
parking_lot_core-0.7.0
pin-utils-0.1.0-alpha.4
pkg-config-0.3.17
plist-0.4.2
ppv-lite86-0.2.6
proc-macro-hack-0.5.14
proc-macro-nested-0.1.4
proc-macro2-1.0.9
quick-error-1.2.3
quote-1.0.3
rand-0.7.3
rand_chacha-0.2.2
rand_core-0.5.1
rand_hc-0.2.0
redox_syscall-0.1.56
redox_users-0.3.4
regex-1.3.6
regex-syntax-0.6.17
rust-argon2-0.7.0
rustc-demangle-0.1.16
rustc_version-0.2.3
ryu-1.0.3
safemem-0.3.3
same-file-1.0.6
scopeguard-1.1.0
semver-0.9.0
semver-parser-0.7.0
serde-1.0.105
serde_derive-1.0.105
serde_json-1.0.50
signal-hook-registry-1.2.0
slab-0.4.2
smallvec-0.6.13
smallvec-1.2.0
socket2-0.3.11
syn-1.0.17
syntect-3.3.0
termcolor-1.1.0
thread_local-1.0.1
time-0.1.42
tokio-0.1.22
tokio-codec-0.1.2
tokio-current-thread-0.1.7
tokio-executor-0.1.10
tokio-fs-0.1.7
tokio-io-0.1.13
tokio-process-0.2.5
tokio-reactor-0.1.12
tokio-signal-0.2.9
tokio-sync-0.1.8
tokio-tcp-0.1.4
tokio-threadpool-0.1.18
tokio-timer-0.2.13
tokio-udp-0.1.6
tokio-uds-0.2.6
toml-0.5.6
unicode-segmentation-1.6.0
unicode-xid-0.2.0
uuid-0.8.1
vte-rs-0.3.0
vte-sys-0.2.2
walkdir-2.3.1
wasi-0.9.0+wasi-snapshot-preview1
winapi-0.2.8
winapi-0.3.8
winapi-build-0.1.1
winapi-i686-pc-windows-gnu-0.4.0
winapi-util-0.1.3
winapi-x86_64-pc-windows-gnu-0.4.0
ws2_32-sys-0.2.1
xml-rs-0.8.0
xrl-0.0.8
yaml-rust-0.4.3
"

inherit cargo gnome2-utils meson xdg

DESCRIPTION="GTK frontend for the Xi text editor, written in Rust"
HOMEPAGE="https://gitlab.gnome.org/World/Tau"

if [[ ${PV} == 9999 ]]
then
	inherit git-r3
	EGIT_REPO_URI="https://gitlab.gnome.org/World/Tau.git"
	RESTRICT="network-sandbox"
	KEYWORDS=""
else
	SRC_URI="https://gitlab.gnome.org/World/Tau/uploads/b5f24cd692ec0c2a2c2be460fffaf505/${P}.tar.xz
		$(cargo_crate_uris ${CRATES})"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="MIT"
SLOT="0"
IUSE=""

RDEPEND="
	gui-libs/libhandy
	x11-libs/vte
"
DEPEND="${RDEPEND}"
BDEPEND=""

src_configure() {
	meson_src_configure
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

pkg_postinst() {
	gnome2_schemas_update
	xdg_pkg_postrm
}

pkg_postrm() {
	gnome2_schemas_update
	xdg_pkg_postrm
}
