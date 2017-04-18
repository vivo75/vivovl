#! /bin/bash

# define known variables

x="${0##*/}"
CATEGORY=${x%--*}
PN=${x#*--}
unset x

REPO=vivovl
REPO_PATH=$( portageq get_repo_path / ${REPO} )
HTML=$( mktemp /tmp/${CATEGORY}--${PN}.XXXXXX )
DISTDIR="$( portageq envvar DISTDIR )"

export CATEGORY DISTDIR HTML PN REPO REPO_PATH

check_ver() {
    local CATEGORY=${1}
    local PN=${2}
    local PV=${3}
    ACCEPT_KEYWORDS="~amd64 **" \
    emerge -p --nodeps --color=n ~${CATEGORY}/${PN}-${PV} \
    &> /dev/null
}

message_and_cleanup() {
    local A="${1}"
    local LAST_VERSION="$(equery --quiet which -e ${CATEGORY}/${PN} | head -n1)"
    local NEXT_VERSION="${REPO_PATH}/${CATEGORY}/${PN}/${PN}-${PV}.ebuild"
    mv ${A} "${DISTDIR}"
    einfo "Found new version \"${PV}\""
    einfo "Try the following commands for a preliminary test:"
    echo "cp -i \\"
    echo " ${LAST_VERSION} \\"
    echo " ${NEXT_VERSION}"
    einfo ""
    echo "ebuild ${NEXT_VERSION} manifest install clean"
}
