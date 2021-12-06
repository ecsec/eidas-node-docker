ARG WILDFLY_VERSION=25.0.0.Final


FROM alpine:3.15 as builder

ARG EIDAS_NODE_VERSION=2.5.0

RUN apk update && \
    apk add --no-cache unzip && \
    apk add --no-cache wget

WORKDIR /data

# Download eIDAS-Node Software
RUN wget https://ec.europa.eu/cefdigital/artifact/repository/eid/eu/eIDAS-node/${EIDAS_NODE_VERSION}/eIDAS-node-${EIDAS_NODE_VERSION}.zip

# Unzip eIDAS-Node Software
RUN unzip eIDAS-node-${EIDAS_NODE_VERSION}.zip && \
    rm eIDAS-node-2.5.0.zip && \
    unzip EIDAS-Binaries-Wildfly-${EIDAS_NODE_VERSION}.zip

# Unzip eIDAS-Node Configuration
RUN unzip -d /data/WILDFLY/config /data/WILDFLY/config.zip


FROM jboss/wildfly:${WILDFLY_VERSION} as runner

ARG JDK_DIR=/usr/lib/jvm/java-11-openjdk-11.0.8.10-0.el7_8.x86_64

ENV EIDAS_CONFIG_REPOSITORY=/eidas
ENV SPECIFIC_CONNECTOR_CONFIG_REPOSITORY=/eidas
ENV SPECIFIC_PROXY_SERVICE_CONFIG_REPOSITORY=/eidas/specificProxyService

# See also https://apacheignite.readme.io/docs/getting-started#running-ignite-with-java-11-and-later-versions regarding add-exports
ENV JAVA_OPTS="-XX:MaxPermSize=512m -Xms512m -Xmx512m -Djava.net.preferIPv4Stack=true -Djdk.tls.client.protocols=TLSv1.2 --add-exports=java.base/jdk.internal.misc=ALL-UNNAMED --add-exports=java.management/com.sun.jmx.mbeanserver=ALL-UNNAMED --add-exports=jdk.internal.jvmstat/sun.jvmstat.monitor=ALL-UNNAMED --add-exports=java.base/sun.reflect.generics.reflectiveObjects=ALL-UNNAMED --add-opens=jdk.management/com.sun.management.internal=ALL-UNNAMED --illegal-access=permit"

USER root

RUN mkdir -p /eidas/keystores
RUN chown -R jboss:root /eidas

# Prepare for adding updated jboss-deployment-structure.xml file to EidasNode.war
# Because of Bug: https://issues.apache.org/jira/browse/IGNITE-12483
# Solution: https://stackoverflow.com/questions/59407347/connection-from-ignite-client-in-docker-container-to-ignite-server-in-another-do
RUN mkdir -p /tmp/WEB-INF && chown -R jboss:root /tmp/WEB-INF
COPY --chown=jboss:root jboss-deployment-structure.xml /tmp/WEB-INF/jboss-deployment-structure.xml
COPY --from=builder --chown=jboss:root /data/WILDFLY/EidasNode.war /tmp/eidas-node.war

# Update the EidasNode.war by adding and overwriting jboss-deployment-structure.xml
RUN cd /tmp/ && \
    jar -uvf eidas-node.war WEB-INF/ && \
    rm -r WEB-INF/ && \
    mv eidas-node.war /opt/jboss/wildfly/standalone/deployments/eidas-node.war && \
    cd -

# Copy default configuration to Wildfly Image
COPY --from=builder --chown=jboss:root /data/WILDFLY/config/wildfly/ /eidas/
COPY --from=builder --chown=jboss:root /data/WILDFLY/config/keystore/* /eidas/keystores/

# Add BouncyCastle Security Provider
RUN sed -i 's/security.provider.12=SunPKCS11/security.provider.12=SunPKCS11\nsecurity.provider.13=org.bouncycastle.jce.provider.BouncyCastleProvider/g' ${JDK_DIR}/conf/security/java.security

# Copy BouncyCastle to Wildfly Modules
COPY --from=builder --chown=jboss:root /data/AdditionalFiles/Wildfly15/ /opt/jboss/wildfly/modules/system/layers/base/

USER jboss
