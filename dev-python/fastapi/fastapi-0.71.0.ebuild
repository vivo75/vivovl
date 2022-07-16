# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8..10} )
inherit distutils-r1

DESCRIPTION="FastAPI framework, high performance, easy to learn"
HOMEPAGE="https://www.fastapi.io/"
SRC_URI="https://github.com/tiangolo/fastapi/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="dev-python/starlette[${PYTHON_USEDEP}]
	dev-python/pydantic[${PYTHON_USEDEP}]"

DISTUTILS_USE_SETUPTOOLS=pyproject.toml
