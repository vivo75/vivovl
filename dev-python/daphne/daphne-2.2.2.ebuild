# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python{3_5,3_6} pypy3 )

inherit python-r1

DESCRIPTION="Django Channels HTTP/WebSocket server"
HOMEPAGE="https://github.com/django/daphne https://pypi.org/project/daphne/"
SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"

LICENSE="AS-IS"
SLOT="0"
KEYWORDS="amd64"
IUSE="test"

RDEPEND=""
DEPEND="${RDEPEND} dev-python/twisted[${PYTHON_USEDEP}]"
