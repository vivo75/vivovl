# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="An open source Remote Desktop Protocol server; connector for local Xorg session"
HOMEPAGE="http://www.xrdp.org/"
SRC_URI="https://github.com/neutrinolabs/xorgxrdp/releases/download/v${PV}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	>=net-misc/xrdp-0.9.14:0=
	x11-base/xorg-server:0=
"
DEPEND=${RDEPEND}
BDEPEND="
	dev-lang/nasm
	virtual/pkgconfig
"
