################################################################################
# This Dockerfile was generated from the template at distribution/src/docker/Dockerfile
#
# Beginning of multi stage Dockerfile
################################################################################

################################################################################
# Build stage 0 `builder`:
# Extract elasticsearch artifact
# Set gid=0 and make group perms==owner perms
################################################################################

FROM centos:7 AS builder

ENV PATH /usr/share/elasticsearch/bin:$PATH

# Provide a non-root user to run the process.
RUN groupadd -g 1000 elasticsearch && \
    adduser -u 1000 -g 1000 -d /usr/share/elasticsearch elasticsearch

WORKDIR /usr/share/elasticsearch

RUN cd /opt && \
    curl --retry 8 -s -L -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.5.4.tar.gz && \
    cd - && \
    tar zxf /opt/elasticsearch-6.5.4.tar.gz --strip-components=1 && \
    grep ES_DISTRIBUTION_TYPE=tar /usr/share/elasticsearch/bin/elasticsearch-env && \
    sed -ie 's/ES_DISTRIBUTION_TYPE=tar/ES_DISTRIBUTION_TYPE=docker/' /usr/share/elasticsearch/bin/elasticsearch-env && \
    mkdir -p config data logs && \
    chmod 0777 config data logs

# RUN cd /opt && curl --retry 8 -s -L -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.5.4.tar.gz && cd -

# RUN tar zxf /opt/elasticsearch-6.8.1.tar.gz --strip-components=1
# RUN grep ES_DISTRIBUTION_TYPE=tar /usr/share/elasticsearch/bin/elasticsearch-env \
#     && sed -ie 's/ES_DISTRIBUTION_TYPE=tar/ES_DISTRIBUTION_TYPE=docker/' /usr/share/elasticsearch/bin/elasticsearch-env
# RUN mkdir -p config data logs
# RUN chmod 0777 config data logs

################################################################################
# Build stage 1 (the actual elasticsearch image):
# Copy elasticsearch from stage 0
# Install required plugins
# Add entrypoint
################################################################################

FROM centos:7

ENV ELASTIC_CONTAINER true

RUN for iter in {1..10}; do yum update -y && \
    yum install -y nc java-11-openjdk-devel && \
    yum clean all && exit_code=0 && break || exit_code=$? && echo "yum error: retry $iter in 10s" && sleep 10; done; \
    (exit $exit_code)

# TODO: If "java-11-openjdk-devel" changes, then RUN line below and copy/paste result to be persisted!
# Sorry, I did not succeed on automating that, since ENV is only accepting static data. (?)
RUN export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:/bin/java::") && echo $JAVA_HOME
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-11.0.4.11-0.el7_6.arm

RUN groupadd -g 1000 elasticsearch && \
    adduser -u 1000 -g 1000 -G 0 -d /usr/share/elasticsearch elasticsearch && \
    chmod 0775 /usr/share/elasticsearch && \
    chgrp 0 /usr/share/elasticsearch

WORKDIR /usr/share/elasticsearch
COPY --from=builder --chown=1000:0 /usr/share/elasticsearch /usr/share/elasticsearch
COPY --chown=1000:0 config/elasticsearch.yml config/log4j2.properties config/jvm.options /usr/share/elasticsearch/config/

# Replace OpenJDK's built-in CA certificate keystore with the one from the OS
# vendor. The latter is superior in several ways.
# REF: https://github.com/elastic/elasticsearch-docker/issues/171
#RUN ln -sf /etc/pki/ca-trust/extracted/java/cacerts /usr/share/elasticsearch/jdk/lib/security/cacerts

ENV PATH /usr/share/elasticsearch/bin:$PATH

COPY --chown=1000:0 bin/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# Openshift overrides USER and uses ones with randomly uid>1024 and gid=0
# Allow ENTRYPOINT (and ES) to run even with a different user
RUN chgrp 0 /usr/local/bin/docker-entrypoint.sh && \
    chmod g=u /etc/passwd && \
    chmod 0775 /usr/local/bin/docker-entrypoint.sh

# Install required plugins
#RUN elasticsearch-plugin install analysis-icu

EXPOSE 9200 9300

LABEL org.label-schema.schema-version="1.0" \
  org.label-schema.vendor="Elastic" \
  org.label-schema.name="elasticsearch" \
  org.label-schema.version="6.5.4" \
  org.label-schema.url="https://www.elastic.co/products/elasticsearch" \
  org.label-schema.vcs-url="https://github.com/elastic/elasticsearch" \
  license="Elastic License"

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
# Dummy overridable parameter parsed by entrypoint
CMD ["eswrapper"]

################################################################################
# End of multi-stage Dockerfile
################################################################################
