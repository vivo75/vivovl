# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# TODO:
#     This ebuild emits a QA warning about executable stacks.  What I could
#     find out so far is that cc1 from this package will not include the
#     necessary line ".section ...  GNU-stack..." in its assembler output,
#     while the system's cc1 does.  And of course this package's cc1 will be
#     used to build its libraries.  (check if maybe vanilla gcc 4.0.1 just
#     didn't do that either.)

inherit eutils

DESCRIPTION="C and C++ Frontend for the Low Level Virtual Machine"
HOMEPAGE="http://llvm.org/"
SRC_URI="http://llvm.org/releases/2.4/llvm-gcc-4.2-${PV}.source.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"

IUSE=""

# we're not mirrored, fetch from homepage
RESTRICT="mirror"

DEPEND=">=sys-devel/llvm-2.5"
RDEPEND=">=sys-devel/llvm-2.5"

S="${WORKDIR}/llvm-gcc4.2-${PV}.source"

MY_LLVM_GCC_PREFIX=/usr/lib/llvm-gcc
# install everything in its own prefix to avoid collisions with regular gcc.
# this same variable is located in llvm-base's ebuild; keep them in sync

src_unpack() {
	unpack ${A}
	mkdir "${WORKDIR}/obj"

	# Note: normally (if you follow the build instructions), we would need to
	# pass --enable-llvm=objdir to ./configure in order to build the LLVM
	# back-end of GCC (without it we'd get a normal and boring compiler with no
	# LLVM).  But this option expects the objdir of llvm-base as a parameter,
	# which we don't have.  by not passing this option, we make ./configure
	# believe that we don't want to build the LLVM back-end, thus it won't
	# verify the required objdir.  Instead, the following sed magic enables
	# LLVM support in Makefile.in directly and tells it where to find the
	# things it needs

	# in gcc/Makefile.in LLVMOBJDIR needs to be set so the LLVM back-end gets
	# built, but its value is now meaningless.  LLVMSRCDIR is set to the same
	# to simulate a objdir == srcdir build of llvm-base.  LLVMBINPATH is only
	# used to find llvm-config

	cd "${S}"
	einfo "Enabling LLVM"
	sed -e 's,^LLVMSRCDIR.*,LLVMSRCDIR := dummy,' \
		-e 's,\$(LLVMSRCDIR)/include,/usr/include,g' \
		-e 's,^LLVMOBJDIR.*,LLVMOBJDIR := dummy,' \
		-e 's,\$(LLVMOBJDIR)/include,/usr/include,g' \
		-e 's,^LLVMBINPATH.*,LLVMBINPATH = /usr/bin,' \
		-i gcc/Makefile.in || die "sed failed"
}

src_compile() {
	local CONF_FLAGS=""

	cd "${WORKDIR}/obj"

	# TODO: shall we or not?
	#CONF_FLAGS="${CONF_FLAGS} --disable-threads"

	# this is to avoid this problem: http://llvm.org/bugs/show_bug.cgi?id=896
	CONF_FLAGS="${CONF_FLAGS} --disable-shared"
	
	# TODO: multilib can be enabled by applying a patch listed in the README.LLVM file
	if useq amd64; then
		CONF_FLAGS="${CONF_FLAGS} --disable-multilib"
	fi

	CONF_FLAGS="${CONF_FLAGS} --prefix=${MY_LLVM_GCC_PREFIX}"
	CONF_FLAGS="${CONF_FLAGS} --disable-nls"
	CONF_FLAGS="${CONF_FLAGS} --enable-languages=c,c++"
	CONF_FLAGS="${CONF_FLAGS} --infodir=/usr/share/info"
	CONF_FLAGS="${CONF_FLAGS} --mandir=/usr/share/man"

	"${S}"/configure ${CONF_FLAGS} || die "./configure failed"
	emake || die "emake failed"
	
	# bootstrapping is also possible but takes much longer for unknown benefits
	emake bootstrap || die "emake failed"
}

src_install() {
	cd "${WORKDIR}/obj"
	make DESTDIR="${D}" install || die "make install failed"

	einfo "Install symlinks in /usr/bin"
	dodir /usr/bin
	cd "${D}/usr/bin"
	for X in c++ g++ cpp gcc gcov gccbug; do
		ln -s "${MY_LLVM_GCC_PREFIX}/bin/$X" "llvm-$X" || die "ln failed"
	done

	einfo "Fixing man and info pages"

	# man7 contains gfld, gpl and fsf-funding.  those should be present on the
	# system already
	rm -rf "${D}/usr/share/man/man7"

	# install man1 pages with a llvm- prefix
	cd "${D}/usr/share/man/man1" || die "cd failed"
	for X in *; do
		mv "${X}" "llvm-${X}" || die "mv failed"
	done

	# ditto for info pages
	cd "${D}/usr/share/info" || die "cd failed"
	rm -f dir
	for X in *; do
		mv "${X}" "llvm-${X}"
	done
}

