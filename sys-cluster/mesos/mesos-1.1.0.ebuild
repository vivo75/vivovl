# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit user

DESCRIPTION="Datacenter Cluster Operating System"
HOMEPAGE="http://mesos.apache.org/"
SRC_URI="http://archive.apache.org/dist/mesos/${PV}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="python +java"

DEPEND="
	dev-cpp/glog
	java? (
		dev-java/maven-bin
		virtual/jdk
	)
	python? (
		dev-libs/protobuf[python]
	)
	dev-libs/apr
	dev-libs/cyrus-sasl
	dev-libs/leveldb
	dev-libs/protobuf[java]
	dev-libs/zookeeper-c
	dev-vcs/subversion
	sys-apps/ethtool
"
RDEPEND="${DEPEND}"

pkg_setup() {
	enewgroup mesos
	enewuser mesos -1 /bin/sh /var/lib/mesos mesos
}

src_configure() {

	econf \
		--with-network-isolator \
		$(use_enable python) \
		$(use_enable java) \
		--with-apr=/usr \
		--with-curl=/usr \
		--with-glog=/usr \
		--with-leveldb=/usr \
		--with-nl=/usr \
		--with-protobuf=/usr \
		--with-sasl=/usr \
		--with-svn=/usr \
		--with-zlib=/usr \
		--with-zookeeper=/usr \
		PROTOBUF_JAR=/usr/share/protobuf/lib/protobuf.jar
}

src_install() {
	emake DESTDIR="${D}" install

	dodir /etc/mesos
	insinto /etc/mesos
	doins "${FILESDIR}/environment"

	insinto /etc/sysctl.d
	newins "${FILESDIR}/mesos.sysctl" "20-mesos.conf"

	insinto /usr/lib/systemd/system
	doins "${FILESDIR}/mesos-master.service"
	doins "${FILESDIR}/mesos-agent.service"

	keepdir /var/lib/mesos
	keepdir /var/log/mesos

	insinto /usr/share/mesos/lib
	for jar in src/java/target/*.jar
	do
		echo "Adding: $jar"
		doins $jar
	done

	# Remove non-mesos python modules
	find "${D}" | \
		grep site-packages | \
		grep -v site-packages/mesos | \
		xargs rm -f

	rm -f "${D}/usr/bin/easy_install"
	rm -rf "${D}/usr/lib64/python2.7/site-packages/setuptools"
}
