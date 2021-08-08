# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools eutils pam systemd

DESCRIPTION="An open source Remote Desktop Protocol server"
HOMEPAGE="http://www.xrdp.org/"
SRC_URI="https://github.com/neutrinolabs/xrdp/releases/download/v${PV}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="aac debug fuse ipv6 kerberos jpeg lame opus pam pixman pulseaudio"

RDEPEND="dev-libs/openssl:0=
	x11-libs/libX11:0=
	x11-libs/libXfixes:0=
	x11-libs/libXrandr:0=
	aac? ( media-libs/fdk-aac:0= )
	fuse? ( sys-fs/fuse:0= )
	jpeg? ( virtual/jpeg:0= )
	kerberos? ( virtual/krb5:0= )
	lame? ( media-sound/lame:0= )
	opus? ( media-libs/libopusenc:0= )
	pam? ( sys-libs/pam:0= )
	pixman? ( x11-libs/pixman:0= )
	pulseaudio? ( media-sound/pulseaudio:0= )
"
BDEPEND="${RDEPEND}
	virtual/pkgconfig
"
PDEPEND="
	|| (
		net-misc/tigervnc[server,xorgmodule]
		net-misc/xorgxrdp
	)
"

# does not work with gentoo version of freerdp
#	neutrinordp? ( net-misc/freerdp:0= )
# does not work
#	xrdpvr? ( media-video/ffmpeg:0= )

PATCHES=(
	"${FILESDIR}/${P}-flags.patch"
)

src_prepare() {
	default

	# disallow root login by default
	sed -i -e '/^AllowRootLogin/s/true/false/' sesman/sesman.ini || die

	eautoreconf
}

src_configure() {
	use kerberos && use pam \
		&& ewarn "Both kerberos & pam auth enabled, kerberos will take precedence."

	local myconf=(
		--localstatedir="${EPREFIX}"/var

		# -- authentication backends --
		# kerberos is inside !SESMAN_NOPAM conditional for no reason
		#   (is this still correct?)
		$(use pam || use kerberos || echo --enable-nopam)
		$(usex kerberos --enable-kerberos '')

		# pam_userpass is not in Gentoo at the moment
		--disable-pamuserpass

		# -- jpeg support --
		$(usex jpeg --enable-jpeg '')
		# the package supports explicit linking against libjpeg-turbo
		# (no need for -ljpeg compat)
		$(use jpeg && has_version 'media-libs/libjpeg-turbo:0' && echo --enable-tjpeg)

		# -- sound support --
		$(usex pulseaudio '--enable-simplesound --enable-loadpulsemodules' '')

		# -- others --
		$(usex debug --enable-xrdpdebug '')
		$(usex fuse --enable-fuse '')
		# $(usex neutrinordp --enable-neutrinordp '')
		# $(usex xrdpvr --enable-xrdpvr '')

		--with-systemdsystemunitdir="$(systemd_get_systemunitdir)"
		$(usex ipv6 --enable-ipv6 '')
		$(usex aac --enable-fdkaac '')
		$(usex opus --enable-opus '')
		$(usex lame --enable-mp3lame '')
		$(usex pixman --enable-pixman '')
	)

	econf "${myconf[@]}"
}

src_install() {
	default

	find "${ED}" -name '*.la' -delete || die

	# use our pam.d file since upstream's incompatible with Gentoo
	use pam && newpamd "${FILESDIR}"/xrdp-sesman.pamd xrdp-sesman
	# and our startwm.sh
	exeinto /etc/xrdp
	doexe "${FILESDIR}"/startwm.sh

	# own /etc/xrdp/rsakeys.ini
	: > rsakeys.ini
	insinto /etc/xrdp
	doins rsakeys.ini

	newinitd "${FILESDIR}/${PN}-initd" ${PN}
}

pkg_preinst() {
	# either copy existing keys over to avoid CONFIG_PROTECT whining
	# or generate new keys (but don't include them in binpkg!)
	if [[ -f "${EROOT}"/etc/xrdp/rsakeys.ini ]]; then
		cp {"${EROOT}","${ED}"}/etc/xrdp/rsakeys.ini || die
	else
		einfo "Running xrdp-keygen to generate new rsakeys.ini ..."
		LD_LIBRARY_PATH="${ED}"/usr/lib64/xrdp "${ED}"/usr/bin/xrdp-keygen xrdp "${ED}"/etc/xrdp/rsakeys.ini \
			|| die "xrdp-keygen failed to generate RSA keys"
	fi
}

pkg_postinst() {
	# check for use of bundled rsakeys.ini (installed by default upstream)
	if [[ $(cksum "${EROOT}"/etc/xrdp/rsakeys.ini) == '2935297193 1019 '* ]]
	then
		ewarn "You seem to be using upstream bundled rsakeys.ini. This means that"
		ewarn "your communications are encrypted using a well-known key. Please"
		ewarn "consider regenerating rsakeys.ini using the following command:"
		ewarn
		ewarn "  ${EROOT}/usr/bin/xrdp-keygen xrdp ${EROOT}/etc/xrdp/rsakeys.ini"
		ewarn
	fi

	elog "Various session types require different backend implementations:"
	elog "- sesman-Xvnc requires net-misc/tigervnc[server,xorgmodule]"
	elog "- sesman-Xorgrdp requires net-misc/xorgxrdp"
}
