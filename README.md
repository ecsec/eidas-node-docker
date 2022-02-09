# eIDAS-Node Docker Image

[![Docker](https://github.com/ecsec/eidas-node-docker/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/ecsec/eidas-node-docker/actions/workflows/docker-publish.yml)
![Docker Image Version (latest by date)](https://img.shields.io/docker/v/ecsec/eidas-node)

This repository provides a Dockerfile and Helm Chart of the EU eIDAS-Node Software. The eIDAS-Node Docker Image is published via [Docker Hub](https://hub.docker.com/r/ecsec/eidas-node).

## Build

By executing the following command the eIDAS-Node Image can be built.

```bash
$ docker build -t ecsec/eidas-node .
```

The following build arguments are supported (and can be used with `--build-arg`):

| Build Argument | Description | Default |
| -------------- | ----------- | ------- |
| ALPINE_VERSION | Version of the Alpine Image that is used for downloading, extracting and preparing the eIDAS-Node software. | 3.15 |
| EIDAS_NODE_VERSION | Version of the eIDAS-Node software that will be used in the resulting image. | 2.5.0 |
| WILDFLY_VERSION | Version of the WildFly Application Server that will be used in the resulting image. | 25.0.0.Final |
| EIDAS_NODE_URL | Defines the entire URL that is pointing to the ZIP-Archive of the eIDAS-Node Software. | `https://ec.europa.eu/cefdigital/artifact/repository/eid/eu/eIDAS-node/${EIDAS_NODE_VERSION}/eIDAS-node-${EIDAS_NODE_VERSION}.zip` |

## Configuration

Before you can run the eIDAS-Node via Docker, you have to prepare your eIDAS-Node configuration. A configuration must be present, otherwise you might receive startup errors.

For an initial start you can use the default settings that are provided in the eIDAS-Node release archive (which can be downloaded from [here](https://ec.europa.eu/cefdigital/wiki/display/CEFDIGITAL/All+releases). You have to extract the content in the archive and there should be the config directories `wildfly` and `keystore`. Those directories provide some default settings for the eIDAS-Node software.

Those settings must be mounted to the Docker Container. The most essential mount paths are the following:

| Mount Path | Description |
| ---------- | ----------- |
| /config/eidas | This is the default directory where your eIDAS-Node configuration files are stored (Can be overwritten via an env variable). |
| /config/keystore | This is the default directory where your keystores are stored. |
| /opt/jboss/wildfly/standalone/configuration/standalone.xml | Your WildFly configuration which can be overwritten by a customized one. |

In addition, the following environment variables can be overwritten at runtime (by using `--env`):

| Environment Variable | Description | Default |
| -------------------- | ----------- | ------- |
| EIDAS_CONFIG_REPOSITORY | The directory where your eIDAS-Node configuration files are stored. | /config/eidas |
| SPECIFIC_CONNECTOR_CONFIG_REPOSITORY | The directory where your specific connector configuration files are stored. | /config/eidas/specificConnector |
| SPECIFIC_PROXY_SERVICE_CONFIG_REPOSITORY | The directory where your specific proxy service configuration files are stored. | /config/eidas/specificProxyService |
| JAVA_OPTS_CUSTOM | Can be used to overwrite JVM arguments. | `-Xmx512m` |


Starting the eIDAS-Node Docker container with some default settings can look like this:

```bash
$ docker run \
    -p 8080:8080 \
    --mount type=bind,source=<PATH_TO_EIDAS_NODE_CONFIG_FOLDER>/wildfly,target=/config/eidas \
    --mount type=bind,source=<PATH_TO_EIDAS_NODE_CONFIG_FOLDER>/keystore,target=/config/keystore \
    ecsec/eidas-node
```

## Deployment via Helm Chart

```bash
$ helm repo add ecsec https://mvn.ecsec.de/repository/helm-public/
$ helm repo update
$ helm upgrade --install ${RELEASE_NAME} -n ${NAMESPACE} --version ${VERSION} ecsec/eidas-node
```

You can list all available eIDAS-Node helm charts by using the following command:

```bash
$ helm search repo eidas-node -l --devel
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
