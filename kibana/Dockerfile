################################################################################
# This Dockerfile was adapted from the template at distribution/src/docker/Dockerfile
# 
# Better option seems to be Kibana 6.5.4 + Nodejs v10.14.0, see YourSecurityTech link:
# https://www.yoursecurity.tech/hosting-a-mini-siem.html
#
# kibana_1         | Kibana does not support the current Node.js version v8.14.0. Please use Node.js v10.15.2.
# kibana_1         | Kibana does not support the current Node.js version v8.14.1. Please use Node.js v10.15.2.
# kibana_1         | Kibana does not support the current Node.js version v8.15.0. Please use Node.js v10.15.2.
# kibana_1         | Kibana does not support the current Node.js version v8.15.1. Please use Node.js v10.15.2.
# kibana_1         | Kibana does not support the current Node.js version v8.16.0. Please use Node.js v10.15.2.
#
# Kibana 6.8.1: although logs indicates nodejs 10.15.2, error is shown below.
# /usr/share/kibana/bin/../node/bin/node: /lib/libstdc++.so.6: version `GLIBCXX_3.4.20' not found
#
# nodejs v8.14.0: error bad option: --max-http-header-size=65536, removed it from /usr/share/kibana/bin/kibana
#
# Beginning of multi stage Dockerfile
################################################################################

################################################################################
# Build stage 0 `builder`:
# Extract nodejs and kibana artifacts
# Set gid=0 and make group perms==owner perms
################################################################################

FROM centos:7 AS builder

ENV PATH=/usr/share/kibana/bin:$PATH

# Provide a non-root user to run the process.
RUN groupadd -g 1000 kibana && \
    adduser -u 1000 -g 1000 -d /usr/share/kibana kibana

# Get kibana and disable builtin nodejs for x86_64
WORKDIR /usr/share/kibana
RUN cd /opt && \
    curl --retry 8 -s -L -O https://artifacts.elastic.co/downloads/kibana/kibana-6.5.4-linux-x86_64.tar.gz && \
    cd - && \
    tar zxf /opt/kibana-6.5.4-linux-x86_64.tar.gz --strip-components=1 && \
    chown -R kibana:kibana /usr/share/kibana/ && \
    chmod -R g=u /usr/share/kibana && \
    find /usr/share/kibana -type d -exec chmod g+s {} \;

RUN mkdir -p logs && \
    chmod 0777 logs && \
    #rm /usr/share/kibana/node/bin/node && \
    mv /usr/share/kibana/node/bin/node /usr/share/kibana/node/bin/node.bak && \
    mv /usr/share/kibana/config/kibana.yml /usr/share/kibana/config/kibana.yml.bak
    #mv /usr/share/kibana/bin/kibana /usr/share/kibana/bin/kibana.bak

    # ln -s /usr/share/kibana /opt/kibana

# Get nodejs for armv7l
WORKDIR /usr/share/node
RUN curl --retry 8 -s -L -O https://nodejs.org/dist/v10.14.0/node-v10.14.0-linux-armv7l.tar.xz && \
    tar -xvf node-v10.14.0-linux-armv7l.tar.xz node-v10.14.0-linux-armv7l/bin/node --strip 2
    #cp ./node /usr/local/bin/


################################################################################
# Build stage 1 (the actual kibana image):
# Copy nodejs and kibana from stage 0
# Add entrypoint
################################################################################

FROM centos:7

ENV PATH=/usr/share/kibana/bin:$PATH
ENV ELASTIC_CONTAINER true

RUN groupadd -g 1000 kibana && \
    adduser -u 1000 -g 1000 -G 0 -d /usr/share/kibana kibana && \
    chmod 0775 /usr/share/kibana && \
    chgrp 0 /usr/share/kibana
    
WORKDIR /usr/share/kibana
COPY --from=builder --chown=1000:0 /usr/share/kibana /usr/share/kibana
COPY --from=builder --chown=1000:0 /usr/share/node/node /usr/local/bin/
COPY --chown=1000:0 config/kibana.yml /usr/share/kibana/config/
#COPY --chown=1000:0 bin/kibana /usr/share/kibana/bin/kibana
COPY --chown=1000:0 config/kibana.service /etc/systemd/system/
#RUN chmod 0755 /usr/share/kibana/bin/kibana

# Set-aside the built-in Node.js and force Kibana to use armv7l version
RUN ln -s /usr/local/bin/node /usr/share/kibana/node/bin/node

RUN chown --recursive kibana:kibana config/ && \
    chmod 0777 config/kibana.yml

# Place the startup wrapper script.
ADD bin/docker-entrypoint.sh /usr/local/bin/
RUN chmod 0755 /usr/local/bin/docker-entrypoint.sh
#USER 1000

# TODO: "env2yaml/env2yaml" binary should be compiled to armv7, the GO source code can be found at: 
# https://github.com/elastic/kibana-docker/blob/f72d4a13e2c4bf90fb24378640c51aeb1cc943e6/build/kibana/env2yaml/env2yaml.go
# Since I did not succeed on that yet, I commented "bin/docker-entrypoint" line 7 to avoid errors.
#ADD env2yaml/env2yaml /usr/local/bin/
#RUN chmod 0755 /usr/local/bin/env2yaml

EXPOSE 5601

LABEL org.label-schema.schema-version="1.0" \
  org.label-schema.vendor="Elastic" \
  org.label-schema.name="kibana" \
  org.label-schema.version="6.5.4" \
  org.label-schema.url="https://www.elastic.co/products/kibana" \
  org.label-schema.vcs-url="https://github.com/elastic/kibana" \
license="Elastic License"

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
# Dummy overridable parameter parsed by entrypoint
#CMD ["kbwrapper"]