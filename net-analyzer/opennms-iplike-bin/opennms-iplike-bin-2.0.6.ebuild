# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jrrd/jrrd-1.0.1-r1.ebuild,v 1.4 2008/12/08 03:37:55 jmbsvicetto Exp $

EAPI=5

inherit multilib rpm

DESCRIPTION="Java Interface to Tobias Oetiker's RRDtool"
MY_PN="${PN#opennms-}"
MY_PN="${MY_PN%-bin}"
FCV="fc23"
FLCV="1."
SRC_URI="
	amd64? ( https://yum.opennms.org/stable/${FCV}/${MY_PN}/${MY_PN}-${PV}-${FLCV}${FCV}.x86_64.rpm )
	x86? ( https://yum.opennms.org/stable/${FCV}/${MY_PN}/${MY_PN}-${PV}-${FLCV}${FCV}.i686.rpm )
	"

HOMEPAGE="https://www.opennms.org/wiki/IPLIKE"
KEYWORDS="amd64 x86"
LICENSE="GPL-2"
SLOT="0"

DEPEND=">=dev-db/postgresql-9.4"
RDEPEND="${DDEPEND}"

QA_PRESTRIPPED="/usr/lib64/pgsql/iplike.so"

pkg_setup() {
	ewarn ""
	ewarn "Before you initialise the OpenNMS database your PgSQL needs to"
	ewarn "run with a UTF-based locale. Please check PG_INITDB_OPTS in"
	ewarn "/etc/conf.d/postgresql-*, and correct before proceeding."
	ewarn ""
}

src_unpack() {
	rpm_unpack
	mkdir "${S}"
	mv ${WORKDIR}/usr ${S}/usr
	mv ${S}/usr/lib64 ${S}/usr/$(get_libdir) 2> /dev/null
}

src_install() {
	insinto /
	doins -r usr
}

pkg_postinst() {

	# Find iplike.os
	IPLIKE=`ls /usr/lib/postgresql-*/lib/iplike.so`
	ewarn "You need to insert the iplike.so function into PostgreSQL"
	ewarn "use the provided \"install_iplike.sh\" binary"
}

# kate: encoding utf-8; eol unix; syntax Bash;
# kate: indent-width 8; mixedindent off; replace-tabs off; remove-trailing-spaces modified; space-indent off;
# kate: tab-indents on;
# kate: word-wrap-column 120; word-wrap on;
