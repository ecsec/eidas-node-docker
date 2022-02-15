#!/bin/bash

USAGE="""Usage: ./build.sh

Can be used to build the Docker images for: eIDAS-Node, IdP-Demo and Specific Proxy Service.

Optional:
    --image\t\tSpecify a specific image to be built. Can be: 'eidas-node', 'idp-demo' and 'specific-proxy-service'.
    --tag\t\tSpecifiy the tag that should be used for all resulting images. Default is latest.
    --skip-base\t\tIndicates that the base image is already built and will be skipped.
    --help\t\tDisplay this help.
"""

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
declare -a IMAGES=("eidas-node" "idp-demo" "specific-proxy-service")
declare -a IMAGES_TO_BE_BUILT
SKIP_BASE_IMAGE_BUILD=false
TAG=latest

prepareImagesToBeBuilt() {
    while [[ $# -gt 0 ]]
    do
        key="$1"

        case $key in
            --image)
            IMAGES_TO_BE_BUILT=$2
            shift
            shift
            ;;
            --skip-base)
            SKIP_BASE_IMAGE_BUILD=true
            shift
            ;;
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

    if [ ${#IMAGES_TO_BE_BUILT[@]} = 0 ] ; then
        IMAGES_TO_BE_BUILT=("${IMAGES[@]}")
    fi

    echo "The following images will be built: ${IMAGES_TO_BE_BUILT[*]}"
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

prepareImagesToBeBuilt ${@}

if [ "$SKIP_BASE_IMAGE_BUILD" == false ]; then
    prepareBaseImage
fi

buildImages ${IMAGES_TO_BE_BUILT[*]}
