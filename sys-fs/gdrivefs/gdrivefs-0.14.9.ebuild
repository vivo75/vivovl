# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_6 )

inherit distutils-r1

MY_P="GDriveFS-${PV}"
DESCRIPTION="An innovative FUSE wrapper for Google Drive."
HOMEPAGE="https://github.com/dsoprea/GDriveFS"
SRC_URI="https://github.com/dsoprea/GDriveFS/archive/${PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm"

RDEPEND="sys-fs/fuse"
DEPEND="${RDEPEND}
	dev-python/fusepy
	dev-python/google-api-python-client
	virtual/python-greenlet
	dev-python/httplib2
	dev-python/python-dateutil
	dev-python/six"

DOCS=( README.rst )

S="${WORKDIR}/${MY_P}"
