# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=( python2_7 )

inherit autotools multilib toolchain-funcs git-r3 python-r1 python-utils-r1

DESCRIPTION=" libmypaint, a.k.a. "brushlib", is a library for making brushstrokes which is used by MyPaint and other"
HOMEPAGE="https://github.com/mypaint/libmypaint/wiki"
EGIT_REPO_URI="https://github.com/mypaint/libmypaint.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE="doc gegl +openmp"
#IUSE="doc gegl gperf introspection nls +openmp"

RDEPEND=""
DEPEND="${RDEPEND}"

pkg_pretend() {
    if use openmp ; then
		tc-has-openmp || die "Please switch to an openmp compatible compiler"
	fi
}

src_prepare() {
	./autogen.sh ${myconf} || die

	# Fix "libtoolize --force" of autogen.sh (bug #476626)
	rm install-sh ltmain.sh || die
	_elibtoolize --copy --install || die

	gnome2_src_prepare
}

src_configure() {
	econf \
	$(use_enable doc docs) \
	$(use_enable gegl) \
	$(use_enable openmp)
}

