FROM andy5995/slackware:15.0

USER root

# why doesn't this get set automatically, like HOME does?
ENV USER=root

RUN echo "http://mirrors.us.kernel.org/slackware/slackware64-15.0/" > /etc/slackpkg/mirrors
RUN echo n | slackpkg update

# Returns an error if there are no packages to upgrade
# RUN echo y | slackpkg upgrade-all

COPY *tagfile .
RUN echo y | slackpkg install $(cat ap-tagfile)
RUN echo y | slackpkg install $(cat d-tagfile)
RUN echo y | slackpkg install $(cat l-tagfile)
RUN echo y | slackpkg install $(cat n-tagfile)

RUN update-ca-certificates --fresh

# Get and install sbopkg
ARG SBOPKG_VER
ARG SBOPKG_NAME
COPY ./$SBOPKG_NAME.sha256sum .
RUN /bin/bash -c 'curl -LO https://github.com/sbopkg/sbopkg/releases/download/$SBOPKG_VER/$SBOPKG_NAME && \
  sha256sum -c $SBOPKG_NAME.sha256sum &&  \
  installpkg $SBOPKG_NAME &&  \
  rm $SBOPKG_NAME*'
RUN sbopkg -r

# Install slpkg and its dependencies
RUN sbopkg -B -i  \
    "greenlet  \
    SQLAlchemy  \
    python3-pythondialog  \
    python3-progress  \
    slpkg" \
    -e stop &&  \
  rm -rf /var/cache/sbopkg /tmp/*
RUN slpkg update --yes

# Install slapt-get
COPY ./slapt-get /slapt-get
RUN /bin/bash -c 'cd /slapt-get && \
  ./slapt-get.Slackbuild && \
  installpkg slapt*txz && \
  cd / && \
  rm -rf slapt-get'
RUN slapt-get -u

# Tests
# This just tests to make sure some basic development tools are
# installed and their dependencies are satisfied.
RUN /bin/bash -c 'cd /tmp \
  && curl -LO https://github.com/curl/curl/releases/download/curl-7_87_0/curl-7.87.0.tar.xz \
  && tar xf curl*xz -C /tmp \
  && cd /tmp/curl-7.87.0 \
  && autoreconf -if \
  && mkdir build && cd build \
  && ../configure --enable-warnings --enable-werror --with-openssl \
  && make -j$(nproc) \
  && make -C tests -j$(nproc) \
  && cd .. && rm -rf build && mkdir build && cd build \
  && ../configure --enable-warnings --enable-werror --with-gnutls \
  && make -j$(nproc) \
  && make -C tests -j$(nproc) \
  && cd \
  && rm -rf /tmp/curl*'

CMD ["/bin/bash","-l"]
