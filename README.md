[![.github/workflows/build.yml](https://github.com/bamzooka/bamzooka_docker/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/bamzooka/bamzooka_docker/actions/workflows/build.yml)

### About



- Docker makes it much easier to deploy [a Bamzooka](https://github.com/bamzooka/bamzooka) on your servers and keep it updated.
- [Docker](https://docker.com/) is an open source project to pack, ship and run any Linux application in a lighter weight, faster container than a traditional virtual machine.
- The templates and base image configure Bamzooka with the Bamzooka team's recommended optimal defaults.

### Getting Started

The simplest way to get started is via the **standalone** template, which can be installed in 30 minutes or less. For detailed install instructions, see

https://github.com/bamzooka/bamzooka/blob/master/docs/INSTALL-cloud.md

### Directory Structure

#### `/cids`

Contains container ids for currently running Docker containers. cids are Docker's "equivalent" of pids. Each container will have a unique git like hash.

#### `/containers`

This directory is for container definitions for your various Bamzooka containers. You are in charge of this directory, it ships empty.

#### `/samples`

Sample container definitions you may use to bootstrap your environment. You can copy templates from here into the containers directory.

#### `/shared`

Placeholder spot for shared volumes with various Bamzooka containers. You may elect to store certain persistent information outside of a container, in our case we keep various logfiles and upload directory outside. This allows you to rebuild containers easily without losing important information. Keeping uploads outside of the container allows you to share them between multiple web instances.

#### `/templates`

[pups](https://github.com/samsaffron/pups)-managed templates you may use to bootstrap your environment.

#### `/image`

Dockerfiles for Bamzooka; see [the README](image/README.md) for further details.

The Docker repository will always contain the latest built version at: https://hub.docker.com/r/bamzooka/base/, you should not need to build the base image.

### Launcher

The base directory contains a single bash script which is used to manage containers. You can use it to "bootstrap" a new container, enter, start, stop and destroy a container.

```yaml
Usage: launcher COMMAND CONFIG [--skip-prereqs]
Commands:
    start:      Start/initialize a container
    stop:       Stop a running container
    restart:    Restart a container
    destroy:    Stop and remove a container
    enter:      Use docker exec to enter a container
    logs:       Docker logs for container
    memconfig:  Configure sane defaults for available RAM
    bootstrap:  Bootstrap a container for the config based on a template
    rebuild:    Rebuild a container (destroy old, bootstrap, start new)
```

If the environment variable "SUPERVISED" is set to true, the container won't be detached, allowing a process monitoring tool to manage the restart behaviour of the container.

### Container Configuration

The beginning of the container definition can contain the following "special" sections:

#### templates:

```yaml
templates:
  - "templates/cron.template.yml"
  - "templates/postgres.template.yml"
```

This template is "composed" out of all these child templates, this allows for a very flexible configuration structure. Furthermore you may add specific hooks that extend the templates you reference.

#### expose:

```yaml
expose:
  - "2222:22"
  - "127.0.0.1:20080:80"
```

Publish port 22 inside the container on port 2222 on ALL local host interfaces. In order to bind to only one interface, you may specify the host's IP address as `([<host_interface>:[host_port]])|(<host_port>):<container_port>[/udp]` as defined in the [docker port binding documentation](http://docs.docker.com/userguide/dockerlinks/). To expose a port without publishing it, specify only the port number (e.g., `80`).


#### volumes:

```yaml
volumes:
  - volume:
      host: /var/bamzooka/shared
      guest: /shared

```

Expose a directory inside the host to the container.

#### links:

```yaml
links:
  - link:
      name: postgres
      alias: postgres
```

Links another container to the current container. This will add `--link postgres:postgres`
to the options when running the container.

#### environment variables:

Setting environment variables to the current container.

```yaml
# app.yml

env:
  BAMZOOKA_DB_HOST: some-host
  BAMZOOKA_DB_NAME: "{{config}}_bamzooka"
```

The above will add `-e BAMZOOKA_DB_HOST=some-host -e BAMZOOKA_DB_NAME=app_bamzooka` to the options when running the container.

#### labels:

```yaml
# app.yml

labels:
  monitor: "true"
  app_name: "{{config}}_bamzooka"
```

Add labels to the current container. The above will add `--l monitor=true -l app_name=dev_bamzooka` to the options
when running the container

### Upgrading Bamzooka

The Docker setup gives you multiple upgrade options:

1. Use the front end at http://yoursite.com/admin/upgrade to upgrade an already running image.

2. Create a new base image manually by running:
  - `./launcher rebuild my_image`

### Single Container vs. Multiple Container

The samples directory contains a standalone template. This template bundles all of the software required to run Bamzooka into a single container. The advantage is that it is easy.

The multiple container configuration setup is far more flexible and robust, however it is also more complicated to set up. A multiple container setup allows you to:

- Minimize downtime when upgrading to new versions of Bamzooka. You can bootstrap new web processes while your site is running and only after it is built, switch the new image in.
- Scale your forum to multiple servers.
- Add servers for redundancy.
- Have some required services (e.g. the database) run on beefier hardware.

If you want a multiple container setup, see the `data.yml` and `web_only.yml` templates in the samples directory. To ease this process, `launcher` will inject an env var called `BAMZOOKA_HOST_IP` which will be available inside the image.

WARNING: In a multiple container configuration, *make sure* you setup iptables or some other firewall to protect various ports (for postgres/redis).
On Ubuntu, install the `ufw` or `iptables-persistent` package to manage firewall rules.

### Email

For a Bamzooka instance to function properly Email must be set up. Use the `SMTP_URL` env var to set your SMTP address, see sample templates for an example. The Docker image does not contain postfix, exim or another MTA, it was omitted because it is very tricky to set up correctly.

### Troubleshooting

View the container logs: `./launcher logs my_container`

Spawn a shell inside your container using `./launcher enter my_container`. This is the most foolproof method if you have host root access.

If you see network errors trying to retrieve code from `github.com` or `rubygems.org` try again - sometimes there are temporary interruptions and a retry is all it takes.

Behind a proxy network with no direct access to the Internet? Add proxy information to the container environment by adding to the existing `env` block in the `container.yml` file:

```yaml
env:
    …existing entries…
    HTTP_PROXY: http://proxyserver:port/
    http_proxy: http://proxyserver:port/
    HTTPS_PROXY: http://proxyserver:port/
    https_proxy: http://proxyserver:port/
```

### Security

Directory permissions in Linux are UID/GID based, if your numeric IDs on the
host do not match the IDs in the guest, permissions will mismatch. On clean
installs you can ensure they are in sync by looking at `/etc/passwd` and
`/etc/group`, the Bamzooka account will have UID 1000.

### MISC

 Bamzooka has its own login to docker hub. Ask a dev from the bamzooka team if you need any access


### Credits

This was originally copied from [Discourse_docker](https://github.com/discourse/discourse_docker) project and modified for Bamzooka needs.

License
===
MIT
