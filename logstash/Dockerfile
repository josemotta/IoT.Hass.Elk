# This Dockerfile was generated from templates/Dockerfile.j2
FROM centos:7

# Install Java and the "which" command, which is needed by Logstash's shell
# scripts.
RUN yum update -y && yum install -y java-11-openjdk-devel which && \
    yum clean all

# TODO: If "java-11-openjdk-devel" changes, then RUN line below and copy/paste result to be persisted!
# Sorry, I did not succeed on automating that, since ENV is only accepting static data. (?)
#RUN export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:/bin/java::") && echo $JAVA_HOME
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-11.0.3.7-0.el7_6.arm

# Provide a non-root user to run the process.
# RUN groupadd --gid 1000 logstash && \
#     adduser --uid 1000 --gid 1000 \
#       --home-dir /usr/share/logstash --no-create-home \
#       logstash

RUN groupadd -g 1000 logstash && \
    adduser -u 1000 -g 1000 -G 0 -d /usr/share/logstash logstash && \
    chmod 0775 /usr/share/logstash && \
    chgrp 0 /usr/share/logstash
    
# Add Logstash itself.
RUN curl -Lo - https://artifacts.elastic.co/downloads/logstash/logstash-6.8.1.tar.gz | \
    tar zxf - -C /usr/share && \
    mv /usr/share/logstash-6.8.1 /usr/share/logstash && \
    chown --recursive logstash:logstash /usr/share/logstash/ && \
    chown -R logstash:root /usr/share/logstash && \
    chmod -R g=u /usr/share/logstash && \
    find /usr/share/logstash -type d -exec chmod g+s {} \; && \
    ln -s /usr/share/logstash /opt/logstash

WORKDIR /usr/share/logstash

ENV ELASTIC_CONTAINER true
ENV PATH=/usr/share/logstash/bin:$PATH

# Provide a minimal configuration, so that simple invocations will provide
# a good experience.
ADD --chown=1000:0 config/pipelines.yml config/pipelines.yml
ADD --chown=1000:0 config/logstash-full.yml config/logstash.yml
ADD --chown=1000:0 config/log4j2.properties config/
ADD --chown=1000:0 pipeline/default.conf pipeline/logstash.conf
RUN chown --recursive logstash:root config/ pipeline/

# Ensure Logstash gets a UTF-8 locale by default.
ENV LANG='en_US.UTF-8' LC_ALL='en_US.UTF-8'

# Place the startup wrapper script.
ADD bin/docker-entrypoint /usr/local/bin/
RUN chmod 0755 /usr/local/bin/docker-entrypoint

USER 1000

ADD --chown=1000:0 env2yaml/env2yaml /usr/local/bin/
RUN chmod +x /usr/local/bin/env2yaml

EXPOSE 9600 5044

LABEL org.label-schema.schema-version="1.0" \
  org.label-schema.vendor="Elastic" \
  org.label-schema.name="logstash" \
  org.label-schema.version="6.8.1" \
  org.label-schema.url="https://www.elastic.co/products/logstash" \
  org.label-schema.vcs-url="https://github.com/elastic/logstash" \
license="Elastic License"
ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
