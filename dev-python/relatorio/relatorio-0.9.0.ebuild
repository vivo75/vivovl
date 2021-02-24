# Copyright 1999-2017 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_8 python3_7 python3_9 )

inherit distutils-r1

DESCRIPTION="A templating library able to output odt and pdf files"
HOMEPAGE="https://pypi.python.org/pypi/relatorio"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 ~x86"
IUSE="test fodt chart"

COMMON_DEPEND=">=dev-python/genshi-0.5"
DEPEND="${COMMON_DEPEND}
	dev-python/setuptools"
RDEPEND="${COMMON_DEPEND}
	dev-python/lxml
	fodt? ( sys-apps/file[python] )
	chart? (
		>=dev-python/pycha-0.4.0
		dev-python/pyyaml
		)"

DOCS="README AUTHORS CHANGES"

python_test() {
	esetup.py test || die
}
