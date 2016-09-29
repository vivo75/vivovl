# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit autotools eutils

MY_P="${PN}-enfuse-${PV/_rc/rc}"

DESCRIPTION="Image Blending with Multiresolution Splines"
HOMEPAGE="http://enblend.sourceforge.net/"
SRC_URI="mirror://sourceforge/enblend/${MY_P}.tar.gz"

LICENSE="GPL-2 VIGRA"
SLOT="0"
KEYWORDS="amd64 ppc x86"
IUSE="debug doc gpu image-cache openmp openexr"

REQUIRED_USE="openmp? ( !image-cache )"

RDEPEND="
	>=dev-libs/boost-1.31.0:=
	media-libs/glew
	>=media-libs/lcms-2.5:2
	>=media-libs/libpng-1.2.43:0=
	>=media-libs/openexr-1.0:=
	media-libs/plotutils[X]
	media-libs/tiff:=
	>=media-libs/vigra-1.8.0[openexr]
	sci-libs/gsl:=
	virtual/jpeg:0=
	debug? ( dev-libs/dmalloc )
	gpu? ( media-libs/freeglut )
	virtual/latex-base"
# TODO: documentation switched from Texinfo to LaTex and Hevea
# http://hg.code.sf.net/p/enblend/code/file/a7a247e1e64b/NEWS
# TODO: remove virtual/latex-base need from -doc usage
# TODO: gpu is ineffective ATM
DEPEND="${RDEPEND}
	media-gfx/imagemagick
	sys-apps/help2man
	virtual/pkgconfig
	openmp? (
		dev-util/google-perftools
	)
	doc? (
		media-gfx/transfig
		sci-visualization/gnuplot[gd]
		virtual/latex-base
	)"

S="${WORKDIR}/${MY_P}"


src_configure() {
	local c
	c="$(use_with openexr) \
	$(use_enable image-cache) \
	$(use_enable openmp) \
	$(use_with openmp tcmalloc)"
	econf ${c}
}

#src_compile() {
#	# forcing -j1 as every parallel compilation process needs about 1 GB RAM.
#	cmake-utils_src_compile -j1
#}

