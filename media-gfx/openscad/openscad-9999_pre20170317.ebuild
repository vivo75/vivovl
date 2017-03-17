# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="The Programmers Solid 3D CAD Modeller"
HOMEPAGE="http://www.openscad.org/"

if [[ ${PV#9999} != ${PV} ]] ; then
	inherit eutils git-r3 qmake-utils
	SRC_URI=
	EGIT_REPO_URI="https://github.com/openscad/openscad.git"
	EGIT_COMMIT="714e14e4a6b8eb62677784de6213e1cde79a6554"
else
	inherit eutils qmake-utils
	MY_PV="2015.03-2"
	SRC_URI="http://files.openscad.org/${PN}-${MY_PV}.src.tar.gz"
fi

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

CDEPEND="media-gfx/opencsg
	sci-mathematics/cgal
	dev-qt/qtcore:4
	dev-qt/qtgui:4[-egl]
	dev-qt/qtopengl:4[-egl]
	dev-cpp/eigen:3
	dev-libs/glib:2
	dev-libs/gmp:0=
	dev-libs/mpfr:0=
	dev-libs/boost:=
	media-libs/fontconfig:1.0
	media-libs/freetype:2
	media-libs/glew:*
	media-libs/harfbuzz
	x11-libs/qscintilla:=[qt4(-)]"
DEPEND="${CDEPEND}"
RDEPEND="${CDEPEND}"
[[ ${PV#9999} == ${PV} ]] && S="${WORKDIR}/${PN}-${MY_PV}"

src_unpack() {
	git-r3_src_unpack
}

src_prepare() {
	#Use our CFLAGS (specifically don't force x86)
	sed -i "s/QMAKE_CXXFLAGS_RELEASE = .*//g" ${PN}.pro  || die
	sed -i "s/\/usr\/local/\/usr/g" ${PN}.pro || die

	eapply_user
}

src_configure() {
	eqmake4 "${PN}.pro"
}

src_install() {
	emake install INSTALL_ROOT="${D}"
	einstalldocs
}
