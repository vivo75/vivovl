# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit user

DESCRIPTION="A container orchestration platform for Mesos"
HOMEPAGE="https://mesosphere.github.io/marathon"
SRC_URI="http://downloads.mesosphere.com/${PN}/v${PV}/${P}.tgz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="
	sys-cluster/mesos[java]
	virtual/jre
"

pkg_setup() {
	enewgroup marathon
	enewuser marathon -1 /bin/sh /var/lib/marathon marathon
}

src_install() {
	dodir /usr/share/marathon/lib
	insinto /usr/share/marathon/lib
	newins target/*/marathon-assembly-*.jar marathon-assembly.jar

	insinto /usr/lib/systemd/system
	doins "${FILESDIR}/marathon.service"

	insinto /etc/marathon
	doins "${FILESDIR}/environment"
}
