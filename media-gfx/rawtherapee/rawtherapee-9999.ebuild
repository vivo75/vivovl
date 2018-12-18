# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils flag-o-matic gnome2-utils toolchain-funcs xdg-utils git-r3

MY_P=${P/_rc/-rc}
DESCRIPTION="A powerful cross-platform raw image processing program"
HOMEPAGE="http://www.rawtherapee.com/"
#EGIT_BRANCH="amaze_vng4"
EGIT_REPO_URI="https://github.com/Beep6581/RawTherapee.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="openmp"

RDEPEND="dev-libs/expat
	dev-libs/libsigc++:2
	media-libs/lcms:2
	media-libs/lensfun
	media-libs/libcanberra[gtk3]
	media-libs/libiptcdata
	media-libs/libpng:0
	media-libs/tiff:0
	sci-libs/fftw:3.0
	sys-libs/zlib
	virtual/jpeg:0
	x11-libs/gtk+:3"
DEPEND="${RDEPEND}
	app-arch/xz-utils
	dev-cpp/gtkmm:3.0
	virtual/pkgconfig"

S="${WORKDIR}/${MY_P}"

pkg_pretend() {
	if use openmp ; then
		tc-has-openmp || die "Please switch to an openmp compatible compiler"
	fi
}

src_configure() {
	# upstream tested that "fast-math" give wrong results, so filter it
	# https://bugs.gentoo.org/show_bug.cgi?id=606896#c2
	filter-flags -ffast-math
	# -Ofast enable "fast-math" both in gcc and clang
	replace-flags -Ofast -O3
	# In case we add an ebuild for klt we can (i)use that one,
	# see http://cecas.clemson.edu/~stb/klt/
	local mycmakeargs=(
		-DOPTION_OMP=$(usex openmp)
		-DDOCDIR=/usr/share/doc/${PF}
		-DCREDITSDIR=/usr/share/${PN}
		-DLICENCEDIR=/usr/share/${PN}
		-DCACHE_NAME_SUFFIX="${EGIT_BRANCH}"
		-DWITH_SYSTEM_KLT="off"
	)
	cmake-utils_src_configure
}

pkg_postinst() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
}
