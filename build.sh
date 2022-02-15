#!/bin/bash

USAGE="""Usage: ./build.sh

Can be used to build the Docker images for: eIDAS-Node, IdP-Demo and Specific Proxy Service.

Optional:
    --tag\t\tSpecifiy the tag that should be used for all resulting images. Default is latest.
    --help\t\tDisplay this help.
"""

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

declare -a IMAGES=("eidas-node" "idp-demo" "specific-proxy-service")
TAG=latest

prepare() {
    while [[ $# -gt 0 ]]
    do
        key="$1"

        case $key in
            --tag)
            TAG=$2
            shift
            shift
            ;;
            --help)
            printf "${USAGE}"
            exit 0
            ;;
            *) # unknown option
            shift
            ;;
        esac
    done
}

prepareBaseImage() {
    docker build -t eidas-node-base -f $DIR/Dockerfile.base $DIR/.
}

buildImage() {
    local IMAGE_TO_BE_BUILT=$1
    local TAG=$2

    docker build -t ecsec/$IMAGE_TO_BE_BUILT:$TAG -f $DIR/Dockerfile.$IMAGE_TO_BE_BUILT $DIR/.
}

buildImages() {
    local IMAGES_TO_BE_BUILT=("$@")

    for IMAGE_TO_BE_BUILT in ${IMAGES_TO_BE_BUILT[*]};
    do
        buildImage $IMAGE_TO_BE_BUILT $TAG
    done
}

prepare ${@}
prepareBaseImage
buildImages ${IMAGES[*]}
