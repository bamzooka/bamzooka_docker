# Docker images

## Building new images

To build a new image, just run `ruby auto_build.rb image-name`. The build process will build a local image with a predefined tag.

Images and tag names are defined [here](https://github.com/bamzooka/bamzooka_docker/blob/master/image/auto_build.rb#L6-L11).

> **A note about --squash**: By default we squash the images we serve on Docker Hub. You will need to [enable experimental features](https://github.com/docker/docker-ce/blob/master/components/cli/experimental/README.md) on your Docker daemon for that.


## More about the images

See both `auto_build.rb` and the respective `Dockerfile`s for details on _how_ all of this happens.


### base ([bamzooka/base](https://hub.docker.com/r/bamzooka/base/))

All of the dependencies for running Bamzooka.  This includes runit, postgres, nginx, ruby, imagemagick, etc.  It also includes the creation of the "bamzooka" user and `/var/www` directory.


### bamzooka_dev ([bamzooka/bamzooka_dev](https://hub.docker.com/r/bamzooka/bamzooka_dev/))

Adds redis and postgres just like the "standalone" template for Bamzooka in order to have an all-in-one container for development.  Note that you are expected to mount your local bamzooka source directory to `/src`.  See [the README in GitHub's bamzooka/bin/docker](https://github.com/bamzooka/bamzooka/tree/master/bin/docker/) for utilities that help with this.

Note that the bamzooka user is granted "sudo" permission without asking for a password in the bamzooka_dev image.  This is to facilitate the command-line Docker tools in bamzooka proper that run commands as the bamzooka user.


### bamzooka_test ([bamzooka/bamzooka_test](https://hub.docker.com/r/bamzooka/bamzooka_test/))

Builds on the bamzooka image and adds testing tools and a default testing entrypoint.


### bamzooka_bench ([bamzooka/bamzooka_bench](https://hub.docker.com/r/bamzooka/bamzooka_bench/))

Builds on the bamzooka_test image and adds benchmark testing.


### bamzooka_fast_switch ([bamzooka/bamzooka_fast_switch](https://hub.docker.com/r/bamzooka/bamzooka_fast_switch/))

Builds on the bamzooka image and adds the ability to easily switch versions of Ruby.
