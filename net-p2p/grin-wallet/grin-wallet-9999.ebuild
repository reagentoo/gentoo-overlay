# Copyright 2017-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CRATES="
addr2line-0.12.1
adler32-1.0.4
aead-0.2.0
aes-0.3.2
aes-ctr-0.3.0
aes-soft-0.3.3
aesni-0.6.0
age-0.4.0
age-core-0.4.0
aho-corasick-0.7.10
ansi_term-0.11.0
arc-swap-0.4.7
arrayref-0.3.6
arrayvec-0.3.25
arrayvec-0.4.12
arrayvec-0.5.1
async-socks5-0.3.1
async-trait-0.1.35
atty-0.2.14
autocfg-0.1.7
autocfg-1.0.0
backtrace-0.3.48
base64-0.11.0
base64-0.12.1
base64-0.9.3
bcrypt-pbkdf-0.1.0
bech32-0.7.2
bindgen-0.52.0
bit-vec-0.6.2
bitflags-0.9.1
bitflags-1.2.1
blake2-rfc-0.2.18
blake2b_simd-0.5.10
block-buffer-0.3.3
block-buffer-0.7.3
block-cipher-trait-0.6.2
block-modes-0.3.3
block-padding-0.1.5
blowfish-0.4.0
bs58-0.3.1
bstr-0.2.13
built-0.4.2
bumpalo-3.4.0
byte-tools-0.2.0
byte-tools-0.3.1
byteorder-1.3.4
bytes-0.5.4
c2-chacha-0.2.4
cargo-lock-4.0.1
cc-1.0.54
cexpr-0.3.6
cfg-if-0.1.10
chacha20poly1305-0.4.1
chrono-0.4.11
clang-sys-0.28.1
clap-2.33.1
clear_on_drop-0.2.4
cloudabi-0.0.3
constant_time_eq-0.1.5
cookie-factory-0.3.1
core-foundation-0.7.0
core-foundation-sys-0.7.0
crc32fast-1.2.0
croaring-mw-0.4.5
croaring-sys-mw-0.4.5
crossbeam-deque-0.7.3
crossbeam-epoch-0.8.2
crossbeam-queue-0.2.2
crossbeam-utils-0.7.2
crypto-mac-0.6.2
crypto-mac-0.7.0
csv-1.1.3
csv-core-0.1.10
ct-logs-0.6.0
ctor-0.1.15
ctr-0.3.2
curve25519-dalek-2.1.0
data-encoding-2.2.1
difference-2.0.0
digest-0.7.6
digest-0.8.1
dirs-1.0.5
dirs-2.0.2
dirs-next-1.0.1
dirs-sys-0.3.5
dirs-sys-next-0.1.0
doc-comment-0.3.3
dtoa-0.4.5
easy-jsonrpc-mw-0.5.4
easy-jsonrpc-proc-macro-mw-0.5.1
ed25519-dalek-1.0.0-pre.3
either-1.5.3
encode_unicode-0.3.6
enum_primitive-0.1.1
env_logger-0.7.1
failure-0.1.8
failure_derive-0.1.8
fake-simd-0.1.2
flate2-1.0.14
fnv-1.0.7
foreign-types-0.3.2
foreign-types-shared-0.1.1
fuchsia-cprng-0.1.1
fuchsia-zircon-0.3.3
fuchsia-zircon-sys-0.3.3
futures-0.1.29
futures-0.3.5
futures-channel-0.3.5
futures-core-0.3.5
futures-executor-0.3.5
futures-io-0.3.5
futures-macro-0.3.5
futures-sink-0.3.5
futures-task-0.3.5
futures-util-0.3.5
gcc-0.3.55
generic-array-0.12.3
generic-array-0.9.0
getrandom-0.1.14
gimli-0.21.0
git2-0.13.6
glob-0.3.0
grin_api-4.0.0
grin_chain-4.0.0
grin_core-4.0.0
grin_keychain-4.0.0
grin_p2p-4.0.0
grin_pool-4.0.0
grin_secp256k1zkp-0.7.9
grin_store-4.0.0
grin_util-4.0.0
h2-0.2.5
heck-0.3.1
hermit-abi-0.1.13
hkdf-0.8.0
hmac-0.6.3
hmac-0.7.1
http-0.2.1
http-body-0.3.1
httparse-1.3.4
humantime-1.3.0
hyper-0.13.6
hyper-rustls-0.20.0
hyper-socks2-mw-0.4.4
hyper-timeout-0.3.1
hyper-tls-0.4.1
idna-0.2.0
indexmap-1.4.0
iovec-0.1.4
itoa-0.4.5
jobserver-0.1.21
js-sys-0.3.40
jsonrpc-core-10.1.0
keccak-0.1.0
kernel32-sys-0.2.2
lazy_static-1.4.0
lazycell-1.2.1
lexical-core-0.6.2
libc-0.2.71
libgit2-sys-0.12.7+1.0.0
liblmdb-sys-0.2.2
libloading-0.5.2
libz-sys-1.0.25
linefeed-0.6.0
linked-hash-map-0.5.3
lmdb-zero-0.4.4
lock_api-0.3.4
log-0.4.8
log-mdc-0.1.0
log4rs-0.12.0
lru-cache-0.1.2
matches-0.1.8
maybe-uninit-2.0.0
memchr-2.3.3
memmap-0.7.0
memoffset-0.5.4
miniz_oxide-0.3.7
mio-0.6.22
mio-named-pipes-0.1.6
mio-uds-0.6.8
miow-0.2.1
miow-0.3.5
mortal-0.2.2
native-tls-0.2.4
net2-0.2.34
nix-0.17.0
nodrop-0.1.14
nom-4.2.3
nom-5.1.1
ntapi-0.3.4
num-0.2.1
num-bigint-0.2.6
num-complex-0.2.4
num-integer-0.1.42
num-iter-0.1.40
num-rational-0.2.4
num-traits-0.1.43
num-traits-0.2.11
num_cpus-1.13.0
object-0.19.0
odds-0.2.26
once_cell-1.4.0
opaque-debug-0.2.3
openssl-0.10.29
openssl-probe-0.1.2
openssl-sys-0.9.58
ordered-float-1.0.2
output_vt100-0.1.2
parking_lot-0.10.2
parking_lot_core-0.7.2
pbkdf2-0.2.3
pbkdf2-0.3.0
peeking_take_while-0.1.2
percent-encoding-2.1.0
phf-0.8.0
phf_codegen-0.8.0
phf_generator-0.8.0
phf_shared-0.8.0
pin-project-0.4.20
pin-project-internal-0.4.20
pin-project-lite-0.1.7
pin-utils-0.1.0
pkg-config-0.3.17
podio-0.1.7
poly1305-0.5.2
ppv-lite86-0.2.8
pretty_assertions-0.6.1
prettytable-rs-0.8.0
proc-macro-hack-0.5.16
proc-macro-nested-0.1.5
proc-macro2-0.4.30
proc-macro2-1.0.18
quick-error-1.2.3
quote-0.6.13
quote-1.0.7
radix64-0.6.2
rand-0.5.6
rand-0.6.5
rand-0.7.3
rand_chacha-0.1.1
rand_chacha-0.2.2
rand_core-0.3.1
rand_core-0.4.2
rand_core-0.5.1
rand_hc-0.1.0
rand_hc-0.2.0
rand_isaac-0.1.1
rand_jitter-0.1.4
rand_os-0.1.3
rand_pcg-0.1.2
rand_pcg-0.2.1
rand_xorshift-0.1.1
rayon-1.3.0
rayon-core-1.7.0
rdrand-0.4.0
redox_syscall-0.1.56
redox_users-0.3.4
regex-1.3.9
regex-automata-0.1.9
regex-syntax-0.6.18
remove_dir_all-0.5.2
ring-0.16.14
ripemd160-0.7.0
rpassword-4.0.5
rust-argon2-0.7.0
rustc-demangle-0.1.16
rustc-hash-1.1.0
rustc-serialize-0.3.24
rustc_version-0.2.3
rustls-0.17.0
rustls-native-certs-0.3.0
rustyline-6.2.0
ryu-1.0.5
safemem-0.3.3
same-file-1.0.6
schannel-0.1.19
scopeguard-1.1.0
scrypt-0.2.0
sct-0.6.0
secrecy-0.6.0
security-framework-0.4.4
security-framework-sys-0.4.3
semver-0.10.0
semver-0.9.0
semver-parser-0.7.0
serde-1.0.111
serde-value-0.6.0
serde_derive-1.0.111
serde_json-1.0.55
serde_yaml-0.8.13
sha2-0.7.1
sha2-0.8.2
sha3-0.8.2
shlex-0.1.1
signal-hook-registry-1.2.0
siphasher-0.3.3
slab-0.4.2
smallstr-0.2.0
smallvec-1.4.0
socket2-0.3.12
spin-0.5.2
static_assertions-0.3.4
stream-cipher-0.3.2
strsim-0.8.0
strum-0.18.0
strum_macros-0.18.0
subtle-1.0.0
subtle-2.2.3
supercow-0.1.0
syn-0.15.44
syn-1.0.31
synstructure-0.10.2
synstructure-0.12.4
sysinfo-0.14.5
tempfile-3.1.0
term-0.5.2
term-0.6.1
termcolor-1.1.0
terminfo-0.7.3
textwrap-0.11.0
thiserror-1.0.19
thiserror-impl-1.0.19
thread-id-3.3.0
thread_local-1.0.1
time-0.1.43
timer-0.2.0
tokio-0.2.21
tokio-io-timeout-0.4.0
tokio-macros-0.2.5
tokio-rustls-0.13.1
tokio-tls-0.3.1
tokio-util-0.3.1
toml-0.5.6
tower-service-0.3.0
traitobject-0.1.0
try-lock-0.2.2
typemap-0.3.3
typenum-1.12.0
unicode-bidi-0.3.4
unicode-normalization-0.1.12
unicode-segmentation-1.6.0
unicode-width-0.1.7
unicode-xid-0.1.0
unicode-xid-0.2.0
universal-hash-0.3.0
unsafe-any-0.4.2
untrusted-0.7.1
url-2.1.1
utf8parse-0.2.0
uuid-0.8.1
vcpkg-0.2.10
vec_map-0.8.2
version_check-0.1.5
version_check-0.9.2
void-1.0.2
walkdir-2.3.1
want-0.3.0
wasi-0.9.0+wasi-snapshot-preview1
wasm-bindgen-0.2.63
wasm-bindgen-backend-0.2.63
wasm-bindgen-macro-0.2.63
wasm-bindgen-macro-support-0.2.63
wasm-bindgen-shared-0.2.63
web-sys-0.3.40
webpki-0.21.3
which-3.1.1
winapi-0.2.8
winapi-0.3.8
winapi-build-0.1.1
winapi-i686-pc-windows-gnu-0.4.0
winapi-util-0.1.5
winapi-x86_64-pc-windows-gnu-0.4.0
ws2_32-sys-0.2.1
x25519-dalek-0.6.0
yaml-rust-0.3.5
yaml-rust-0.4.4
zeroize-0.9.3
zeroize-1.1.0
zeroize_derive-0.9.3
zeroize_derive-1.0.0
zip-0.5.5
"

inherit cargo user

DESCRIPTION="Wallet for Grin cryptocurrency"
HOMEPAGE="https://github.com/mimblewimble/grin-wallet"

if [[ ${PV} == 9999 ]]
then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/mimblewimble/${PN}.git"
	RESTRICT="network-sandbox"
	KEYWORDS=""
else
	SRC_URI="
		https://github.com/mimblewimble/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
		$(cargo_crate_uris ${CRATES})
	"

	RESTRICT="mirror"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="Apache-2.0 Apache-2.0 CC0-1.0 ISC MIT Unlicense"
SLOT="0"
IUSE=""

DEPEND=""
RDEPEND=""

pkg_setup() {
	enewgroup grin
	enewuser grin -1 -1 /var/lib/grin grin
}

src_prepare() {
	default

	sed -i \
		-e 's/mut grin_path/grin_path/' \
		-e '/grin_path.*push/d' \
		-e '/check_api_secret_file/ s/Some.* API/None, API/' \
		-e '/check_api_secret_file/ s/Some.* OWN/None, OWN/' \
		config/src/config.rs || die

	sed -i \
		-e '/default_config.*update_paths/d' \
		impls/src/lifecycle/default.rs || die
}

src_install() {
	cargo_src_install
	einstalldocs

	HOME="${S}" target/release/grin-wallet -p null init >/dev/null || die

	insinto /etc/grin
	doins grin-wallet.toml

	newinitd "${FILESDIR}/${PN}-initd" "${PN}"
	newconfd "${FILESDIR}/${PN}-confd" "${PN}"

	keepdir /var/{lib,log}/grin
	fowners grin:grin /var/{lib,log}/grin
}

pkg_preinst() {
	sed -i \
		-e '/data_file_dir/ s:=.*:= "/var/lib/grin/wallet_data":' \
		-e "/log_file_path/ s:=.*:= \"/run/grin/${PN}\.log\":" \
		-e '/send_config_dir/ s:=.*:= "/var/lib/grin":' \
		"${D}/etc/grin/grin-wallet.toml" || die
}

pkg_postinst() {
	einfo
	elog "You might want to run:"
	elog "  \"emerge --config =${CATEGORY}/${PF}\""
	elog "if this is a new install."
	einfo
}

pkg_config() {
	einfo "Grin wallet initialization into /var/lib/grin ..."
	einfo

	mkdir /run/grin
	chown grin:grin /run/grin

	su grin -s /bin/sh -c 'cd /etc/grin ; grin-wallet --pass null init'
	su grin -s /bin/sh -c 'rm ~/grin-wallet.{log,toml}'

	einfo
	einfo "Please check your Grin wallet info"
	einfo

	su grin -s /bin/sh -c 'cd /etc/grin ; grin-wallet --pass null info'
}
