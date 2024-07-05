# Rocky Linux 8 Ansible Test Image

Rocky Linux 8 Docker container for Ansible playbook and role testing.  
This container is used to test Ansible roles and playbooks (e.g. with molecule) running locally inside the container.  
A user `ansible` is created with password-less sudo configured.

[![Docker Build and Publish](https://github.com/TimGrt/docker-rockylinux8-ansible/actions/workflows/ci.yml/badge.svg)](https://github.com/TimGrt/docker-rockylinux8-ansible/actions/workflows/ci.yml) ![Docker Pulls](https://img.shields.io/docker/pulls/timgrt/rockylinux8-ansible) ![CodeFactor Grade](https://img.shields.io/codefactor/grade/github/timgrt/docker-rockylinux8-ansible/main)

## How to Build

If you need to build the image on your own locally, do the following:

1. Install container runtime, I use [Podman](https://podman.io/docs/installation) but you may also use [Docker](https://docs.docker.com/engine/installation/).
2. Clone the repository and `cd` into this directory.
3. Run `podman build -t rockylinux8-ansible .`

## How to Use Standalone

1. Install container runtime, I use [Podman](https://podman.io/docs/installation). You may also use [Docker](https://docs.docker.com/engine/installation/), but you'll have to adjust some configurations.
2. Pull this image from Docker Hub or use the image you built earlier, e.g. called `rockylinux8-ansible:latest` for the next step.

    ```bash
    podman pull timgrt/rockylinux8-ansible:latest
    ```

3. Run a container from the image.

    ```console
    podman run --detach --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro --name instance timgrt/rockylinux8-ansible:latest
    ```

4. Use the container in your inventory with the *podman* connection plugin.

    ```ini
    [test]
    instance ansible_connection=podman ansible_user=ansible
    ```

    Using the ansible user inside the container to be able to test with become.

    You'll need to have the Ansible collection `containers.podman` installed.

    ```console
    ansible-galaxy collection install containers.podman
    ```

## How to Use with Molecule

1. [Install Docker](https://docs.docker.com/engine/installation/).
2. [Install Molecule](https://ansible.readthedocs.io/projects/molecule/installation/).
3. Add Image in `molecule.yml`.

    ```yaml
    ---
    driver:
      name: podman
    platforms:
      - name: rocky8
        image: docker.io/timgrt/rockylinux8-ansible:latest
        volumes:
          - /sys/fs/cgroup:/sys/fs/cgroup:ro
        command: "/usr/sbin/init"
        pre_build_image: true
    provisioner:
      name: ansible
      config_options:
        defaults:
          interpreter_python: auto_silent
          callback_result_format: yaml
        ssh_connection:
          pipelining: false
      inventory:
        host_vars:
          rocky8:
            ansible_user: ansible
    ```

## Author

Created 2022 by Tim Grützmacher, inspired by [Jeff Geerling](https://www.jeffgeerling.com/)
