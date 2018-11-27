# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils golang-vcs-snapshot golang-build

EGO_SRC=github.com/kubernetes/dns
EGO_PN=k8s.io/dns
EGIT_COMMIT="${PV}"

DESCRIPTION="Kubernetes DNS Services"
HOMEPAGE="https://github.com/kubernetes/dns"
SRC_URI="https://github.com/kubernetes/dns/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
IUSE=""

DEPEND="
	dev-lang/go
"
RDEPEND="
	sys-cluster/kubernetes
"

src_compile() {
	ego_pn_check
	set -- env GOPATH="${WORKDIR}/${P}:$(get_golibdir_gopath)" \
		go build -v -work -x ${EGO_BUILD_FLAGS} "${EGO_PN}/cmd/kube-dns"
	echo "$@"
	"$@" || die
}

src_install() {
	insinto /usr/lib/systemd/system
	doins $FILESDIR/kube-dns.service

	dobin kube-dns
}
