# Copyright 2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python2_7 )

inherit distutils-r1 versionator git-r3

DESCRIPTION="rclone backend for duplicity"HOMEPAGE=""
HOMEPAGE="https://github.com/GilGalaad/duplicity-rclone"
EGIT_REPO_URI="https://github.com/vivo75/duplicity-rclone"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

CDEPEND="
	net-misc/rclone
"
DEPEND="${CDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
"
RDEPEND="${CDEPEND}"
