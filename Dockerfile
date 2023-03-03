FROM andy5995/slackware:15.0

USER root

# why doesn't this get set automatically, like HOME does?
ENV USER=root

RUN echo y | slackpkg update

#Returns an error if there are no packages to upgrade
RUN /bin/bash -c 'set -e; \
    r=0; \
    echo y | slackpkg upgrade-all || r=$?; \
    if [ $r -ne 0 ] && [ $r -ne 20 ]; then \
      exit $r; \
    fi'

# series a
RUN echo y | slackpkg install \
      dcron \
      dbus \
      infozip

# series ap
RUN echo y | slackpkg install \
      sqlite

# series d
RUN echo y | slackpkg install \
      autoconf \
      autoconf-archive \
      automake \
      binutils \
      bison \
      cmake \
      doxygen \
      flex \
      gcc-11 \
      g++ \
      gettext-tools \
      git \
      guile \
      intltool \
      kernel-headers \
      libtool \
      llvm \
      m4 \
      make \
      meson \
      ninja \
      opencl-headers \
      perl \
      pkg-config \
      python-pip \
      python-setuptools \
      python2 \
      python3 \
      ruby \
      rust \
      sassc \
      strace

# series l
RUN echo y | slackpkg install \
      M2Crypto \
      Mako \
      boost \
      brotli \
      cfitsio \
      chmlib \
      clucene \
      cryfs \
      dotconf \
      eigen3 \
      elfutils \
      exiv2 \
      expat \
      farstream \
      fftw \
      gc \
      gcr \
      gegl \
      gexiv2 \
      giflib \
      gjs \
      glib \
      glib-networking \
      glib2 \
      glibc \
      glibc-i18n \
      glibc-profile \
      glibmm \
      gmime \
      gmm \
      gmp \
      gnu-efi \
      gobject-introspection \
      graphene \
      graphite2 \
      gsl \
      gvfs \
      harfbuzz \
      hyphen \
      icon-naming-utils \
      icu4c \
      id3lib \
      isl \
      iso-codes \
      jansson \
      jemalloc \
      kdsoap \
      keybinder3 \
      libarchive \
      libasyncns \
      libatasmart \
      libcap \
      libcap-ng \
      libclc \
      libcue \
      libdmtx \
      libedit \
      libevent \
      libexif \
      libffi \
      libgnome-keyring \
      libgnt \
      libgpod \
      libgsf \
      libgtop \
      libidl \
      libidn \
      libidn2 \
      libmcrypt \
      libmng \
      libmpc \
      libnih \
      libnjb \
      libnl \
      libnl3 \
      libnsl \
      libnss_nis \
      libpcap \
      libplist \
      libproxy \
      libpsl \
      libsass \
      libseccomp \
      libsecret \
      libsigc++ \
      libsigc++3 \
      libsigsegv \
      libssh \
      libssh2 \
      libtasn1 \
      libtiff \
      libunistring \
      libunwind \
      liburing \
      libusb \
      libusb-compat \
      libusbmuxd \
      libuv \
      libwebp \
      libwnck3 \
      libwpd \
      libwpg \
      libxml2 \
      libxslt \
      libyaml \
      libzip \
      lz4 \
      mhash \
      mlt \
      mm \
      mpfr \
      ncurses \
      openexr \
      opus \
      opusfile \
      orc \
      pcre \
      pcre2 \
      polkit \
      popt \
      pycurl \
      pyparsing \
      python-Jinja2 \
      python-MarkupSafe \
      python-PyYAML \
      python-appdirs \
      python-certifi \
      python-cffi \
      python-chardet \
      python-charset-normalizer \
      python-distro \
      python-dnspython \
      python-doxypypy \
      python-doxyqml \
      python-future \
      python-idna \
      python-notify2 \
      python-packaging \
      python-pbr \
      python-pillow \
      python-ply \
      python-pycparser \
      python-pygments \
      python-random2 \
      python-requests \
      python-setuptools_scm \
      python-six \
      python-tomli \
      python-urllib3 \
      qrencode \
      quazip \
      readline \
      rpcsvc-proto \
      rttr \
      rubygem-asciidoctor \
      sbc \
      serf \
      sg3_utils \
      shared-desktop-ontologies \
      shared-mime-info \
      slang \
      slang1 \
      spirv-llvm-translator \
      t1lib \
      tdb \
      tevent \
      utf8proc \
      vid.stab \
      woff2 \
      xapian-core \
      xxHash \
      zlib \
      zstd

# series n
RUN echo y | slackpkg install \
      ca-certificates \
      c-ares \
      curl \
      cyrus-sasl \
      gnutls \
      gpgme \
      libassuan \
      libgcrypt \
      libgpg-error \
      nettle \
      nghttp2 \
      p11-kit \
      rsync \
      stunnel

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
ARG CURL_VER=7.88.1
RUN /bin/bash -c 'cd /tmp \
  && curl -LO https://github.com/curl/curl/releases/download/curl-7_88_1/curl-$CURL_VER.tar.xz \
  && tar xf curl*xz -C /tmp \
  && cd /tmp/curl-$CURL_VER \
  && autoreconf -if \
  && mkdir build && cd build \
  && ../configure --with-openssl --with-libssh2 --with-gssapi --enable-ares --enable-static=no --without-ca-bundle --with-ca-path=/etc/ssl/certs \
  && make -j$(nproc) \
  && make -C tests -j$(nproc) \
  && cd .. && rm -rf build && mkdir build && cd build \
  && ../configure --enable-warnings --enable-werror --with-gnutls \
  && make -j$(nproc) \
  && make -C tests -j$(nproc) \
  && cd \
  && rm -rf /tmp/curl*'

# Test a meson build
ARG RMW_VER=0.9.0
RUN /bin/bash -c 'cd /tmp \
  && curl -LO https://github.com/theimpossibleastronaut/rmw/releases/download/v$RMW_VER/rmw-$RMW_VER.tar.xz \
  && tar xf rmw-$RMW_VER.tar.xz \
  && cd rmw-$RMW_VER \
  && meson setup _build \
  && cd _build \
  && meson compile \
  && meson test \
  && cd / \
  && rm -rf /tmp/rmw* '

CMD ["/bin/bash","-l"]
