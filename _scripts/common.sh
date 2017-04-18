#! /bin/bash

# define known variables
REPO=vivovl
REPO_PATH=$( portageq get_repo_path / ${REPO} )
HTML=$( mktemp /tmp/${CATEGORY}--${PN}.XXXXXX )
DISTDIR="$( portageq envvar DISTDIR )"

export DISTDIR HTML REPO REPO_PATH

check_ver() {
    local CATEGORY=${1}
    local PN=${2}
    local PV=${3}
    ACCEPT_KEYWORDS="~amd64 **" \
    emerge -p --nodeps --color=n ~${CATEGORY}/${PN}-${PV} \
    &> /dev/null
}

