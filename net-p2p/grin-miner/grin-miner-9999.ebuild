# Copyright 2017-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CRATES="
addr2line-0.13.0
adler-0.2.3
ahash-0.2.18
ahash-0.3.8
aho-corasick-0.7.13
arc-swap-0.4.7
array-macro-1.0.5
arrayref-0.3.6
arrayvec-0.4.12
arrayvec-0.5.1
atty-0.2.14
autocfg-1.0.0
backtrace-0.3.50
base64-0.11.0
bitflags-1.2.1
blake2-rfc-0.2.18
blake2b_simd-0.5.10
bufstream-0.1.4
built-0.4.2
byteorder-1.3.4
cargo-lock-4.0.1
cc-1.0.58
cfg-if-0.1.10
chrono-0.4.13
cl-sys-0.4.2
cmake-0.1.44
const-cstr-0.3.0
const-random-0.1.8
const-random-macro-0.1.8
constant_time_eq-0.1.5
core-foundation-0.7.0
core-foundation-sys-0.7.0
crossbeam-0.7.3
crossbeam-channel-0.4.2
crossbeam-deque-0.7.3
crossbeam-epoch-0.8.2
crossbeam-queue-0.2.3
crossbeam-utils-0.7.2
cursive-0.14.1
darling-0.10.2
darling_core-0.10.2
darling_macro-0.10.2
dirs-2.0.2
dirs-sys-0.3.5
enum-map-0.6.2
enum-map-derive-0.4.3
enum_primitive-0.1.1
enumset-0.4.5
enumset_derive-0.4.4
failure-0.1.8
failure_derive-0.1.8
fnv-1.0.7
foreign-types-0.3.2
foreign-types-shared-0.1.1
fs_extra-1.1.0
fuchsia-cprng-0.1.1
futures-0.1.29
gcc-0.3.55
getrandom-0.1.14
gimli-0.22.0
git2-0.13.6
glob-0.3.0
hashbrown-0.7.2
hermit-abi-0.1.15
ident_case-1.0.1
idna-0.2.0
itoa-0.4.6
jobserver-0.1.21
lazy_static-1.4.0
libc-0.2.72
libgit2-sys-0.12.7+1.0.0
libloading-0.6.2
libz-sys-1.0.25
log-0.4.8
maplit-1.0.2
matches-0.1.8
maybe-uninit-2.0.0
memchr-2.3.3
memoffset-0.5.5
miniz_oxide-0.4.0
native-tls-0.2.4
ncurses-5.99.0
nodrop-0.1.14
num-0.1.42
num-0.2.1
num-bigint-0.1.44
num-complex-0.1.43
num-complex-0.2.4
num-integer-0.1.43
num-iter-0.1.41
num-rational-0.1.42
num-rational-0.2.4
num-traits-0.1.43
num-traits-0.2.12
object-0.20.0
ocl-0.19.3
ocl-core-0.11.2
ocl-core-vector-0.1.0
openssl-0.10.30
openssl-probe-0.1.2
openssl-sys-0.9.58
owning_ref-0.4.1
pancurses-0.16.1
pdcurses-sys-0.7.1
percent-encoding-2.1.0
pkg-config-0.3.18
ppv-lite86-0.2.8
proc-macro-hack-0.5.16
proc-macro2-1.0.18
quote-1.0.7
qutex-0.2.3
rand-0.3.23
rand-0.4.6
rand-0.7.3
rand_chacha-0.2.2
rand_core-0.3.1
rand_core-0.4.2
rand_core-0.5.1
rand_hc-0.2.0
rdrand-0.4.0
redox_syscall-0.1.57
redox_users-0.3.4
regex-1.3.9
regex-syntax-0.6.18
remove_dir_all-0.5.3
rust-argon2-0.7.0
rust-crypto-0.2.36
rustc-demangle-0.1.16
rustc-serialize-0.3.24
rustc_version-0.1.7
ryu-1.0.5
schannel-0.1.19
scopeguard-1.1.0
security-framework-0.4.4
security-framework-sys-0.4.3
semver-0.1.20
semver-0.9.0
semver-parser-0.7.0
serde-1.0.114
serde_derive-1.0.114
serde_json-1.0.56
signal-hook-0.1.16
signal-hook-registry-1.2.0
slog-2.5.2
slog-async-2.5.0
slog-term-2.6.0
stable_deref_trait-1.2.0
strsim-0.9.3
syn-1.0.34
synstructure-0.12.4
take_mut-0.2.2
tempfile-3.1.0
term-0.6.1
term_size-0.3.2
thread_local-1.0.1
time-0.1.43
tinyvec-0.3.3
toml-0.5.6
unicode-bidi-0.3.4
unicode-normalization-0.1.13
unicode-segmentation-1.6.0
unicode-width-0.1.8
unicode-xid-0.2.1
url-2.1.1
vcpkg-0.2.10
wasi-0.9.0+wasi-snapshot-preview1
winapi-0.3.9
winapi-i686-pc-windows-gnu-0.4.0
winapi-x86_64-pc-windows-gnu-0.4.0
winreg-0.5.1
xi-unicode-0.2.1
"

inherit cargo multilib user

DESCRIPTION="Mining software for Grin, supports CPU and CUDA GPUs."
HOMEPAGE="https://github.com/mimblewimble/grin-miner"

if [[ ${PV} == 9999 ]]
then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/mimblewimble/${PN}.git"
	RESTRICT="network-sandbox"
	KEYWORDS=""
else
	CUCKO_COMMIT="efbf4f865e2ed412f000fd487b324c08e420b735"

	SRC_URI="
		https://github.com/mimblewimble/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
		https://github.com/tromp/cuckoo/archive/${CUCKO_COMMIT}.tar.gz -> cuckoo-${CUCKO_COMMIT::7}.tar.gz
		$(cargo_crate_uris ${CRATES})
	"

	RESTRICT="mirror"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="Apache-2.0 Apache-2.0 CC0-1.0 ISC MIT MPL-2.0 Unlicense"
SLOT="0"
IUSE="cuda +opencl"

DEPEND=""
RDEPEND=""

pkg_setup() {
	enewgroup grin
	enewuser grin -1 -1 /var/lib/grin grin
}

src_unpack() {
	cargo_src_unpack

	rmdir ${P}/cuckoo-miner/src/cuckoo_sys/plugins/cuckoo || die

	mv cuckoo-${CUCKO_COMMIT} \
		${P}/cuckoo-miner/src/cuckoo_sys/plugins/cuckoo || die
}

src_prepare() {
	default

	if ! use cuda
	then
		sed -i \
			-e '/^cuckoo_miner/d' \
			-e 's/^#cuckoo_miner/cuckoo_miner/' \
			Cargo.toml || die
	fi
}

src_compile() {
	if use opencl
	then
		cargo_src_compile --features opencl
	else
		cargo_src_compile
	fi
}

src_install() {
	cargo_src_install
	einstalldocs

	insinto /etc/grin
	doins grin-miner.toml

	newinitd "${FILESDIR}/${PN}-initd" "${PN}"
	newconfd "${FILESDIR}/${PN}-confd" "${PN}"

	keepdir /var/log/grin
	fowners grin:grin /var/log/grin

	insinto /usr/$(get_libdir)/${PN}
	insopts -m755

	doins target/release/plugins/*.cuckooplugin

	if use opencl
	then
		newins target/release/deps/libocl_cuckaroo.so ocl_cuckaroo.cuckooplugin
		newins target/release/deps/libocl_cuckatoo.so ocl_cuckatoo.cuckooplugin
	fi
}

pkg_preinst() {
	sed -i \
		-e "/log_file_path/ s:=.*:= \"/run/grin/${PN}\.log\":" \
		-e '/run_tui/ s:true:false:' \
		-e "s:#\(miner_plugin_dir\).*:\1 = \"/usr/$(get_libdir)/${PN}\":" \
		-e 's/^[^#].*mining\.miner_plugin_config/#&/' \
		-e 's/^device/#device/' \
		-e 's/^plugin_name/#plugin_name/' \
		${D}/etc/grin/grin-miner.toml || die
}

pkg_postinst() {
	einfo
	elog "You might want to enable CUDA or OpenCL plugin in /etc/grin/grin-miner.toml."
	elog "Also you should run grin-server and grin-wallet to use grin-miner."
	einfo
}
