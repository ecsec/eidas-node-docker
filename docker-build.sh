#!/bin/sh

#NO_GIT_TAG=1
REG_NAME=public.docker.ecsec.de
PREFIX=ecsec/eidas

DOCKER_DIR=docker/
NAME=eidas-node

if [ ! $1 ]; then
    echo "USAGE:   $0 <sem-version> [<version-alias>*]"
    echo "EXAMPLE: $0 1.0.1"
    echo "EXAMPLE: $0 1.0.1 1.0.1-wildfly-25.0.0"
    exit 1
fi


if [ -f ./$DOCKER_DIR/.env ]; then
    # loading overriding env vars
    . ./$DOCKER_DIR/.env
fi


docker build --build-arg EIDAS_NODE_VERSION=${EIDAS_NODE_VERSION} \
             --build-arg WILDFLY_VERSION=${WILDFLY_VERSION} \
             -t $REG_NAME/$PREFIX/$NAME $DOCKER_DIR || exit 1

if [ $1 ]; then
    echo "Publishing version=$1 ..."
    if [ ! $NO_GIT_TAG ]; then
        git tag v$1 || exit 1
        git push origin v$1 || exit 1
    fi

    docker tag $REG_NAME/$PREFIX/$NAME:latest $REG_NAME/$PREFIX/$NAME:$1
    docker push $REG_NAME/$PREFIX/$NAME:latest
    docker push $REG_NAME/$PREFIX/$NAME:$1

    # add alias for all other versions
    shift 1
    for i in $*; do
        echo "Also tagging version=$i"
        docker tag $REG_NAME/$PREFIX/$NAME:latest $REG_NAME/$PREFIX/$NAME:$i
        docker push $REG_NAME/$PREFIX/$NAME:$i
    done
fi
