# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=( python2_7 )

inherit multilib scons-utils toolchain-funcs git-r3 python-r1 python-utils-r1

DESCRIPTION=""
HOMEPAGE=""
EGIT_REPO_URI="https://github.com/mypaint/libmypaint.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="+gegl openmp"

RDEPEND="gegl? ( media-libs/gegl )"
DEPEND="${RDEPEND}"

pkg_pretend() {
	if use openmp ; then
		tc-has-openmp || die "Please switch to an openmp compatible compiler"
	fi
}

src_compile() {
	escons CC="$(tc-getCC)" enable_gegl=true use_sharedlib=yes prefix="${D}"/usr
}
src_install() {
	escons enable_gegl=true use_sharedlib=yes prefix="${D}"/usr install
	python_export_best
	python_optimize "${D}"usr/share/${PN}
	sed -i -e "s:${D}::" ${D}/usr/lib/pkgconfig/*.pc || die "cannot sanitize *.pc files"
}

