EAPI=6
PYTHON_COMPAT=( python3_{3,4,5,6} )

inherit cmake-utils

DESCRIPTION=""
HOMEPAGE="https://github.com/cutelyst/cutelyst/"
KEYWORDS=""
if [[ ${PV} = "9999" ]] ; then
	inherit git-r3
	EGIT_BRANCH="master"
	EGIT_REPO_URI="https://github.com/cutelyst/cutelyst.git"
else
	KEYWORDS="~x86 ~amd64 ~arm"
	SRC_URI="https://github.com/cutelyst/cutelyst/archive/v${PV}.tar.gz -> ${P}.tar.gz"
fi
IUSE="docs jemalloc memcached +test +uwsgi"

LICENSE="LGPL-2"
SLOT="0"

RDEPEND=">=dev-qt/qtcore-5.6
	>=dev-qt/qtgui-5.6
	>=dev-qt/qthelp-5.6
	>=dev-qt/qtnetwork-5.6
	>=dev-qt/qtsql-5.6
	dev-libs/grantlee:5
	docs? ( app-doc/doxygen )
	jemalloc? ( dev-libs/jemalloc )
	memcached? ( net-misc/memcached )
	uwsgi? ( www-servers/uwsgi )"
DEPEND="${RDEPEND}"

src_configure() {
	
	local mycmakeargs=(
		-DPLUGIN_STATICCOMPRESSED=ON
		-DBUILD_TESTS=$(usex test)
		-DUSE_JEMALLOC=$(usex jemalloc)
		-DPLUGIN_MEMCACHED=$(usex memcached)
	)
	cmake-utils_src_configure
}
