# Copyright 1999-2017 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5
PYTHON_COMPAT=( python3_{8..10} )

inherit distutils-r1

DESCRIPTION="A small open source Python web framework"
HOMEPAGE="http://www.pylonsproject.org/"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="repoze"
SLOT="0"
KEYWORDS="amd64 x86"

RDEPEND="dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/pyramid[${PYTHON_USEDEP}]
	dev-python/mako[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}"

