FROM vbatts/slackware:15.0
RUN echo "http://mirrors.us.kernel.org/slackware/slackware64-15.0/" > /etc/slackpkg/mirrors
RUN echo n | slackpkg update
RUN echo y | slackpkg upgrade-all
COPY d-tagfile .
COPY l-tagfile .
RUN echo y | slackpkg install $(cat d-tagfile)
RUN echo y | slackpkg install $(cat l-tagfile)
RUN echo y | slackpkg install \
  ca-certificates \
  curl  \
  cyrus-sasl  \
  gnutls  \
  nghttp2 \
  rsync

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

# Install slapt-get
COPY ./slapt-get /slapt-get
RUN /bin/bash -c 'cd /slapt-get && \
  ./slapt-get.Slackbuild && \
  installpkg slapt*txz && \
  cd / && \
  rm -rf slapt-get'
RUN slapt-get -u

ENTRYPOINT ["/bin/bash"] 
