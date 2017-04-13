# Copyright 2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

DESCRIPTION="Improved JPEG encoder based on libjpeg-turbo"
HOMEPAGE="https://github.com/mozilla/mozjpeg"
SRC_URI="https://github.com/mozilla/${PN}/releases/download/v${PV}-pre/${P}-release-source.tar.gz"

LICENSE="BSD IJG"
SLOT="0"
KEYWORDS="amd64 ~x86"
IUSE=""

RDEPEND="
	media-libs/libjpeg-turbo
	sys-libs/zlib"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${PN}

src_configure() {
	econf \
		--bindir=${EROOT}/usr/libexec/${PN} \
		--program-prefix=moz \
		--without-turbojpeg \
		--without-java
}

src_install() {
	emake install DESTDIR="${D}"

	# cleanup conflicting (with libjpeg-turbo) files
	rm -r "${ED}/usr/$(get_libdir)" "${ED}/usr/include" || die "unable to cleanup"
	newlib.so ${S}/.libs/libjpeg.so.62.2.0 libmozjpeg.so

	# create a wrapper for libmozjpeg executables, so they use
	# our library and not the libjpeg-turbo one
	mkdir -p ${ED}/usr/bin/ || die "missing /usr/bin/"
	echo -e '#!/bin/sh\nLD_PRELOAD=libmozjpeg.so "'"${EPREFIX}"'/usr/libexec/mozjpeg/$(basename $0)" "$@"' > "${ED}"/usr/bin/mozjpeg
	chmod 0755 "${ED}"/usr/bin/mozjpeg
	for x in "${ED}"/usr/libexec/mozjpeg/* ; do
        ln -s mozjpeg ${ED}/usr/bin/${x##*/}
	done

	dodoc README.md README-mozilla.txt usage.txt wizard.txt
}
