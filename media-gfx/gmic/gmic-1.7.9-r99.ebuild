# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils bash-completion-r1 git-r3 qmake-utils

DESCRIPTION="GREYC's Magic Image Converter"
HOMEPAGE="http://gmic.eu/ https://github.com/dtschump/gmic"
SRC_URI="http://gmic.eu/files/source/${PN}_${PV}.tar.gz"
GMICQT_REPO_DIR="https://github.com/c-koi/gmic-qt.git"

LICENSE="CeCILL-2 FDL-1.3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+cli ffmpeg fftw +gimp graphicsmagick jpeg +krita opencv openexr openmp +png static-libs tiff X zlib"
REQUIRED_USE="|| ( cli gimp )"

COMMON_DEPEND="
	fftw? ( sci-libs/fftw:3.0[threads] )
	gimp? ( >=media-gfx/gimp-2.4.0 )
	graphicsmagick? ( media-gfx/graphicsmagick )
	jpeg? ( virtual/jpeg:0 )
	krita? ( media-gfx/krita )
	net-misc/curl
	opencv? ( >=media-libs/opencv-2.3.1a-r1 )
	openexr? (
		media-libs/ilmbase
		media-libs/openexr
	)
	png? ( media-libs/libpng:0= )
	tiff? ( media-libs/tiff:0 )
	X? (
		x11-libs/libX11
		x11-libs/libXext
	)
	zlib? ( sys-libs/zlib )
	dev-qt/qtwidgets:5
	dev-qt/qtnetwork:5"

RDEPEND="${COMMON_DEPEND}
	ffmpeg? ( media-video/ffmpeg:0 )
	gimp? ( !media-plugins/gimp-gmic )
"
DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}"/${P}-flags.patch
	"${FILESDIR}"/${P}-man.patch
)

pkg_pretend() {
	if use openmp ; then
		tc-has-openmp || die "Please switch to an openmp compatible compiler"
	fi

	if ! test-flag-CXX -std=c++11 ; then
		die "You need at least GCC 4.7.x or Clang >= 3.3 for C++11-specific compiler flags"
	fi
}

src_unpack() {
	default
	#EGIT_CHECKOUT_DIR="${S}/gmic-qt" git-r3_src_unpack
	#EGIT_COMMIT="${WINE_COMMIT}"
	git-r3_fetch "${GMICQT_REPO_DIR}"
	# "${STAGING_COMMIT}"
	git-r3_checkout "${GMICQT_REPO_DIR}" "${WORKDIR}/gmic-qt"
	# this symlink is needed to build gmic-qt
	ln -s ${WORKDIR}/${P} "${WORKDIR}/${PN}"
}


src_configure() {
	local x
	local luse
	local quse
	local mycmakeargs=(
		-DBUILD_LIB=ON
		-DBUILD_LIB_STATIC=$(usex static-libs)
		-DBUILD_CLI=$(usex cli)
		-DBUILD_MAN=$(usex cli)
		-DBUILD_PLUGIN=$(usex gimp)
		-DENABLE_X=$(usex X)
		-DENABLE_FFMPEG=$(usex ffmpeg)
		-DENABLE_FFTW=$(usex fftw)
		-DENABLE_GRAPHICSMAGICK=$(usex graphicsmagick)
		-DENABLE_JPEG=$(usex jpeg)
		-DENABLE_OPENCV=$(usex opencv)
		-DENABLE_OPENEXR=$(usex openexr)
		-DENABLE_OPENMP=$(usex openmp)
		-DENABLE_PNG=$(usex png)
		-DENABLE_TIFF=$(usex tiff)
		-DENABLE_ZLIB=$(usex zlib)
	)

	local CMAKE_BUILD_TYPE="Release"
	cmake-utils_src_configure
	pushd "${WORKDIR}/gmic-qt"
		for x in cli:none gimp:gimp krita:krita ; do
		luse=${x%:*}
		quse=${x#*:}
		if use ${luse} ; then
			eqmake5 HOST=${quse} && mv Makefile Makefile.${quse} || die
		fi
		done
	popd
}

src_compile() {
	local x
	local luse
	local quse

	default
	pushd "${WORKDIR}/gmic-qt"
	for x in cli:none gimp:gimp krita:krita ; do
		luse=${x%:*}
		quse=${x#*:}
		if use ${luse} ; then
			emake -f Makefile.${quse}
			# emake clean
		fi
	done
	popd
}

src_install() {
	cmake-utils_src_install
	dodoc README
    use cli && newbashcomp resources/${PN}_bashcompletion.sh ${PN}
	pushd ${WORKDIR}/gmic-qt
	if use cli; then
		exeinto /usr/bin
		doexe gmic_qt
    fi
	if use gimp; then
		exeinto $(gimptool-2.0 --gimpplugindir)/plug-ins
		doexe gmic_gimp_qt
	fi
	if use krita; then
		exeinto /usr/$(get_libdir)/kritaplugins
		doexe gmic_krita_qt
	fi
	popd
}
