# Copyright 2005-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-utils flag-o-matic toolchain-funcs xdg-utils

inherit git-r3
EGIT_REPO_URI="https://github.com/vivo75/poppler.git"
#EGIT_BRANCH="svg-0.81.0"
EGIT_TAG="0.81.1-svg"
SLOT="0/9999"
KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
#SLOT="0/91"   # CHECK THIS WHEN BUMPING!!! SUBSLOT IS libpoppler.so SOVERSION
MY_PN=${PN%-svg}

DESCRIPTION="Fork of poppler for pdftosvg support"
HOMEPAGE="https://poppler.freedesktop.org/"

LICENSE="GPL-2"
IUSE="debug +jpeg +jpeg2k +lcms nss png tiff"

# No test data provided
RESTRICT="test"

BDEPEND="
	dev-util/glib-utils
	virtual/pkgconfig
"
DEPEND="
	media-libs/fontconfig
	media-libs/freetype
	sys-libs/zlib
	jpeg? ( virtual/jpeg:0 )
	jpeg2k? ( >=media-libs/openjpeg-2.3.0-r1:2= )
	lcms? ( media-libs/lcms:2 )
	nss? ( >=dev-libs/nss-3.19:0 )
	png? ( media-libs/libpng:0= )
	tiff? ( media-libs/tiff:0 )
"
DOCS=( AUTHORS NEWS README.md README-XPDF )

PATCHES=(
	"${FILESDIR}/${MY_PN}-0.28.1-fix-multilib-configuration.patch"
	"${FILESDIR}/${MY_PN}-0.57.0-disable-internal-jpx.patch"
)

src_prepare() {
	cmake-utils_src_prepare

	# Clang doesn't grok this flag, the configure nicely tests that, but
	# cmake just uses it, so remove it if we use clang
	if [[ ${CC} == clang ]] ; then
		sed -e 's/-fno-check-new//' -i cmake/modules/PopplerMacros.cmake || die
	fi

	if ! grep -Fq 'cmake_policy(SET CMP0002 OLD)' CMakeLists.txt ; then
		sed -e '/^cmake_minimum_required/acmake_policy(SET CMP0002 OLD)' \
			-i CMakeLists.txt || die
	else
		einfo "policy(SET CMP0002 OLD) - workaround can be removed"
	fi

	# we need to up the C++ version, bug #622526, #643278
	append-cxxflags -std=c++14
}

src_configure() {
	xdg_environment_reset
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=OFF
		-DUSE_FLOAT=ON
		-DENABLE_QT5=OFF
		-DBUILD_GTK_TESTS=OFF
		-DBUILD_QT5_TESTS=OFF
		-DBUILD_CPP_TESTS=OFF
		-DENABLE_SPLASH=ON
		-DENABLE_ZLIB=ON
		-DENABLE_ZLIB_UNCOMPRESS=OFF
		-DENABLE_UNSTABLE_API_ABI_HEADERS=ON
		-DUSE_FLOAT=OFF
		-DWITH_Cairo=OFF
		-DENABLE_LIBCURL=OFF
		-DENABLE_CPP=OFF
		-DWITH_JPEG=$(usex jpeg)
		-DENABLE_DCTDECODER=$(usex jpeg libjpeg none)
		-DENABLE_LIBOPENJPEG=$(usex jpeg2k openjpeg2 none)
		-DENABLE_CMS=$(usex lcms lcms2 none)
		-DWITH_NSS3=$(usex nss)
		-DWITH_PNG=$(usex png)
		-DWITH_TIFF=$(usex tiff)
		-DENABLE_UTILS=ON
	)

	cmake-utils_src_configure
}

src_install() {
	exeinto /opt/bin
	# $BUILD_DIR came from cmake-utils eclass
	newexe ${BUILD_DIR}/utils/pdftohtml pdftosvg
}
