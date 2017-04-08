# Copyright 2016 Gaikai, a Sony Interactive Entertainment company

EAPI=5

DESCRIPTION="Build time system packages"

SLOT="0"
KEYWORDS="amd64"

DEPEND="app-arch/bzip2
	app-arch/gzip
	app-arch/tar
	app-arch/xz-utils
	app-misc/colordiff
	net-misc/rsync
	net-misc/wget
	sys-apps/diffutils
	sys-apps/file
	sys-apps/findutils
	sys-apps/less
	sys-apps/util-linux
	sys-apps/which
	sys-devel/binutils
	sys-devel/gcc
	sys-devel/gnuconfig
	sys-devel/make
	sys-devel/patch
	sys-process/procps
	sys-process/psmisc
	virtual/pager
	virtual/os-headers"
