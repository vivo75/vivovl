# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# kate: encoding utf-8; eol unix
# kate: indent-width 4; mixedindent off; replace-tabs off; remove-trailing-space on; space-indent off
# kate: word-wrap-column 80; word-wrap on

EAPI=2

inherit toolchain-funcs cmake-utils
[ "$PV" == "9999" ] && inherit git

MY_P=${P/f/F}

DESCRIPTION="An open source general purpose untyped language written in C++"
HOMEPAGE="http://falconpl.org/"

if [ "$PV" != "9999" ]; then
	SRC_URI="http://falconpl.org/project_dl/_official_rel/${MY_P}.tar.bz2"
else
	SRC_URI=""
	EGIT_BRANCH="master"
	EGIT_REPO_URI="git://github.com/vivo75/falcon-core.git"
fi

RDEPEND="dev-libs/libpcre
	sys-libs/zlib"
DEPEND="${RDEPEND}
	>=dev-util/cmake-2.6.1"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug"

#S=${WORKDIR}/${MY_P%.*}
S=${WORKDIR}/${MY_P}

src_unpack() {
	if [ "${PV}" != "9999" ]; then
		unpack ${MY_P}.tar.bz2
		cd "${S}"
	else
		git_src_unpack
		cd "${S}"
	fi
}

src_configure() {
	mycmakeargs=""
	#mycmakeargs="${mycmakeargs} $(cmake-utils_use_enable pdf PDF)"
	mycmakeargs="${mycmakeargs} -DFALCON_INSTALL_DIR_LIB=$(get_libdir)"
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	dodoc AUTHORS ChangeLog README
	[ -f TODO ] && dodoc TODO
}

#TODO:
# src_test() {
# 	FALCON_LOAD_PATH=".;${S}/devel/release/build/core/rtl" \
# 		"${S}/devel/release/build/core/clt/faltest/faltest" \
# 		-d "${S}/core/tests/testsuite" \
# 		|| die "faltest failed"
# }
