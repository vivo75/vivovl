# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE="xml"

inherit eutils cmake-utils flag-o-matic gnome2-utils fdo-mime toolchain-funcs python-single-r1

MY_P=${P/_/}

DESCRIPTION="A SVG based generic vector-drawing program"
HOMEPAGE="http://www.inkscape.org/"
SRC_URI="https://inkscape.global.ssl.fastly.net/media/resources/file/${P}.tar.bz2"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~arm ~hppa ~ppc ~ppc64 ~x86 ~amd64-linux ~x86-linux ~sparc-solaris ~x86-solaris"
IUSE="cdr dia dbus gnome imagemagick openmp postscript latex lcms nls spell static-libs visio wpg"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

WPG_DEPS="
	|| (
		( app-text/libwpg:0.3 dev-libs/librevenge )
		( app-text/libwpd:0.9 app-text/libwpg:0.2 )
	)
"
COMMON_DEPEND="
	${PYTHON_DEPS}
	>=app-text/poppler-0.26.0:=[cairo]
	>=dev-cpp/glibmm-2.28
	>=dev-cpp/gtkmm-2.18.0:2.4
	>=dev-cpp/cairomm-1.9.8
	>=dev-cpp/glibmm-2.32
	>=dev-libs/boehm-gc-6.4
	>=dev-libs/glib-2.28
	>=dev-libs/libsigc++-2.0.12
	>=dev-libs/libxml2-2.6.20
	>=dev-libs/libxslt-1.0.15
	dev-libs/popt
	dev-python/lxml[${PYTHON_USEDEP}]
	media-libs/fontconfig
	media-libs/freetype:2
	media-libs/libpng:0
	sci-libs/gsl:=
	x11-libs/libX11
	>=x11-libs/gtk+-2.10.7:2
	>=x11-libs/pango-1.24
	cdr? (
		media-libs/libcdr
		${WPG_DEPS}
	)
	dbus? ( dev-libs/dbus-glib )
	media-libs/libexif
	gnome? ( >=gnome-base/gnome-vfs-2.0 )
	imagemagick? ( media-gfx/imagemagick:=[cxx] )
	virtual/jpeg
	lcms? ( media-libs/lcms:2 )
	spell? (
		app-text/aspell
		app-text/gtkspell:2
	)
	visio? (
		media-libs/libvisio
		${WPG_DEPS}
	)
	wpg? ( ${WPG_DEPS} )
"

# These only use executables provided by these packages
# See share/extensions for more details. inkscape can tell you to
# install these so we could of course just not depend on those and rely
# on that.
RDEPEND="${COMMON_DEPEND}
	dev-python/numpy[${PYTHON_USEDEP}]
	cdr? ( media-gfx/uniconvertor )
	dia? ( app-office/dia )
	latex? (
		media-gfx/pstoedit[plotutils]
		app-text/dvipsk
		app-text/texlive
	)
	postscript? ( app-text/ghostscript-gpl )
"

DEPEND="${COMMON_DEPEND}
	>=dev-libs/boost-1.36
	>=dev-util/intltool-0.40
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
"

S=${WORKDIR}/${MY_P}

RESTRICT="test"

pkg_pretend() {
	if use openmp; then
		tc-has-openmp || die "Please switch to an openmp compatible compiler"
	fi
}

src_prepare() {
# 	epatch \
# 		"${FILESDIR}"/${PN}-0.91_pre3-automagic.patch \
# 		"${FILESDIR}"/${PN}-0.91_pre3-cppflags.patch \
# 		"${FILESDIR}"/${PN}-0.91_pre3-desktop.patch \
# 		"${FILESDIR}"/${PN}-0.91_pre3-exif.patch \
# 		"${FILESDIR}"/${PN}-0.91_pre3-sk-man.patch \
# 		"${FILESDIR}"/${PN}-0.48.4-epython.patch

	sed -i "s#@EPYTHON@#${EPYTHON}#" src/extension/implementation/script.cpp || die

	# bug 421111
	python_fix_shebang share/extensions
	cmake-utils_src_prepare
}

src_configure() {
	# aliasing unsafe wrt #310393
	append-flags -fno-strict-aliasing
	# enable c++11 as needed for sigc++-2.6, #566318
	# remove it when upstream solves the issue
	# https://bugs.launchpad.net/inkscape/+bug/1488079
	append-cxxflags -std=c++11

	# GMOCK_PRESENT before enabling this (and gmock deps) re-enable "test"
	# TODO: option(WITH_GTK3_EXPERIMENTAL "Enable compilation with GTK+3 (EXPERIMENTAL!)" OFF)
	# TODO: option(WITH_PROFILING "Turn on profiling" OFF) # Set to true if compiler/linker should enable profiling
	# TODO: option(WITH_SVG2 "Compile with support for new SVG2 features" ON)
	# TODO: option(WITH_LPETOOL "Compile with LPE Tool and experimental LPEs enabled" OFF)
	# TODO: option(ENABLE_BINRELOC "Enable relocatable binaries" OFF)
	# missing: econf \
	# missing: 	$(use_enable static-libs static) \
	# missing: 	$(use_enable exif) \
	# missing: 	$(use_enable jpeg) \
	# missing: 	$(use_with inkjar) \

	local mycmakeargs=(
		-DENABLE_LCMS="$(usex lcms)"
		-DWITH_DBUS="$(usex dbus)"
		-DWITH_GNOME_GNOME_VFS="$(usex gnome)"
		-DWITH_SPELL="$(usex spell)"
		-DWITH_IMAGE_MAGICK="$(usex imagemagick)"
		-DWITH_LIBCDR="$(usex cdr)"
		-DWITH_LIBVISIO="$(usex visio)"
		-DWITH_LIBWPG="$(usex wpg)"
		-DWITH_NLS="$(usex nls)"
		-DWITH_OPENMP="$(usex openmp)"
		-DENABLE_POPPLER_CAIRO=on
	)

	cmake-utils_src_configure
}

# src_compile() {
# 	emake AR="$(tc-getAR)"
# }

src_install() {
	default
	cmake-utils_src_install

	prune_libtool_files
	python_optimize "${ED}"/usr/share/${PN}/extensions
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
	# fdo-mime_desktop_database_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	# fdo-mime_desktop_database_update
}
