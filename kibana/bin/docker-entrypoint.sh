#!/bin/bash -e

# Map environment variables to entries in logstash.yml.
# Note that this will mutate logstash.yml in place if any such settings are found.
# This may be undesirable, especially if logstash.yml is bind-mounted from the
# host system.
# IT IS NECESSARY TO CONVERT "env2yaml" to armv7 binary code, then line below is disabled!
#env2yaml /usr/share/logstash/config/logstash.yml

# # Allow user specify custom CMD, maybe bin/kibana itself
# # for example to directly specify `-E` style parameters for kibana on k8s
# # or simply to run /bin/bash to check the image
# if [[ "$1" != "kbwrapper" ]]; then
#   if [[ "$(id -u)" == "0" && $(basename "$1") == "kibana" ]]; then
#     # centos:7 chroot doesn't have the `--skip-chdir` option and
#     # changes our CWD.
#     # Rewrite CMD args to replace $1 with `kibana` explicitly,
#     # so that we are backwards compatible with the docs
#     # from the previous kibana versions<6
#     # and configuration option D:
#     # https://www.elastic.co/guide/en/kibana/reference/5.6/docker.html#_d_override_the_image_8217_s_default_ulink_url_https_docs_docker_com_engine_reference_run_cmd_default_command_or_options_cmd_ulink
#     # Without this, user could specify `kibana -E x.y=z` but
#     # `bin/kibana -E x.y=z` would not work.
#     set -- "kibana" "${@:2}"
#     # Use chroot to switch to UID 1000
#     exec chroot --userspec=1000 / "$@"
#   else
#     # User probably wants to run something else, like /bin/bash, with another uid forced (Openshift?)
#     exec "$@"
#   fi
# fi

if [[ -z $1 ]] || [[ ${1:0:1} == '-' ]] ; then
  exec kibana "$@"
else
  exec "$@"
fi
