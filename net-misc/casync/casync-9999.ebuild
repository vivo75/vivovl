# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit meson

DESCRIPTION="A tool for distributing file system images"
HOMEPAGE="http://0pointer.net/blog/casync-a-tool-for-distributing-file-system-images.html"

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://github.com/systemd/${PN}.git"
	inherit git-r3
else
	SRC_URI="https://github.com/systemd/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
fi

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="fuse man selinux"

RDEPEND="
	app-arch/xz-utils
	app-arch/zstd
	dev-libs/openssl
	sys-apps/acl
	dev-util/ninja
	sys-apps/attr
	sys-libs/zlib
	fuse? ( sys-fs/fuse )
	selinux? ( sys-libs/libselinux )
"
DEPEND="${RDEPEND}
	>=dev-util/meson-0.41.0
	man? ( dev-python/sphinx )
"

src_configure() {
	local emesonargs=(
		-Dfuse=$(usex fuse true false)
		-Dman=$(usex man true false)
		-Dselinux=$(usex selinux true false)
	)
	meson_src_configure
}
