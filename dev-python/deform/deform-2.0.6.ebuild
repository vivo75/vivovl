# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

PYTHON_COMPAT=( python{2_7,3_4,3_5,3_6} pypy )
inherit distutils-r1

DESCRIPTION="Another form generation library"
HOMEPAGE="https://docs.pylonsproject.org/projects/deform/en/latest/ https://pypi.org/project/deform/ https://github.com/Pylons/deform"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="repoze"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="test"

RDEPEND="dev-python/translationstring[${PYTHON_USEDEP}]
	dev-python/colander[${PYTHON_USEDEP}]
	dev-python/peppercorn[${PYTHON_USEDEP}]
	dev-python/chameleon[${PYTHON_USEDEP}]
	dev-python/iso8601[${PYTHON_USEDEP}]
	dev-python/zope-deprecation[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}
	test? ( dev-python/beautifulsoup:4[${PYTHON_USEDEP}]
		dev-python/coverage[${PYTHON_USEDEP}]
		dev-python/nose[${PYTHON_USEDEP}]
		dev-python/flaky[${PYTHON_USEDEP}] )"

# Include COPYRIGHT.txt because the license seems to require it.
DOCS=( CHANGES.txt COPYRIGHT.txt README.rst )

src_install() {
	distutils-r1_src_install

	# Install only the .rst source, as sphinx processing requires
	# a theme only available from git that contains hardcoded
	# references to files on https://static.pylonsproject.org/ (so
	# the docs would not actually work offline). Install the
	# source, which is somewhat readable.
	docinto docs
	dodoc docs/*.rst || die
}
