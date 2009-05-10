DESCRIPTION="ETL is a multiplatform class and template library designed to
complement and supplement the C++ STL. (SVN-sources)"
HOMEPAGE="http://synfig.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""

PROVIDE="virtual/ETL"

ESVN_REPO_URI="https://synfig.svn.sourceforge.net/svnroot/synfig/ETL/trunk/"
ESVN_PROJECT="${PN}"

inherit eutils
inherit subversion

src_compile() {
	autoreconf -if
	econf || die
}

src_install() {
	make DESTDIR="${D}" install || die
}

