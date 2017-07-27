# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit cmake-utils toolchain-funcs git-r3 flag-o-matic

DESCRIPTION="A powerful cross-platform raw image processing program"
HOMEPAGE="http://www.rawtherapee.com/"
EGIT_BRANCH="newlocallab"
EGIT_REPO_URI="https://github.com/Beep6581/RawTherapee.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="openmp"

RDEPEND="x11-libs/gtk+:3
	dev-libs/expat
	dev-libs/libsigc++:2
	media-libs/libcanberra[gtk3]
	media-libs/tiff:0
	media-libs/libpng:0
	media-libs/libiptcdata
	media-libs/lcms:2
	sci-libs/fftw:3.0
	sys-libs/zlib
	virtual/jpeg:0"
DEPEND="${RDEPEND}
	app-arch/xz-utils
	virtual/pkgconfig
	dev-cpp/gtkmm:3.0"

pkg_pretend() {
	if use openmp ; then
		tc-has-openmp || die "Please switch to an openmp compatible compiler"
	fi
	# https://bugs.gentoo.org/show_bug.cgi?id=606896#c2
	# https://github.com/vivo75/vivovl/issues/2
	if [[ $(get-flag -O3) != "-O3" ]] ; then
		ewarn "upstream suggest using {C,CXX}FLAGS+=\"-O3\" for better performances"
		ewarn "see bug#606896#c2"
		ewarn "take a look at https://wiki.gentoo.org/wiki//etc/portage/package.env"
		ewarn "for suggestion on how to change environment for a single package"
	fi
}

src_configure() {
	filter-flags -ffast-math
	local mycmakeargs=(
		$(cmake-utils_use openmp OPTION_OMP)
		-DDOCDIR=/usr/share/doc/${PF}
		-DCREDITSDIR=/usr/share/${PN}
		-DLICENCEDIR=/usr/share/${PN}
		-DCACHE_NAME_SUFFIX="${EGIT_BRANCH}"
	)
	cmake-utils_src_configure
}