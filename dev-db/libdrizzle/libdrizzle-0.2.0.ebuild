# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/pgadmin3/pgadmin3-1.8.4.ebuild,v 1.2 2008/07/18 08:11:51 aballier Exp $

EAPI="1"

inherit eutils autotools

KEYWORDS="~amd64"

DESCRIPTION="cli lib drizzle"
HOMEPAGE="http://www.pgadmin.org/"
SRC_URI="mirror://launchpad/libdrizzle/trunk/${PV}/+download/libdrizzle-${PV}.tar.gz"
LICENSE="GPL"
SLOT="0"
IUSE="debug"

DEPEND=""
RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	eautoreconf
}

src_compile() {
	econf \
		$(use_enable debug)
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "einstall failed"
}
