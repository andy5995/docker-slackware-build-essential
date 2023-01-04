FROM vbatts/slackware:15.0
RUN echo "http://spout.ussg.indiana.edu/linux/slackware/slackware64-15.0/" > /etc/slackpkg/mirrors
RUN slackpkg update
RUN echo y | slackpkg upgrade-all
RUN echo y | slackpkg install \
  d \
  l \
  ca-certificates \
  curl  \
  cyrus-sasl  \
  gnutls  \
  nghttp2

# TODO: install slapt-get and sbopkg
# wget https://github.com/sbopkg/sbopkg/releases/download/0.38.2/sbopkg-0.38.2-noarch-1_wsr.tgz && \
RUN update-ca-certificates --fresh
ENTRYPOINT ["/bin/bash"] 
