# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CRATES="
MacTypes-sys-1.3.0
adler32-1.0.3
arrayref-0.3.5
arrayvec-0.4.10
atk-sys-0.7.0
autocfg-0.1.1
backtrace-0.3.13
backtrace-sys-0.1.28
base64-0.10.0
base64-0.9.3
bitflags-1.0.4
block-buffer-0.3.3
build_const-0.2.1
byte-tools-0.2.0
byteorder-1.2.7
bytes-0.4.11
cairo-rs-0.5.0
cairo-sys-rs-0.7.0
cc-1.0.28
cfg-if-0.1.6
cloudabi-0.0.3
core-foundation-0.5.1
core-foundation-sys-0.5.1
crc-1.8.1
crc32fast-1.1.2
crossbeam-channel-0.2.6
crossbeam-channel-0.3.6
crossbeam-deque-0.6.3
crossbeam-epoch-0.6.1
crossbeam-epoch-0.7.0
crossbeam-utils-0.5.0
crossbeam-utils-0.6.3
digest-0.7.6
dirs-0.3.1
dtoa-0.4.3
encoding_rs-0.8.14
failure-0.1.5
failure_derive-0.1.5
fake-simd-0.1.2
filetime-0.2.4
flate2-1.0.6
fnv-1.0.6
foreign-types-0.3.2
foreign-types-shared-0.1.1
fragile-0.3.0
fuchsia-zircon-0.3.3
fuchsia-zircon-sys-0.3.3
futures-0.1.25
futures-cpupool-0.1.8
gdk-0.9.0
gdk-pixbuf-0.5.0
gdk-pixbuf-sys-0.7.0
gdk-sys-0.7.0
generic-array-0.9.0
gio-0.5.1
gio-sys-0.7.0
glib-0.6.1
glib-sys-0.7.0
glide-0.5.6
gobject-sys-0.7.0
gstreamer-0.12.2
gstreamer-base-0.12.2
gstreamer-base-sys-0.6.2
gstreamer-player-0.12.2
gstreamer-player-sys-0.6.2
gstreamer-sys-0.6.2
gstreamer-video-0.12.2
gstreamer-video-sys-0.6.2
gtk-0.5.0
gtk-sys-0.7.0
h2-0.1.14
http-0.1.14
httparse-1.3.3
hyper-0.12.20
hyper-old-types-0.11.0
hyper-tls-0.3.1
idna-0.1.5
indexmap-1.0.2
iovec-0.1.2
itoa-0.4.3
kernel32-sys-0.2.2
language-tags-0.2.2
lazy_static-1.2.0
lazycell-1.2.1
libc-0.2.46
libflate-0.1.19
lock_api-0.1.5
log-0.4.6
matches-0.1.8
memoffset-0.2.1
mime-0.3.13
mime_guess-2.0.0-alpha.6
miniz-sys-0.1.11
miniz_oxide-0.2.0
miniz_oxide_c_api-0.2.0
mio-0.6.16
miow-0.2.1
muldiv-0.2.0
native-tls-0.2.2
net2-0.2.33
nodrop-0.1.13
num-integer-0.1.39
num-rational-0.2.1
num-traits-0.2.6
num_cpus-1.9.0
ole32-sys-0.2.0
openssl-0.10.16
openssl-probe-0.1.2
openssl-sys-0.9.40
owning_ref-0.4.0
pango-0.5.0
pango-sys-0.7.0
parking_lot-0.6.4
parking_lot-0.7.1
parking_lot_core-0.3.1
parking_lot_core-0.4.0
pbr-1.0.1
percent-encoding-1.0.1
phf-0.7.24
phf_codegen-0.7.24
phf_generator-0.7.24
phf_shared-0.7.24
pkg-config-0.3.14
proc-macro2-0.4.24
quote-0.6.10
rand-0.4.5
rand-0.5.5
rand-0.6.4
rand_chacha-0.1.1
rand_core-0.2.2
rand_core-0.3.0
rand_hc-0.1.0
rand_isaac-0.1.1
rand_os-0.1.1
rand_pcg-0.1.1
rand_xorshift-0.1.1
rdrand-0.4.0
redox_syscall-0.1.50
redox_termios-0.1.1
remove_dir_all-0.5.1
reqwest-0.9.8
rustc-demangle-0.1.13
rustc_version-0.2.3
ryu-0.2.7
safemem-0.3.0
schannel-0.1.14
scopeguard-0.3.3
security-framework-0.2.1
security-framework-sys-0.2.2
self_update-0.4.5
semver-0.9.0
semver-parser-0.7.0
serde-1.0.84
serde_derive-1.0.84
serde_json-1.0.34
serde_urlencoded-0.5.4
sha2-0.7.1
shell32-sys-0.1.2
siphasher-0.2.3
slab-0.4.2
smallvec-0.6.7
stable_deref_trait-1.1.1
string-0.1.3
syn-0.15.24
synstructure-0.10.1
tar-0.4.20
tempdir-0.3.7
tempfile-3.0.5
termion-1.5.1
time-0.1.42
tokio-0.1.14
tokio-current-thread-0.1.4
tokio-executor-0.1.6
tokio-io-0.1.11
tokio-reactor-0.1.8
tokio-tcp-0.1.3
tokio-threadpool-0.1.10
tokio-timer-0.2.8
try-lock-0.2.2
typenum-1.10.0
unicase-1.4.2
unicase-2.2.0
unicode-bidi-0.3.4
unicode-normalization-0.1.7
unicode-xid-0.1.0
unreachable-1.0.0
url-1.7.2
uuid-0.7.1
vcpkg-0.2.6
version_check-0.1.5
void-1.0.2
want-0.0.6
winapi-0.2.8
winapi-0.3.6
winapi-build-0.1.1
winapi-i686-pc-windows-gnu-0.4.0
winapi-x86_64-pc-windows-gnu-0.4.0
ws2_32-sys-0.2.1
xattr-0.2.2
xdg-2.2.0
"

inherit cargo xdg

DESCRIPTION="Cross-platform media player based on GStreamer and GTK+"
HOMEPAGE="https://github.com/philn/glide"

if [[ ${PV} == 9999 ]]; then
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
	media-libs/gst-plugins-bad[gtk]"
DEPEND="${RDEPEND}"

src_prepare() {
	sed -i \
		-e 's/\(Icon=.*\)\.svg/\1/' \
		data/net.baseart.Glide.desktop || die

	default
}

src_install() {
	cargo_src_install --path .

	insinto /usr/share/appdata
	doins data/net.baseart.Glide.appdata.xml

	insinto /usr/share/applications
	doins data/net.baseart.Glide.desktop

	insinto /usr/share/icons/hicolor/scalable/apps
	doins data/net.baseart.Glide.svg

	einstalldocs
}
