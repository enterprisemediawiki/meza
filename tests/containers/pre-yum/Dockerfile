FROM enterprisemediawiki/meza:base
LABEL MAINTAINER James Montalvo
ENV container=docker

# Install packages from getmeza.sh
RUN yum -y install \
    git \
    ansible

# Install packages from meza base role
RUN yum -y install \
    ntp \
    ntpdate \
    ntp-doc \
    openssh-server \
    openssh-clients \
    vim \
    net-tools \
    firewalld \
    jq

# Install packages from base-extras role
RUN yum -y install \
    expect \
    expectk \
    perl \
    wget \
    gcc \
    cifs-utils

# Install packages from php and httpd
RUN yum -y install \
    httpd-devel \
    mod_ssl \
    mod_proxy_html \
    zlib-devel \
    sqlite-devel \
    bzip2-devel \
    pcre-devel \
    openssl-devel \
    curl-devel \
    libxml2-devel \
    libXpm-devel \
    gmp-devel \
    libicu-devel \
    t1lib-devel \
    aspell-devel \
    libcurl-devel \
    libjpeg-devel \
    libvpx-devel \
    libpng-devel \
    freetype-devel \
    readline-devel \
    libtidy-devel \
    libmcrypt-devel \
    pam-devel \
    sendmail \
    sendmail-cf \
    m4 \
    xz-libs \
    mariadb-libs

# Clean up
RUN yum clean all