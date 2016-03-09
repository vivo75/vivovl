# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit multilib rpm

DESCRIPTION="Java Interface to IPv4 ICMP functions needed for OpenNMS"
MY_PN="${PN#opennms-}"
MY_PN="${MY_PN%-bin}"
FCV="fc23"
FLCV="1"
SRC_URI="
	amd64? ( https://yum.opennms.org/stable/${FCV}/${MY_PN}/${MY_PN}-${PV}-${FLCV}.x86_64.rpm )
	x86? ( https://yum.opennms.org/stable/${FCV}/${MY_PN}/${MY_PN}-${PV}-${FLCV}.i686.rpm )
	"
HOMEPAGE="http://www.opennms.org/"
RESTRICT="mirror"
KEYWORDS="amd64 x86"
LICENSE="GPL-2"

SLOT="0"

RDEPEND=">=virtual/jdk-1.8"
DEPEND="${RDEPEND}"

QA_PRESTRIPPED="/usr/lib64/libjicmp6.so"

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

# kate: encoding utf-8; eol unix; syntax Bash;
# kate: indent-width 8; mixedindent off; replace-tabs off; remove-trailing-spaces modified; space-indent off;
# kate: tab-indents on;
# kate: word-wrap-column 120; word-wrap on;
