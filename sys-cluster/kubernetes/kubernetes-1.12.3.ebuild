# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

DESCRIPTION="Production-Grade Container Orchestration"
HOMEPAGE="kubernetes.io"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="
	net-misc/myip
	sys-cluster/kube-apiserver
	sys-cluster/kube-controller-manager
	sys-cluster/kube-proxy
	sys-cluster/kube-scheduler
	sys-cluster/kubectl
	sys-cluster/kubelet
"

src_unpack() {
	mkdir -p "${S}"
}

src_install() {
	local KUBE_SERVICES=$(find "${FILESDIR}/" -name 'kube*.service' -type f)

	dodir /etc/kubernetes
	insinto /etc/kubernetes
	doins "${FILESDIR}/environment"
	doins "${FILESDIR}/kubeconfig"
	keepdir /etc/kubernetes/manifests

	insinto /usr/lib/systemd/system
	for service in $KUBE_SERVICES; do
		doins $service
	done
}
