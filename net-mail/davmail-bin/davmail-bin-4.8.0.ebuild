# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils java-pkg-2 user

MY_REV="2479"
MY_PN="davmail"
MY_P="${MY_PN}-linux-x86"

SRC_URI="amd64? ( mirror://sourceforge/${MY_PN}/${MY_P}_64-${PV}-${MY_REV}.tgz )
	x86? ( mirror://sourceforge/${MY_PN}/${MY_P}-${PV}-${MY_REV}.tgz )"
DESCRIPTION="POP/IMAP/SMTP/Caldav/Carddav/LDAP Exchange Gateway"
HOMEPAGE="http://davmail.sourceforge.net/"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="server"

DEPEND="|| (
	>=virtual/jre-1.6
	>=virtual/jdk-1.6
	)
  !net-mail/davmail"
RDEPEND="${DEPEND}"


src_unpack() {
	if use x86; then
		S="${WORKDIR}/${MY_P}-${PV}-${MY_REV}"
	else
		S="${WORKDIR}/${MY_P}_64-${PV}-${MY_REV}"
	fi
	default
}

src_prepare() {
	default
}

pkg_setup() {
  if use server ; then
    enewuser davmail -1 -1 /dev/null
  fi
}

src_install() {
	cd "${S}"

	# libraries
	java-pkg_dojar lib/*.jar
	java-pkg_dojar ${MY_PN}.jar

	# icon
	doicon "${FILESDIR}"/${MY_PN}.png

	# create wrapper script for the client
	java-pkg_dolauncher ${MY_PN} --main ${MY_PN}.DavGateway --java_args ""

	# desktop entry
	make_desktop_entry ${MY_PN} "DavMail" /usr/share/pixmaps/${MY_PN}.png "Network"

	if use server ; then
		# log file
		touch ${MY_PN}.log
		insinto /var/log
		doins ${MY_PN}.log
		fowners ${MY_PN} /var/log/${MY_PN}.log

		# config files
		insinto /etc
		doins "${FILESDIR}"/${MY_PN}.properties
		newinitd "${FILESDIR}"/${MY_PN}.init ${MY_PN}
		newconfd "${FILESDIR}"/${MY_PN}.conf ${MY_PN}
	fi
}

pkg_postinst() {
	if use server ; then
		elog
		elog "You have chosen to run ${MY_PN} as a system service. You will need to"
		elog "modify /etc/${MY_PN}.properties to serve your needs."
		elog
		elog "You may find it easier to run the ${MY_PN}, configure it via the GUI"
		elog "and copy the resulting ~/.${MY_PN}.properties to /etc. Make sure you"
		elog "set ${MY_PN}.server=true and ${MY_PN}.allowRemote=true."
		elog
	fi
}
