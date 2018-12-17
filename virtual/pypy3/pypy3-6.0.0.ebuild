# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="A virtual for PyPy3 Python implementation"
# pypy3 -c 'import sysconfig; print(sysconfig.get_config_var("SOABI"))'
SLOT="0/60"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE="bzip2 gdbm ncurses sqlite tk xml ncurses readline"

RDEPEND="
	|| (
		>=dev-python/pypy3-${PV}:${SLOT}[bzip2?,gdbm(-)?,ncurses?,sqlite?,tk?]
		>=dev-python/pypy3-bin-${PV}:${SLOT}[gdbm(-)?,sqlite?,tk?]
	)"
