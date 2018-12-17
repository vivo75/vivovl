# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils bash-completion-r1

if [[ ${PV} == "9999" ]]; then
	EGIT_REPO_URI="https://github.com/dtschump/gmic.git"
	inherit git-r3
else
	SRC_URI="http://gmic.eu/files/source/${PN}_${PV}.tar.gz
	         https://github.com/c-koi/gmic-qt/archive/v.${PV//./}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

DESCRIPTION="GREYC's Magic Image Converter"
HOMEPAGE="http://gmic.eu/ https://github.com/dtschump/gmic"

LICENSE="CeCILL-2 FDL-1.3"
SLOT="0"
IUSE="ffmpeg fftw graphicsmagick jpeg opencv openexr openmp png static-libs tiff X zlib"

# -- The following OPTIONAL packages have been found:
# 
#  * PkgConfig
#  * CURL
#  * OpenMP, A low-level parallel execution library, <http://openmp.org/wp/>
#    Optionally used by gmic-qt
#  * X11

# -- The following REQUIRED packages have been found:
# 
#  * Qt5Core
#  * Qt5Gui
#  * Qt5Widgets
#  * Qt5Network
#  * Qt5 (required version >= 5.2.0)
#  * Qt5LinguistTools
#  * PNG
#  * ZLIB
#  * FFTW3

COMMON_DEPEND="
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/linguist-tools:5
	dev-qt/qtnetwork:5
	dev-qt/qtwidgets:5
	sci-libs/fftw:3.0[threads]
	>=media-gfx/gimp-2.9.0
	virtual/jpeg:0
	>=media-libs/opencv-2.3.1a-r1
	media-libs/ilmbase
	media-libs/openexr
	media-libs/libpng:0=
	media-libs/tiff:0
	x11-libs/libX11
	x11-libs/libXext
	sys-libs/zlib"
RDEPEND="${COMMON_DEPEND}
	ffmpeg? ( media-video/ffmpeg:0 )
"
DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
"

S="${WORKDIR}/gmic-qt-v.${PV//./}"

pkg_pretend() {
	if use openmp ; then
		tc-has-openmp || die "Please switch to an openmp compatible compiler"
	fi

	if ! test-flag-CXX -std=c++11 ; then
		die "You need at least GCC 4.7.x or Clang >= 3.3 for C++11-specific compiler flags"
	fi
}

src_prepare() {
	# TODO: fix translations
	echo '<RCC><qresource prefix="/" /></RCC>' > ${S}/translations.qrc
	default
}

src_configure() {
	local mycmakeargs=(
		-DGMIC_PATH="${WORKDIR}/${P}/src"
		-DBUILD_LIB=ON
	)

	local CMAKE_BUILD_TYPE="Release"
	cmake-utils_src_configure
}

src_install() {
	#cmake-utils_src_install
	exeinto /usr/lib/gimp/2.0/plug-ins/
	doexe "${BUILD_DIR}"/gmic_gimp_qt
	#dodoc README
	#newbashcomp resources/${PN}_bashcompletion.sh ${PN}
}
