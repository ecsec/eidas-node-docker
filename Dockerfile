ARG WILDFLY_VERSION=25.0.0.Final
ARG ALPINE_VERSION=3.15


FROM alpine:${ALPINE_VERSION} as builder

ARG EIDAS_NODE_VERSION=2.5.0

RUN apk update && \
    apk add --no-cache unzip && \
    apk add --no-cache wget && \
    apk add --no-cache openjdk11

WORKDIR /data

# Download eIDAS-Node Software
RUN wget https://ec.europa.eu/cefdigital/artifact/repository/eid/eu/eIDAS-node/${EIDAS_NODE_VERSION}/eIDAS-node-${EIDAS_NODE_VERSION}.zip

# Prepare for adding updated jboss-deployment-structure.xml file to EidasNode.war
# Because of Bug: https://issues.apache.org/jira/browse/IGNITE-12483
# Solution: https://stackoverflow.com/questions/59407347/connection-from-ignite-client-in-docker-container-to-ignite-server-in-another-do
COPY docker/jboss-deployment-structure.xml WEB-INF/jboss-deployment-structure.xml

# Unzip eIDAS-Node Software
RUN unzip eIDAS-node-${EIDAS_NODE_VERSION}.zip && \
    unzip EIDAS-Binaries-Wildfly-${EIDAS_NODE_VERSION}.zip && \
    # Update the EidasNode.war by adding and overwriting jboss-deployment-structure.xml
    jar -uvf WILDFLY/EidasNode.war WEB-INF/


FROM jboss/wildfly:${WILDFLY_VERSION} as runner

USER root

# Copy default WAR to Wildfly Image
COPY --from=builder --chown=jboss:root /data/WILDFLY/EidasNode.war /opt/jboss/wildfly/standalone/deployments/eidas-node.war
# Copy BouncyCastle to Wildfly Modules
COPY --from=builder --chown=jboss:root /data/AdditionalFiles/Wildfly15/ /opt/jboss/wildfly/modules/system/layers/base/

RUN mkdir -p /eidas/keystores && \
    mkdir -p /eidas/specificProxyService && \
    chown -R jboss:root /eidas && \
    # Add BouncyCastle Security Provider
    sed -i 's/security.provider.12=SunPKCS11/security.provider.12=SunPKCS11\nsecurity.provider.13=org.bouncycastle.jce.provider.BouncyCastleProvider/g' /usr/lib/jvm/java/conf/security/java.security && \
    # See also https://apacheignite.readme.io/docs/getting-started#running-ignite-with-java-11-and-later-versions regarding add-exports
    printf '\nJAVA_OPTS=\"$JAVA_OPTS $JAVA_OPTS_CUSTOM -Djdk.tls.client.protocols=TLSv1.2 --add-exports=java.base/jdk.internal.misc=ALL-UNNAMED --add-exports=java.management/com.sun.jmx.mbeanserver=ALL-UNNAMED --add-exports=jdk.internal.jvmstat/sun.jvmstat.monitor=ALL-UNNAMED --add-exports=java.base/sun.reflect.generics.reflectiveObjects=ALL-UNNAMED --add-opens=jdk.management/com.sun.management.internal=ALL-UNNAMED --illegal-access=permit\"' \
      >> /opt/jboss/wildfly/bin/standalone.conf

USER jboss

ENV EIDAS_CONFIG_REPOSITORY=/eidas
ENV SPECIFIC_CONNECTOR_CONFIG_REPOSITORY=/eidas
ENV SPECIFIC_PROXY_SERVICE_CONFIG_REPOSITORY=/eidas/specificProxyService

ENV JAVA_OPTS=""
ENV JAVA_OPTS_CUSTOM="-Xmx512m"