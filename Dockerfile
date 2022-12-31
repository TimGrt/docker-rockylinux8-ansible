FROM rockylinux:8
LABEL maintainer="Tim Gruetzmacher"
LABEL org.opencontainers.image.source="https://github.com/TimGrt/docker-rockylinux8-ansible"
ENV container=docker

# Install systemd -- See https://hub.docker.com/_/centos/
RUN rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

# Install requirements.
RUN yum -y install rpm dnf-plugins-core \
 && yum -y update \
 && yum -y config-manager --set-enabled powertools \
 && yum -y install \
      epel-release \
      initscripts \
      sudo \
      which \
      hostname \
      libyaml-devel \
      python3 \
      python3-pip \
      python3-pyyaml \
 && yum clean all

# Upgrade pip to latest version.
RUN pip3 install --no-cache-dir --upgrade pip

# Install Ansible via Pip.
RUN pip3 install --no-cache-dir ansible

# Disable requiretty.
RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers

# Install Ansible inventory file.
RUN mkdir -p /etc/ansible
RUN printf "[local]\nlocalhost ansible_connection=local\n" > /etc/ansible/hosts

# Create `ansible` user with sudo permissions
ENV ANSIBLE_USER=ansible

RUN set -xe \
  && useradd -m ${ANSIBLE_USER} \
  && echo "${ANSIBLE_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/ansible

VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/lib/systemd/systemd"]
