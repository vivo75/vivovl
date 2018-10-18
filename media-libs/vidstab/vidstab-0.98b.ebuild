# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

inherit cmake-utils cmake-multilib

DESCRIPTION="Video stabilization library"
HOMEPAGE="http://public.hronopik.de/vid.stab/"
SRC_URI="https://github.com/georgmartius/vid.stab/archive/release-${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/vid.stab-release-${PV}"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~x86"
IUSE=""

DEPEND="media-video/ffmpeg
	media-video/transcode"

RDEPEND=""
