# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CRATES="
adler32-1.0.3
aho-corasick-0.7.3
argon2rs-0.2.5
arrayvec-0.4.10
autocfg-0.1.4
backtrace-0.3.32
backtrace-sys-0.1.29
base64-0.10.1
bincode-1.1.4
bitflags-1.1.0
blake2-rfc-0.2.18
block-buffer-0.7.3
block-padding-0.1.4
build_const-0.2.1
byte-tools-0.3.1
bytecount-0.5.1
byteorder-1.3.2
cc-1.0.37
cfg-if-0.1.9
chrono-0.4.7
cloudabi-0.0.3
constant_time_eq-0.1.3
crc-1.8.1
crc32fast-1.2.0
crossbeam-0.7.1
crossbeam-channel-0.3.8
crossbeam-deque-0.7.1
crossbeam-epoch-0.7.1
crossbeam-queue-0.1.2
crossbeam-utils-0.6.5
digest-0.8.0
dirs-2.0.1
dirs-sys-0.3.3
failure-0.1.5
failure_derive-0.1.5
fake-simd-0.1.2
fern-0.5.8
filetime-0.2.5
flate2-1.0.9
fnv-1.0.6
fsevent-0.4.0
fsevent-sys-2.0.1
fuchsia-cprng-0.1.1
fuchsia-zircon-0.3.3
fuchsia-zircon-sys-0.3.3
generic-array-0.12.3
humantime-1.2.0
idna-0.1.5
inotify-0.6.1
inotify-sys-0.1.3
iovec-0.1.2
itoa-0.4.4
jsonrpc-lite-0.5.0
kernel32-sys-0.2.2
languageserver-types-0.54.0
lazy_static-1.3.0
lazycell-1.2.1
libc-0.2.58
line-wrap-0.1.1
linked-hash-map-0.5.2
log-0.4.6
matches-0.1.8
memchr-2.2.0
memoffset-0.2.1
miniz-sys-0.1.12
miniz_oxide-0.2.1
miniz_oxide_c_api-0.2.1
mio-0.6.19
mio-extras-2.0.5
miow-0.2.1
net2-0.2.33
nodrop-0.1.13
notify-4.0.12
num-derive-0.2.5
num-integer-0.1.41
num-traits-0.2.8
onig-4.3.2
onig_sys-69.1.0
opaque-debug-0.2.2
percent-encoding-1.0.1
pkg-config-0.3.14
plist-0.4.2
proc-macro2-0.4.30
quick-error-1.2.2
quote-0.6.12
rand-0.4.6
rand-0.6.5
rand_chacha-0.1.1
rand_core-0.3.1
rand_core-0.4.0
rand_hc-0.1.0
rand_isaac-0.1.1
rand_jitter-0.1.4
rand_os-0.1.3
rand_pcg-0.1.2
rand_xorshift-0.1.1
rdrand-0.4.0
redox_syscall-0.1.54
redox_users-0.3.0
regex-1.1.7
regex-syntax-0.6.7
remove_dir_all-0.5.2
rustc-demangle-0.1.15
ryu-0.2.8
safemem-0.3.0
same-file-1.0.4
scoped_threadpool-0.1.9
scopeguard-0.3.3
serde-1.0.94
serde_derive-1.0.94
serde_json-1.0.39
serde_test-1.0.94
sha2-0.8.0
slab-0.4.2
smallvec-0.6.10
syn-0.15.39
synstructure-0.10.2
syntect-3.2.0
tempdir-0.3.7
thread_local-0.3.6
time-0.1.42
toml-0.5.1
typenum-1.10.0
ucd-util-0.1.3
unicode-bidi-0.3.4
unicode-normalization-0.1.8
unicode-segmentation-1.3.0
unicode-xid-0.1.0
url-1.7.2
url_serde-0.2.0
utf8-ranges-1.0.3
walkdir-2.2.8
winapi-0.2.8
winapi-0.3.7
winapi-build-0.1.1
winapi-i686-pc-windows-gnu-0.4.0
winapi-util-0.1.2
winapi-x86_64-pc-windows-gnu-0.4.0
ws2_32-sys-0.2.1
xml-rs-0.8.0
yaml-rust-0.4.3
"

inherit cargo

MY_PN="xi-editor"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="A modern editor with a backend written in Rust"
HOMEPAGE="https://xi-editor.io/xi-editor/"

if [[ ${PV} == 9999 ]]
then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/xi-editor/${MY_PN}.git"
	RESTRICT="network-sandbox"
	KEYWORDS=""
	S="${WORKDIR}/${P}/rust"
else
	SRC_URI="https://github.com/xi-editor/${MY_PN}/archive/v${PV}.tar.gz -> ${MY_P}.tar.gz
		$(cargo_crate_uris ${CRATES})"
	KEYWORDS="~amd64 ~x86"
	S="${WORKDIR}/${MY_P}/rust"
fi

LICENSE="Apache-2.0"
SLOT="0"
IUSE="+syntect"

DEPEND=""
DEPEND="${RDEPEND}"
BDEPEND=""

src_prepare() {
	default

	sed -i -e '/optional/d' \
		experimental/lang/Cargo.toml || die
}

src_compile() {
	cargo_src_compile

	if use syntect
	then
		cargo build -v -j $(makeopts_jobs) $(usex debug "" --release) \
			--manifest-path syntect-plugin/Cargo.toml \
			|| die "cargo build failed"
	fi
}

src_install() {
	cargo_src_install --path .

	if use syntect
	then
		insinto "${EPREFIX}/usr/share/xi/plugins/syntect"
		doins syntect-plugin/manifest.toml
		exeinto "${EPREFIX}/usr/share/xi/plugins/syntect/bin"
		doexe target/release/xi-syntect-plugin
	fi
}
