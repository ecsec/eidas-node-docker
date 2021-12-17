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

## Quick Start

You can run the eIDAS-Node in a container by first building the Image and preparing the configuration in a directory (`config/`). A configuration must be present, otherwise you might receive startup errors.

For an initial start you can use the default config that is provided in the eIDAS-Node archive (which can be downloaded from [here](https://ec.europa.eu/cefdigital/wiki/display/CEFDIGITAL/eIDAS-Node+version+2.5)). You have to extract all the content in the archive and in `EIDAS-Binaries-Wildfly-2.5.0/WILDFLY/config/` you find an example of an eIDAS-Node deployment config (`wildfly/`) and corresponding keystores (`keystore/`).

Run the following command to start the eIDAS-Node with those example settings:

```bash
$ # Absolute path to your eIDAS-Node Configuration (like /home/<USER>/eIDAS-node-2.5.0/EIDAS-Binaries-Wildfly-2.5.0/WILDFLY/config/)
$ PATH_TO_CONFIG=<ABSOLUTE_PATH_TO_CONFIG>
$ docker run \
    -p 8080:8080 \
    --mount type=bind,source=${PATH_TO_CONFIG}/wildfly,target=/config/eidas \
    --mount type=bind,source=${PATH_TO_CONFIG}/keystore,target=/config/keystore \
    ${REPOSITORY}/${IMAGE_NAME}:${TAG} 
```

If you want to customize the WildFly configuration (like Reverse Proxy settings), you can overwrite the WildFly default configuration by creating a new WildFly configuration and mount this config to the container:

```bash
$ # Absolute path to your eIDAS-Node Configuration (like /home/<USER>/eIDAS-node-2.5.0/EIDAS-Binaries-Wildfly-2.5.0/WILDFLY/config/)
$ PATH_TO_CONFIG=<ABSOLUTE_PATH_TO_CONFIG>
$ touch ${PATH_TO_CONFIG}/standalone.xml
$ # Adjust the WildFly settings in config/standalone.xml
$ docker run \
    -p 8080:8080 \
    --mount type=bind,source=${PATH_TO_CONFIG}/wildfly,target=/config/eidas \
    --mount type=bind,source=${PATH_TO_CONFIG}/keystore,target=/config/keystore \
    --mount type=bind,source=${PATH_TO_CONFIG}/standalone.xml,target=/opt/jboss/wildfly/standalone/configuration/standalone.xml \
    ${REPOSITORY}/${IMAGE_NAME}:${TAG}
```

## Deployment via Helm Chart

```bash
$ helm upgrade --install ${RELEASE_NAME} -n ${NAMESPACE} helm/
```

For more details about the helm chart and its configuration, see [here](./helm/README.md).


# License

The sources in this repository are made available under the Apache License Version 2.0.
Find a copy of the license terms in the [LICENSE](./LICENSE) file.

The built docker container contains further software that may use different licenses.
Consider inspecting the following projects to obtain a complete list of licenses.
- Alpine Linux (https://www.alpinelinux.org/)
- WildFly Docker Image (https://github.com/jboss-dockerfiles/wildfly)
- eIDAS-Node Integration Package (https://ec.europa.eu/cefdigital/wiki/display/CEFDIGITAL/eIDAS-Node+Integration+Package)
