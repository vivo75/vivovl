# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="https://github.com/zfsonlinux/${PN}.git"
	inherit git-r3
else
	#SRC_URI="https://github.com/zfsonlinux/zfs/releases/download/zfs-${PV}/${P}.tar.gz"
	#KEYWORDS=" ~amd64"
	inherit git-r3 linux-mod
	EGIT_REPO_URI="git://github.com/zfsonlinux/${PN}.git"
	EGIT_COMMIT="f5c5286daa5f76532d7a8a7988d6a42cfd58038c"
fi

inherit autotools flag-o-matic linux-info linux-mod

DESCRIPTION="The Solaris Porting Layer is a Linux kernel module which provides many of the Solaris kernel APIs"
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
		{ kernel_is le 4 10 || die "Linux 4.10 is the latest supported version."; }

	check_extra_config
}

src_prepare() {
	# splat is unnecessary unless we are debugging
	use debug || { sed -e 's/^subdir-m += splat$//' -i "${S}/module/Makefile.in" || die ; }

	# Set module revision number
	[ ${PV} != "9999" ] && \
		{ sed -i "s/\(Release:\)\(.*\)1/\1\2${PR}-gentoo/" "${S}/META" || die "Could not set Gentoo release"; }

	eapply_user
	eautoreconf
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
	)
	econf ${myeconfargs[@]}
}

src_install() {
	INSTALL_MOD_PATH="${INSTALL_MOD_PATH:-$EROOT}" default
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
