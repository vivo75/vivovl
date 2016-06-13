# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit cmake-utils toolchain-funcs git-r3

DESCRIPTION="A powerful cross-platform raw image processing program"
HOMEPAGE="http://www.rawtherapee.com/"
EGIT_REPO_URI="https://github.com/Beep6581/RawTherapee.git"
EGIT_COMMIT="f0611fe9bacb47f1cc55a285eabf3d2ee2a93007"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="bzip2 openmp"

RDEPEND="bzip2? ( app-arch/bzip2 )
	>=x11-libs/gtk+-3.18.7:3
	>=dev-cpp/gtkmm-3.18.0:3.0
	>=dev-cpp/glibmm-2.16:2
	dev-libs/expat
	dev-libs/libsigc++:2
	media-libs/libcanberra[gtk]
	media-libs/tiff:0
	media-libs/libpng:0
	media-libs/libiptcdata
	media-libs/lcms:2
	sci-libs/fftw:3.0
	sys-libs/zlib
	virtual/jpeg:0"
DEPEND="${RDEPEND}
	app-arch/xz-utils
	virtual/pkgconfig"

pkg_pretend() {
	if use openmp ; then
		tc-has-openmp || die "Please switch to an openmp compatible compiler"
	fi
}

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use openmp OPTION_OMP)
		$(cmake-utils_use_with bzip2 BZIP)
		-DDOCDIR=/usr/share/doc/${PF}
		-DCREDITSDIR=/usr/share/${PN}
		-DLICENCEDIR=/usr/share/${PN}
		-DCACHE_NAME_SUFFIX=""
	)
	cmake-utils_src_configure
}
