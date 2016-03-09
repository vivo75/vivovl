# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit multilib rpm

DESCRIPTION="OpenNMS is a higly robust and flexible NMS tool"
MY_PN="${PN%-bin}"
FLCV="-1"
SRC_URI="https://yum.opennms.org/stable/common/opennms/${MY_PN}-core-${PV}${FLCV}.noarch.rpm"

HOMEPAGE="https://www.opennms.org/"
KEYWORDS="amd64 x86"
LICENSE="GPL-2"
SLOT="0"
# small - comments out UI features not used in small sites normally
# jna -  use jna code only for icmp
# ipv6 - pull in jicmp6 if not using jna only
IUSE="small minimal storebygroup jna ipv6 rrdtool"

DEPEND="
		net-analyzer/opennms-iplike
		|| (
			>=virtual/jdk-1.8
		)
		|| (
			>=dev-db/postgresql-9.4
		)
		rrdtool?	( net-analyzer/opennms-jrrd )
		!jna?		( net-analyzer/opennms-jicmp
			ipv6? ( net-analyzer/opennms-jicmp6 )
		)
"

RDEPEND="${DEPEND}"

S="${WORKDIR}/opennms-${PV}/"


src_unpack() {
	rpm_unpack
	mkdir "${S}"
	mv ${WORKDIR}/{opt,var} ${S}/
}

src_install() {
	insinto /
	doins -r {opt,var}
}

OPENNMS_HOME="/opt/opennms"

INST_LOGDIR="/var/log/opennms"
# FIXME: SHAREDIR should be /var/lib/
INST_SHAREDIR="/var/opennms"
INST_PIDDIR="/run"
INST_PIDFILE="${INST_PIDDIR}/opennms.pid"



pkg_preinst() {
	# Create user and group
	enewgroup opennms 357
	enewuser opennms 357 -1 /dev/null opennms

	cd ${D}/${OPENNMS_HOME}

	# Generally keep it all tight
	find . ${D}/${INST_SHAREDIR} ${D}/${INST_LOGDIR} -type d -exec chown root:opennms {} \;
	find . ${D}/${INST_SHAREDIR} ${D}/${INST_LOGDIR} -type d -exec chmod 770 {} \;

	# This is dodgy
	find etc data docs lib system contrib -type f -exec chown root:opennms {} \;
	find etc data docs lib system contrib -type f -exec chmod 640 {} \;

	# This is dodgy
	find bin -type f -exec chown root:opennms {} \;
	find bin -type f -exec chmod 750 {} \;

}

pkg_postinst() {
	#local HAS_PGSQL=0

	# Check to see if we have an OK java environment
	${OPENNMS_HOME}/bin/runjava -s -q

	einfo "Now you need to initialise the database and setup OpenNMS, run:"
	einfo "${OPENNMS_HOME}/bin/install -dis"
	einfo ""

	einfo "Do NOT run a DHCP server on this machine,"
	einfo "it would interfere with DHCP monitoring by OpenNMS."
	einfo ""

	einfo "If you are upgrading from OpenNMS version 15 or newer,"
	einfo "you should probably clean out ${OPENNMS_DIR}/data/cache."
}


# TODO: /opt/opennms/bin add to PATH


# OPENNMS_HOME="/opt/opennms"
#
# INST_LOGDIR="/var/log/opennms"
# # FIXME: SHAREDIR should be /var/lib/
# INST_SHAREDIR="/var/lib/opennms"
# INST_PIDDIR="/run"
# INST_PIDFILE="${INST_PIDDIR}/opennms.pid"
#
# INST_PREFIX="-Dinstall.prefix=${D}"
# INST_DIR="-Dinstall.dir=${OPENNMS_HOME}"
# INST_LOG="-Dinstall.logs.dir=${INST_LOGDIR}"
# INST_SHARE="-Dinstall.share.dir=${INST_SHAREDIR}"
# INST_PID="-Dinstall.pid.file=${INST_PIDFILE}"
# INST_DOC="-Dinstall.docs.dir=/usr/share/doc/${P}"
#
# PG_INCLUDE="-Dbuild.postgresql.include.dir=/usr/include/postgresql/server"
#
# PGSQL_RUNNING=0
#
# pkg_setup() {
# 	if [ -f ${OPENNMS_HOME}/etc/java.conf -a -f ${INST_PIDFILE} ] &&  \
# 			[ "`pidof -- \`cat ${OPENNMS_HOME}/etc/java.conf\` -classpath ${OPENNMS_DIR}/etc`" != "" ]; then
# 		eerror ""
# 		eerror "Please stop OpenNMS before trying to upgrade it."
# 		eerror ""
# 		die
# 	fi
# }
#
# src_unpack() {
# 	unpack ${A}
# 	cd ${S}
#
# 	# Strip out stuff from the UI
# 	#use small && epatch ${FILESDIR}/${SLOT}/dispatcher-servlet.xml.patch
#
# 	# Make a remember me button, WIP, default
# 	#epatch ${FILESDIR}/${SLOT}/remember-me-cookie.patch
#
# 	# FIXME: create patch to strip poller/capsd of most things for small
# }
#
# src_install () {
# 	# init.d, conf.d, env.d
# 	newinitd ${FILESDIR}/${PV}/${PN}.init ${PN}
# 	newconfd ${FILESDIR}/${PV}/${PN}.conf ${PN}
# 	newenvd ${FILESDIR}/${PV}/${PN}.env 21${PN}
#
# 	# Install OpenNMS into ${OPENNMS_HOME}
# 	keepdir ${OPENNMS_HOME}
# 	keepdir ${OPENNMS_HOME}/deploy
# 	keepdir ${INST_LOGDIR}
# 	#keepdir ${INST_LOGDIR}/daemon
# 	#keepdir ${INST_LOGDIR}/controller
# 	#keepdir ${INST_LOGDIR}/webapp
# 	keepdir ${INST_SHAREDIR}/reports
# 	keepdir ${INST_PIDDIR}
# 	keepdir ${INST_SHAREDIR}
#
# 	dosym ${INST_LOGDIR} ${OPENNMS_HOME}/logs
# 	dosym ${INST_SHAREDIR} ${OPENNMS_HOME}/share
#
# 	echo ${CONFIG_PROTECT}
#
# 	insinto ${OPENNMS_HOME}
# 	doins -r ${S}/lib
# 	doins -r ${S}/data
# 	doins -r ${S}/docs
# 	doins -r ${S}/system
# 	doins -r ${S}/contrib
# 	doins -r ${S}/jetty-webapps
# 	doins -r ${S}/bin
# 	# FIXME: do some smart stuff with checking for existing config and move our
# 	# stuff to ._cfgXXXX
# 	doins -r ${S}/etc
#
# 	insinto ${INST_LOGDIR}
# 	doins -r ${S}/logs/*
#
# 	# FIXME: get a newins to fix this
# 	cp ${FILESDIR}/${SLOT}/etc-opennms.conf ${D}/${OPENNMS_HOME}/etc/opennms.conf
#
# 	# This needs to be in a place PgSQL can get to it, tell user to call
# 	# insert_iplike.sh after
# 	#dolib.so ${S}/lib/iplike.so
# }
#
# pkg_preinst() {
# 	# Create user and group
# 	enewgroup opennms 357
# 	enewuser opennms 357 -1 /dev/null opennms
#
# 	cd ${D}/${OPENNMS_HOME}
#
# 	# Generally keep it all tight
# 	find . ${D}/${INST_SHAREDIR} ${D}/${INST_LOGDIR} -type d -exec chown root:opennms {} \;
# 	find . ${D}/${INST_SHAREDIR} ${D}/${INST_LOGDIR} -type d -exec chmod 770 {} \;
#
# 	# This is dodgy
# 	find etc data docs lib system contrib -type f -exec chown root:opennms {} \;
# 	find etc data docs lib system contrib -type f -exec chmod 640 {} \;
# 	#find lib -type f -name *.so -exec chmod 750 {} \;
#
# 	# This is dodgy
# 	find bin -type f -exec chown root:opennms {} \;
# 	find bin -type f -exec chmod 750 {} \;
#
# 	#find ${D}/${INST_SHAREDIR} -type d -exec chgrp opennms {} \;
# 	#find ${D}/${INST_SHAREDIR} -type d -exec chmod 750 {} \;
#
# 	#find ${D}/${INST_LOGDIR} -type d -exec chgrp opennms {} \;
# 	#find ${D}/${INST_LOGDIR} -type d -exec chmod 750 {} \;
# }
#
# pkg_postinst() {
# 	#local HAS_PGSQL=0
#
# 	# Check to see if we have an OK java environment
# 	${OPENNMS_HOME}/bin/runjava -s -q
#
# 	# FIXME: Check for ._cfg for create.sql and warn DB needs updating
# #	if [ -f ${OPENNMS_HOME}/etc/._cfg*_create.sql ]; then
# #		ewarn "You have unmerged database changes in ${OPENNMS_HOME}/etc,"
# #		ewarn "OpenNMS will likly not work correctly before changes are merged."
# #		ewarn ""
# #	fi
#
# 	ewarn "Now you need to initialise the database and setup OpenNMS, run:"
# 	ewarn "${OPENNMS_HOME}/bin/install -dis"
# 	ewarn ""
#
# 	# Find iplike.os
# 	#IPLIKE=`ls /usr/lib/postgresql-*/lib/iplike.so`
#
# #	if [ ${PGSQL_RUNNING} -eq 1 ]; then
# #		#echo "DROP FUNCTION IF EXISTS iplike(text,text)"  | psql -q -U opennms
# #		echo "CREATE OR REPLACE FUNCTION iplike(text,text) RETURNS bool AS '$IPLIKE' LANGUAGE 'c' WITH(isstrict);" | psql -q -U opennms
# #		if [ ${?} -gt 0 ]; then
# #			ewarn "You may need to insert the iplike.so function into PostgreSQL manually:"
# #			#ewarn "echo \"DROP FUNCTION IF EXISTS iplike(text,text)\"  | psql -q -U opennms"
# #			ewarn "echo \"CREATE OR REPLACE FUNCTION iplike(text,text) RETURNS bool AS '$IPLIKE' LANGUAGE 'c' WITH(isstrict);\" | psql -q -U opennms"
# #			ewarn ""
# #		fi
# #	fi
#
# 	if has_version 'net-misc/dhcp'; then
# 		ewarn "You have a DHCP server installed on this machine,"
# 		ewarn "this will interfere with DHCP monitoring by OpenNMS."
# 		ewarn ""
# 	fi
#
# 	# FIXME: Check for ._cfg recursively
# 	if [ -f ${OPENNMS_HOME}/etc/._cfg* ]; then
# 		ewarn "You have unmerged config changes in ${OPENNMS_HOME}/etc,"
# 		ewarn "please update these with etc-update before starting OpenNMS."
# 	fi
#
# 	ewarn "If you are upgrading from OpenNMS version 15 or newer,"
# 	ewarn "you should probably clean out ${OPENNMS_DIR}/data/cache."
# }
#
# pkg_prerm() {
# 	if [ -f ${OPENNMS_HOME}/etc/java.conf -a -f ${INST_PIDFILE} ] &&  \
# 			[ "`pidof -- \`cat ${OPENNMS_HOME}/etc/java.conf\` -classpath ${OPENNMS_DIR}/etc`" != "" ]; then
# 		eerror ""
# 		eerror "Please stop OpenNMS before trying to remove it."
# 		eerror ""
# 		die
# 	fi
# }

# kate: encoding utf-8; eol unix; syntax Bash;
# kate: indent-width 8; mixedindent off; replace-tabs off; remove-trailing-spaces modified; space-indent off;
# kate: tab-indents on;
# kate: word-wrap-column 200; word-wrap on;
