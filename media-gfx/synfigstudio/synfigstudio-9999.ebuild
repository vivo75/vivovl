DESCRIPTION="Synfig: Film-Quality Vector Animation (main UI, SVN-sources)"
HOMEPAGE="http://synfig.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=dev-cpp/gtkmm-2.4
        media-gfx/synfig"

ESVN_REPO_URI="https://synfig.svn.sourceforge.net/svnroot/synfig/synfig-studio/trunk"
ESVN_PROJECT="${PN}"

inherit subversion

src_compile() {
	autoreconf -if
	econf || die
	emake || die
}

src_install() {
	make DESTDIR="${D}" install || die
}

