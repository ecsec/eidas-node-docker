#!/bin/sh

REG_NAME=public.docker.ecsec.de
PREFIX=ecsec/eidas

DOCKER_DIR=docker/
NAME=eidas-node

if [ ! $1 ]; then
    echo "USAGE:   $0 <eidas-node-version> [<version-alias>*]"
    echo "EXAMPLE: $0 2.5.0"
    echo "EXAMPLE: $0 2.5.0 2.5.0-wildfly-25.0.0"
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
