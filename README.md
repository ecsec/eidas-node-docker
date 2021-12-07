# eIDAS-Node Docker Image

## Build & Push Docker Image

The eIDAS-Node and WildFly version are defined in `.env` and can be overwritten. By executing the following commands the eIDAS-Node Image can be built and published.

```bash
$ source .env
$ REPOSITORY=<YOUR_REPO>
$ IMAGE_NAME=<IMAGE_NAME>
$ TAG=<DESIRED_TAG>
$ docker build --build-arg EIDAS_NODE_VERSION=${EIDAS_NODE_VERSION} \
        --build-arg WILDFLY_VERSION=${WILDFLY_VERSION} \
        -t ${REPOSITORY}/${IMAGE_NAME}:${TAG} .
$ docker push ${REPOSITORY}/${IMAGE_NAME}:${TAG}
```

## Deployment via Helm Chart

```bash
$ helm upgrade --install ${RELEASE_NAME} -n ${NAMESPACE} helm/
```

For more details about the helm chart and its configuration, see [here](./helm/README.md).
