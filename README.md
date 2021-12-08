# eIDAS-Node Docker Image

## Build & Push Docker Image

The eIDAS-Node and WildFly version are defined in ARGs in the Dockerfile.
The eIDAS-Node download is controlled by either setting the version in `EIDAS_NODE_VERSION`, or by defining the entire URL pointing to the zip file in `EIDAS_NODE_URL`.
The WildFly version can be changed with the `WILDFLY_VERSION` argument.

By executing the following commands the eIDAS-Node Image can be built and published.

```bash
$ REPOSITORY=<YOUR_REPO>
$ IMAGE_NAME=<IMAGE_NAME>
$ TAG=<DESIRED_TAG>
$ docker build -t ${REPOSITORY}/${IMAGE_NAME}:${TAG} .
$ docker push ${REPOSITORY}/${IMAGE_NAME}:${TAG}
```

## Deployment via Helm Chart

```bash
$ helm upgrade --install ${RELEASE_NAME} -n ${NAMESPACE} helm/
```

For more details about the helm chart and its configuration, see [here](./helm/README.md).
