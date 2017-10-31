# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

PYTHON_COMPAT=( python2_7 )

inherit eutils autotools flag-o-matic perl-module python-single-r1 versionator

DESCRIPTION="Red Hat Package Management Utils"
HOMEPAGE="http://www.rpm.org"
SRC_URI="http://ftp.rpm.org/releases/rpm-$(get_version_component_range 1-2).x/${P}.tar.bz2"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
#KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-linux ~x86-linux"
KEYWORDS="~amd64"

IUSE="acl caps debugedit doc lua ndb nls python selinux zstd"

CDEPEND="!app-arch/rpm5
	app-arch/libarchive
	>=sys-libs/db-4.5:=
	>=sys-libs/zlib-1.2.3-r1
	>=app-arch/bzip2-1.0.1
	>=dev-libs/popt-1.7
	>=app-crypt/gnupg-1.2
	dev-libs/elfutils
	virtual/libintl
	>=dev-lang/perl-5.8.8
	debugedit? ( !dev-util/debugedit )
	dev-libs/nss
	python? ( ${PYTHON_DEPS} )
	nls? ( virtual/libintl )
	lua? ( >=dev-lang/lua-5.1.0:0[deprecated] )
	acl? ( virtual/acl )
	caps? ( >=sys-libs/libcap-2.0 )
	zstd? ( app-arch/zstd )"

DEPEND="${CDEPEND}
	nls? ( sys-devel/gettext )
	doc? ( app-doc/doxygen )"

RDEPEND="${CDEPEND}
	selinux? ( sec-policy/selinux-rpm )"

REQUIRED_USE="
	python? ( ${PYTHON_REQUIRED_USE} )
"

src_prepare() {
	epatch \
		"${FILESDIR}"/${PN}-4.11.0-autotools.patch \
		"${FILESDIR}"/${PN}-4.8.1-db-path.patch \
		"${FILESDIR}"/${PN}-4.9.1.2-libdir.patch

	# fix #356769
	sed -i 's:%{_var}/tmp:/var/tmp:' macros.in || die "Fixing tmppath failed"
	# fix #492642
	sed -i 's:@__PYTHON@:/usr/bin/python2:' macros.in || die "Fixing %__python failed"

	eautoreconf

	# Prevent automake maintainer mode from kicking in (#450448).
	touch -r Makefile.am preinstall.am
}

src_configure() {
	append-cppflags -I"${EPREFIX}/usr/include/nss" -I"${EPREFIX}/usr/include/nspr"
	econf \
		--without-imaevm \
		--without-selinux \
		--with-external-db \
		--with-crypto=nss \
		--disable-lmdb \
		$(use_enable ndb) \
		$(use_enable python) \
		$(use_with doc hackingdocs) \
		$(use_enable nls) \
		$(use_with lua) \
		$(use_with caps cap) \
		$(use_with acl) \
		$(use_enable zstd)
}

src_compile() {
	default
}

src_install() {
	default

	# remove la files
	prune_libtool_files --all

	use nls || rm -rf "${ED}"/usr/share/man/??

	# this will conflict with dev-util/debugedit
	use debugedit && ln -snf "${EROOT}"usr/libexec/rpm/debugedit "${ED}"/usr/bin/debugedit

	for binary in rpmquery rpmverify;do
		ln -sf rpm "${ED}"/usr/bin/${binary}
	done

	keepdir /usr/src/rpm/{SRPMS,SPECS,SOURCES,RPMS,BUILD}

	dodoc CREDITS README*
	if use doc; then
		pushd doc/hacking/html
		dohtml -p hacking -r .
		popd
		pushd doc/librpm/html
		dohtml -p librpm -r .
		popd
	fi

	# Fix perllocal.pod file collision
	perl_delete_localpod
}

pkg_postinst() {
	if [[ -f "${EROOT}"/var/lib/rpm/Packages ]] ; then
		einfo "RPM database found... Rebuilding database (may take a while)..."
		"${EROOT}"/usr/bin/rpmdb --rebuilddb --root="${EROOT}"
	else
		einfo "No RPM database found... Creating database..."
		"${EROOT}"/usr/bin/rpmdb --initdb --root="${EROOT}"
	fi
}