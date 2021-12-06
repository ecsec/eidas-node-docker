# eIDAS-Node Docker Image

## Build & Push Docker Image

```bash
$ ./docker-build.sh ${EIDAS_NODE_VERSION} ${EIDAS_NODE_VERSION}-wildfly-${WILDFLY_VERSION}
```

## Deployment via Helm Chart

```bash
$ helm upgrade --install ${RELEASE_NAME} -n ${NAMESPACE} helm/
```

For more details about the helm chart and its configuration, see [here](./helm/README.md).
