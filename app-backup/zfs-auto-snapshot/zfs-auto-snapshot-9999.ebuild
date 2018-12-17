# Copyright 2017 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit git-r3

DESCRIPTION="zfs-auto-snapshot service for Linux"
HOMEPAGE="https://github.com/zfsonlinux/zfs-auto-snapshot"
EGIT_REPO_URI="https://github.com/zfsonlinux/zfs-auto-snapshot.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="sys-fs/zfs"

IUSE="+minimal"

src_install() {

	emake DESTDIR="${D}" PREFIX=/usr install || die

	if use minimal; then
		einfo "Removing cron files due to \"minimal\" use enabled"
		rm -rfv "${D}"/etc/cron*
	fi
}
