# Copyright 2017-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_6 )

DESCRIPTION="A collection of small tools for sysadmins"
HOMEPAGE="https://github.com/vivo75/smalltools"

if [[ ${PV} == 9999 ]] ; then
	inherit distutils-r1 git-r3
	EGIT_REPO_URI="https://github.com/vivo75/${PN}.git"
	KEYWORDS=
else
	inherit distutils-r1
	SRC_URI="https://github.com/vivo75/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="amd64 arm"
fi

LICENSE="GPL-2"
SLOT="0"

DOCS=( README.md )
