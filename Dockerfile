# Ubuntu 16.04 based, runs as rundeck user
# https://hub.docker.com/r/rundeck/rundeck/tags
ARG RUNDECK_IMAGE
FROM ${RUNDECK_IMAGE}
MAINTAINER Rundeck Team

ENV ANSIBLE_HOST_KEY_CHECKING=false
ENV RDECK_BASE=/home/rundeck
ENV MANPATH=${MANPATH}:${RDECK_BASE}/docs/man
ENV PATH=${PATH}:${RDECK_BASE}/tools/bin
ENV PROJECT_BASE=${RDECK_BASE}/projects/Test-Project

# install ansible
# for installs from base image see see https://github.com/rundeck/rundeck/blob/master/docker/ubuntu-base/Dockerfile
RUN sudo apt-get -y update \
  && sudo apt-get -y --no-install-recommends install ansible sshpass zip \
  && sudo rm -rf /var/lib/apt/lists/* \
  && mkdir -p ${PROJECT_BASE}/etc/ \
  && sudo mkdir /etc/ansible

# add default project
COPY --chown=rundeck:rundeck docker/project.properties ${PROJECT_BASE}/etc/

# remove embedded rundeck-ansible-plugin
RUN zip -d rundeck.war WEB-INF/rundeck/plugins/ansible-plugin-* \
  && unzip -C rundeck.war WEB-INF/rundeck/plugins/manifest.properties \
  && sed -i "s/\(.*\)\(ansible-plugin-.*\.jar,\)\(.*\)/\1\3/" WEB-INF/rundeck/plugins/manifest.properties \
  && zip -u rundeck.war WEB-INF/rundeck/plugins/manifest.properties \
  && rm WEB-INF/rundeck/plugins/manifest.properties

# add locally built ansible plugin
COPY --chown=rundeck:rundeck build/libs/ansible-plugin-*.jar ${RDECK_BASE}/libext/
