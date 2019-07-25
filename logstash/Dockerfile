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
    adduser -u 1000 -g 1000 -d /usr/share/logstash logstash

WORKDIR /usr/share/logstash

RUN cd /opt && \
    curl --retry 8 -s -L -O https://artifacts.elastic.co/downloads/logstash/logstash-6.8.1.tar.gz && \
    cd - && \
    tar zxf /opt/logstash-6.8.1.tar.gz --strip-components=1

# RUN groupadd -g 1000 logstash && \
#     adduser -u 1000 -g 1000 -G 0 -d /usr/share/logstash logstash && \
#     chmod 0777 /usr/share/logstash && \
#     chgrp 0 /usr/share/logstash
    
# Add Logstash itself.
# RUN curl -Lo - https://artifacts.elastic.co/downloads/logstash/logstash-6.8.1.tar.gz | \
#     tar zxf - -C /usr/share && \
#     mv /usr/share/logstash-6.8.1 /usr/share/logstash && \
#     chown --recursive logstash:logstash /usr/share/logstash/ && \
#     #chown -R logstash:root /usr/share/logstash && \
#     chmod -R g=u /usr/share/logstash && \
#     find /usr/share/logstash -type d -exec chmod g+s {} \; && \
#     ln -s /usr/share/logstash /opt/logstash

ENV ELASTIC_CONTAINER true
ENV PATH=/usr/share/logstash/bin:$PATH

# Remove existing configuration

RUN rm /usr/share/logstash/config/jvm.options \
       /usr/share/logstash/config/log4j2.properties \
       /usr/share/logstash/config/logstash.yml \
       /usr/share/logstash/config/pipelines.yml \
       /usr/share/logstash/pipeline/logstash.conf

# RUN mv -T /usr/share/logstash/config/jvm.options jvm.options.dist && \
#     mv -T /usr/share/logstash/config/log4j2.properties log4j2.properties.dist && \
#     mv -T /usr/share/logstash/config/logstash.yml logstash.yml.dist && \
#     mv -T /usr/share/logstash/config/pipelines.yml pipelines.yml.dist && \
#     mv -T /usr/share/logstash/pipeline/logstash.conf logstash.conf.dist

WORKDIR /usr/share/logstash

COPY --chown=1000:0 config/logstash.yml config/jvm.options config/pipelines.yml config/log4j2.properties /usr/share/elasticsearch/config/
COPY --chown=1000:0 pipeline/default.conf pipeline/logstash.conf

RUN chown --recursive logstash:logstash config/ pipeline/ && \
    chmod 0777 config/logstash.yml

# Place the startup wrapper script.
ADD bin/docker-entrypoint /usr/local/bin/
RUN chmod 0755 /usr/local/bin/docker-entrypoint
#USER 1000
ADD env2yaml/env2yaml /usr/local/bin/
RUN chmod 0755 /usr/local/bin/env2yaml

EXPOSE 9600 5044

LABEL org.label-schema.schema-version="1.0" \
  org.label-schema.vendor="Elastic" \
  org.label-schema.name="logstash" \
  org.label-schema.version="6.8.1" \
  org.label-schema.url="https://www.elastic.co/products/logstash" \
  org.label-schema.vcs-url="https://github.com/elastic/logstash" \
license="Elastic License"
ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
