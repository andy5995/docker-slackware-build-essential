[![Docker Image CI](https://github.com/andy5995/docker-slackware-build-essential/actions/workflows/docker.yml/badge.svg)](https://github.com/andy5995/docker-slackware-build-essential/actions/workflows/docker.yml)
# Slackware Build Essential Docker Image

This image aims to provide the essential tools for building software in a
Slackware environment. It can be used as a [service
container](https://docs.github.com/en/actions/using-containerized-services/about-service-containers#creating-service-containers)
in a GitHub action.

[sbopkg](https://sbopkg.org/) (a tool to synchronize with the
[SlackBuilds.org](https://www.slackbuilds.org/) repository) is included.

The image can be pulled from [Docker
Hub](https://hub.docker.com/repository/docker/andy5995/slackware-build-essential).

## Example for use in a GitHub workflow

```yml
  slackware:
    runs-on: ubuntu-latest
    container: andy5995/slackware-build-essential:15.0
    steps:
    - uses: actions/checkout@v3
    - name: Change default mirror
      run: echo "https://mirrors.ocf.berkeley.edu/slackware/slackware-15.0/" > /etc/slackpkg/mirrors
    - name: Install dependencies
      run: |
        echo n | slackpkg update
        echo y | slackpkg install libassuan
        #
        # Note that in some cases, sbopkg may return 0 on error
        # https://github.com/sbopkg/sbopkg/issues/85
        sbopkg -r
        sbopkg -B -i Pykka -e stop
    - name: Build and test with meson
      run: |
        meson setup _build
        cd _build
        meson compile
        meson test
```

If you would like to randomly rotate the mirror used each time:

```yml
    - name: Change default mirror
      run: |
        mirror=( \
          http://ftp.sunet.se/mirror/slackware.com/slackware64-15.0/ \
          http://ftp.tu-chemnitz.de/pub/linux/slackware/slackware64-15.0/ \
          http://ftp.mirrorservice.org/sites/ftp.slackware.com/pub/slackware/slackware64-15.0/    \
          http://slackware.mirrors.tds.net/pub/slackware/slackware64-15.0/
        )
        echo ${mirror[ $RANDOM % 4]} > /etc/slackpkg/mirrors
```
  
## Projects using this in their CI:

* [rmw](https://github.com/theimpossibleastronaut/rmw)

## LICENSE

The license included in this repository only applies to the files within this
repository; it does not apply to the files retrieved when the image is
created, nor to the files contained within the docker image itself.
