# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-p2p/linuxdcpp/linuxdcpp-9999.ebuild,v 1.10 2009/02/10 16:53:05 armin76 Exp $

inherit bzr autotools

DESCRIPTION="This is the the client and protocol library for the Drizzle project"
HOMEPAGE="https://launchpad.net/libdrizzle/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="debug"

EBZR_REPO_URI="lp:libdrizzle"

RDEPEND=""
DEPEND="${RDEPEND}"

src_compile() {
	eautoreconf
	econf \
	$(use_enable debug dtrace) \
	$(use_enable debug profiling) \
	$(use_enable debug coverage)
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "einstall failed"
}

