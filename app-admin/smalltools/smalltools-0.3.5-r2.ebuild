# Copyright 2017-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{8..10} )

IUSE="zfs"

DESCRIPTION="A collection of small tools for sysadmins"
HOMEPAGE="https://github.com/vivo75/smalltools"

RDEPEND="
	zfs? ( sys-apps/util-linux
			dev-db/sqlite
			sys-fs/zfs
			sys-fs/zfs-auto-snapshot )"

if [[ ${PV} == 9999 ]] ; then
	inherit distutils-r1 git-r3
	EGIT_REPO_URI="https://github.com/vivo75/${PN}.git"
	KEYWORDS="amd64 ~arm"
else
	inherit distutils-r1
	SRC_URI="https://github.com/vivo75/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="amd64 arm"
fi

LICENSE="GPL-2"
SLOT="0"

DOCS=( README.md )
