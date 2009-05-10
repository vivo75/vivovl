# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-p2p/linuxdcpp/linuxdcpp-9999.ebuild,v 1.10 2009/02/10 16:53:05 armin76 Exp $

inherit bzr autotools

DESCRIPTION="Drizzle is a database optimized for Cloud and Net applications"
HOMEPAGE="https://launchpad.net/libdrizzle/"
SRC_URI=""
LICENSE="GPL"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="debug"

EBZR_REPO_URI="lp:drizzle"

RDEPEND=""
DEPEND="${RDEPEND}"

src_unpack() {
	bzr_src_unpack
	./config/autorun.sh
	# eautoreconf
}

src_compile() {
	econf \
	$(use_enable debug dtrace) \
	$(use_enable debug profiling) \
	$(use_enable debug coverage)
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "einstall failed"
}

