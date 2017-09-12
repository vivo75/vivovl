# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="https://github.com/zfsonlinux/${PN}.git"
else
	#SRC_URI="https://github.com/zfsonlinux/zfs/releases/download/zfs-${PV}/${P}.tar.gz"
	KEYWORDS="~amd64"
	EGIT_REPO_URI="https://github.com/zfsonlinux/${PN}.git"
	EGIT_COMMIT="9df9692637aeee416f509c7f39655beb2d35b549"
fi

inherit flag-o-matic git-r3 linux-info linux-mod autotools

DESCRIPTION="The Solaris Porting Layer provides Solaris kernel APIs in a Linux module"
HOMEPAGE="http://zfsonlinux.org/"

LICENSE="GPL-2"
SLOT="0"
IUSE="custom-cflags debug"
RESTRICT="debug? ( strip ) test"

COMMON_DEPEND="dev-lang/perl
	virtual/awk"

DEPEND="${COMMON_DEPEND}"

RDEPEND="${COMMON_DEPEND}
	!sys-devel/spl"

AT_M4DIR="config"
AUTOTOOLS_IN_SOURCE_BUILD="1"
DOCS=( AUTHORS DISCLAIMER )

pkg_setup() {
	linux-info_pkg_setup
	CONFIG_CHECK="
		!DEBUG_LOCK_ALLOC
		MODULES
		KALLSYMS
		!GRKERNSEC_RANDSTRUCT
		!PAX_KERNEXEC_PLUGIN_METHOD_OR
		!PAX_SIZE_OVERFLOW
		ZLIB_DEFLATE
		ZLIB_INFLATE
	"

	use debug && CONFIG_CHECK="${CONFIG_CHECK}
		FRAME_POINTER
		DEBUG_INFO
		!DEBUG_INFO_REDUCED
	"

	kernel_is ge 2 6 32 || die "Linux 2.6.32 or newer required"

	[ ${PV} != "9999" ] && \
		{ kernel_is le 4 13 || die "Linux 4.13 is the latest supported version."; }

	check_extra_config
}

src_prepare() {
	# splat is unnecessary unless we are debugging
	use debug || { sed -e 's/^subdir-m += splat$//' -i "${S}/module/Makefile.in" || die ; }

	# Set module revision number
	[ ${PV} != "9999" ] && \
		{ sed -i "s/\(Release:\)\(.*\)1/\1\2${PR}-gentoo/" "${S}/META" || die "Could not set Gentoo release"; }

	eautoreconf || die
	elibtoolize --patch-only || die

	default
}

src_configure() {
	use custom-cflags || strip-flags
	filter-ldflags -Wl,*

	set_arch_to_kernel
	local myeconfargs=(
		--bindir="${EPREFIX}/bin"
		--sbindir="${EPREFIX}/sbin"
		--with-config=all
		--with-linux="${KV_DIR}"
		--with-linux-obj="${KV_OUT_DIR}"
		$(use_enable debug)
		--docdir="${EPREFIX}"/usr/share/doc/${PF}
	)
	econf "${myeconfargs[@]}"
}

src_compile() {
	emake
}

src_install() {
	emake DESTDIR="${D}" INSTALL_MOD_PATH="${INSTALL_MOD_PATH:-$EROOT}" install
	dodoc -r "${DOCS[@]}"
}

pkg_postinst() {
	linux-mod_pkg_postinst

	# Remove old modules
	if [ -d "${EROOT}lib/modules/${KV_FULL}/addon/spl" ]
	then
		ewarn "${PN} now installs modules in ${EROOT}lib/modules/${KV_FULL}/extra/spl"
		ewarn "Old modules were detected in ${EROOT}lib/modules/${KV_FULL}/addon/spl"
		ewarn "Automatically removing old modules to avoid problems."
		rm -r "${EROOT}lib/modules/${KV_FULL}/addon/spl" || die "Cannot remove modules"
		rmdir --ignore-fail-on-non-empty "${EROOT}lib/modules/${KV_FULL}/addon"
	fi
}
