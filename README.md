[![Docker Image CI](https://github.com/andy5995/docker-slackware-build-essential/actions/workflows/docker.yml/badge.svg)](https://github.com/andy5995/docker-slackware-build-essential/actions/workflows/docker.yml)
# Slackware Build Essential Docker Image

This image aims to provide the essential tools for building software in a
Slackware environment. It can be used as a [service
container](https://docs.github.com/en/actions/using-containerized-services/about-service-containers#creating-service-containers)
in a GitHub action.

The image can be pulled from [Docker
Hub](https://hub.docker.com/repository/docker/andy5995/slackware-build-essential).

## Included package managers

* [slackpkg](https://docs.slackware.com/slackware:slackpkg)
* [sbopkg](https://sbopkg.org/)
* [slapt-get](https://github.com/jaos/slapt-get)
* [slpkg](https://dslackw.gitlab.io/slpkg/)

If you're not familiar with any of these, see the pages linked. You may also
post a question in the
[Discussions](https://github.com/andy5995/docker-slackware-build-essential/discussions).

## Example for use in a GitHub workflow

```yml
  slackware:
    runs-on: ubuntu-latest
    container: andy5995/slackware-build-essential:15.0
    steps:
    - uses: actions/checkout@v3
    - name: Change default mirror
      run: echo "https://mirrors.ocf.berkeley.edu/slackware/slackware64-15.0/" > /etc/slackpkg/mirrors
    - name: Install dependencies
      run: |
        echo n | slackpkg update
        echo y | slackpkg install libassuan
        #
        # Note that in some cases, sbopkg may return 0 on error
        # https://github.com/sbopkg/sbopkg/issues/85
        sbopkg -r
        sbopkg -B -i Pykka -e stop
        slapt-get -u
        slapt-get --install libX11
    - name: Build and test with meson
      run: |
        meson setup _build
        cd _build
        meson compile
        meson test
```

If you would like to randomly rotate the
[mirror](https://ftp.ussg.indiana.edu/linux/slackware/slackware64/source/ap/slackpkg/files/mirrors-x86_64.sample)
used each time:

```yml
    - name: Change default mirror
      run: |
        mirror=( \
          http://ftp.sunet.se/mirror/slackware.com/slackware64-15.0/ \
          http://ftp.tu-chemnitz.de/pub/linux/slackware/slackware64-15.0/ \
          http://ftp.mirrorservice.org/sites/ftp.slackware.com/pub/slackware/slackware64-15.0/    \
          http://slackware.mirrors.tds.net/pub/slackware/slackware64-15.0/ \
        )
        echo ${mirror[$(shuf -i 0-3 -n 1)]} > /etc/slackpkg/mirrors
```

## Customize

This is a [template
repository](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template),
which means you can create a repository from this repo, then customize the
Dockerfile to include all the dependencies your projects needs. You can push
your new image directly to [Docker Hub after creating a few access
tokens](https://docs.docker.com/build/ci/github-actions/).

When you're ready to use the image in your new workflow, simply change the
'container' line (shown in the example workflow above).
  
## Projects using this in their CI:

* [rmw](https://github.com/theimpossibleastronaut/rmw)
* [curl](https://github.com/curl/curl)

## Building the Image Locally

You'll need the slapt-get submodule for the build to complete. If you haven't
cloned this repo yet, you can get the submodule at the same time:

     git clone https://github.com/andy5995/docker-slackware-build-essential --recurse-submodules

Otherwise, if you've already cloned this repo:

    git submodule init
    git submodule update

Once you've confirmed you have files in `./slapt-get` (the directory would be
empty if not cloned), you can run `docker build`:

    docker build -t <name:tag> \
      --build-arg SBOPKG_VER=0.38.2  \
      --build-arg SBOPKG_NAME=sbopkg-0.38.2-noarch-1_wsr.tgz  \
      .

## LICENSE

The license included in this repository only applies to the files within this
repository; it does not apply to the files retrieved when the image is
created, nor to the files contained within the docker image itself.
