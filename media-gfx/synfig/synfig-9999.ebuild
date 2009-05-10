DESCRIPTION="Synfig: Film-Quality Vector Animation (core engine, SVN-sources)"
HOMEPAGE="http://synfig.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="tiff jpeg png freetype fontconfig openexr ffmpeg debug"

DEPEND="dev-cpp/libxmlpp
    dev-libs/libsigc++
	sys-devel/libtool
	dev-util/cvs
	png? ( media-libs/libpng )
	tiff? ( media-libs/tiff )
	jpeg? ( media-libs/jpeg )
	imagemagick? ( media-gfx/imagemagick )
	freetype? ( media-libs/freetype )
	fontconfig? ( media-libs/fontconfig )
	openexr? ( media-libs/openexr )
	ffmpeg? ( media-video/ffmpeg )
    dev-cpp/ETL"

ESVN_REPO_URI="https://synfig.svn.sourceforge.net/svnroot/synfig/synfig-core/trunk"
ESVN_PROJECT="${PN}"

inherit subversion


src_compile() {
	libtoolize --ltdl --copy -f
	autoreconf -if
	econf \
	$(use_enable ffmpeg) \
	$(use_enable libdv) \
	$(use_enable imagemagick) \
	$(use_enable ffmpeg libavcodec) \
	$(use_enable freetype) \
	$(use_enable debug) \
	|| die
	emake || die
}

src_install() {
	make DESTDIR="${D}" install || die
}

