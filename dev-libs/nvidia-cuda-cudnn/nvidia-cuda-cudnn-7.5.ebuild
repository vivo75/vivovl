# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PKG="cudnn-7.5-linux-x64-v5.1"
SRC_URI="${PKG}.tgz"

DESCRIPTION="NVIDIA cuDNN GPU Accelerated Deep Learning"
HOMEPAGE="https://developer.nvidia.com/cuDNN"

SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
RESTRICT="fetch"

DEPEND="dev-util/nvidia-cuda-toolkit"

S="${WORKDIR}/cuda"

# WTF {,32,64} does not work?
QA_PRESTRIPPED=/opt/cuda/lib64/libcudnn.so.5.1.3

pkg_nofetch() {
	einfo "Please download"
	einfo "  - cudnn-7.5-linux-x64-v5.1.tgz"
	einfo "from ${HOMEPAGE} and place them in ${DISTDIR}"
}

src_install() {
	local cudadir=/opt/cuda
	local ecudadir="${EPREFIX}"${cudadir}

	dodir ${cudadir}
	mv * "${ED}"${cudadir} || die

}
