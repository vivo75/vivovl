# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# kate: encoding utf-8; eol unix
# kate: indent-width 4; mixedindent off; replace-tabs off; space-indent off
# kate: remove-trailing-space on; word-wrap-column 120; word-wrap off

inherit multilib

MY_P=${P/_/-}
IUSE="allegro gpm mysql odbc slang X"
DESCRIPTION="An extended implementation of the Clipper dialect of the xBase language family"
HOMEPAGE="http://www.harbour-project.org/"
SRC_URI="mirror://sourceforge/${PN}-project/${MY_P}.tar.bz2"

LICENSE="harbour"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~ia64 ~ppc ~ppc64 ~ppc-macos ~s390 ~sparc ~x86"

RDEPEND="virtual/libc
	sys-libs/ncurses
	allegro? ( media-libs/allegro )
	gpm? ( sys-libs/gpm )
	odbc? ( dev-db/unixODBC )
	slang? ( sys-libs/slang )
	mysql? ( virtual/mysql )
	X? ( x11-libs/libX11
		 x11-libs/libXmu
		 x11-libs/libXext
		 x11-libs/libXt
		 x11-libs/libXpm
		 media-libs/freetype )"

DEPEND="${RDEPEND}
	sys-devel/bison"

S="${WORKDIR}/${MY_P}"

set_vars() {
	export HB_LIBDIRNAME="${1}"
	export C_USR="${CFLAGS}"
	export HB_GTALLEG=`useq allegro && echo yes`
	export HB_GPM_MOUSE=`useq gpm && echo yes`
	export HB_WITHOUT_GTSLN=`useq slang || echo yes`
	export HB_WITHOUT_X11=`useq X || echo yes`
	if use mysql ; then
		HB_INC_MYSQL="$(mysql_config --include)"
		export HB_INC_MYSQL=${HB_INC_MYSQL#-I}
		export L_USR="${L_USR} $(mysql_config --libs)"
	fi
	export HB_INSTALL_PREFIX=/usr
}

src_compile() {
	chmod a+x make_gnu.sh || die
	set_vars "$(get_libdir)" || die
	./make_gnu.sh || die
	pushd contrib
	for d in *; do
		[ -d "${d}" ] && mkdir -p "${d}"/obj/gcc/
	done
	./make_gcc_all.sh
	popd
}

src_test() {
	bin/gcc/hbtest
	einfo "In general, the package works if 'Total calls passed' figure above"
	einfo "is 90% or greater."
}

src_install() {
	local libdir=$(get_libdir)
	#make install for the package does not create dirs if they are missing for some reason
	dodir /usr/bin
	dodir /usr/include/harbour
	dodir /usr/${libdir}/harbour
	dodir /usr/share/doc/${PF}
	export _DEFAULT_BIN_DIR=${ROOT}/usr/bin
	export _DEFAULT_INC_DIR=${ROOT}/usr/include/harbour
	export _DEFAULT_LIB_DIR=${ROOT}/usr/${libdir}/harbour
	export HB_BIN_INSTALL=${D}${_DEFAULT_BIN_DIR}
	export HB_INC_INSTALL=${D}${_DEFAULT_INC_DIR}
	export HB_LIB_INSTALL=${D}${_DEFAULT_LIB_DIR}
	set_vars "${libdir}" || die
	./make_gnu.sh install || die
	pushd contrib
	./make_gcc_all.sh install || die
	popd
	
	dodir /etc/harbour
	install -m644 source/rtl/gtcrs/hb-charmap.def ${D}/etc/harbour/hb-charmap.def
	cat > ${D}/etc/harbour.cfg <<EOF
CC=gcc
CFLAGS=-c -I${_DEFAULT_INC_DIR} ${CFLAGS}
VERBOSE=YES
DELTMP=YES
EOF
	
# 	# rebuild tools with shared libs
# 	unset HB_GTALLEG
# 	L_USR="-L${HB_LIB_INSTALL} -l${PN} -lncurses"
# 	use slang && L_USR="${L_USR} -lslang"
# 	use gpm && L_USR="${L_USR} -lgpm"
# 	use X && L_USR="${L_USR} -L/usr/X11R6/lib -lX11"
# 	use mysql && L_USR="${L_USR} $(mysql_config --libs)"
# 	export L_USR
# 	export PRG_USR="\"-D_DEFAULT_INC_DIR='${_DEFAULT_INC_DIR}'\""
# 	for utl in hbdoc hbextern hbmake hbrun hbtest
# 	do
# 		./make_gnu.sh -C utils/${utl} clean
# 		./make_gnu.sh -C utils/${utl} install
# 	done
# 
# 	# could not find them anymore in tarball
# 	#dosym xbscript /usr/bin/pprun
# 	#dosym xbscript /usr/bin/xprompt
# 
# 	# remove unused files
# 	# TODO: reactivate me
# 	#rm -f ${HB_BIN_INSTALL}/{hbdoc,hbtest}

	# TODO: use LINGUAS
	dodoc ChangeLog COPYING doc/*.txt
	docinto en
	dodoc doc/en/*.txt
# 	docinto es
# 	dodoc doc/es/*.txt
# 	docinto ct
# 	dodoc doc/en/ct/*.txt

	doman doc/man/* || die "doman"

}
