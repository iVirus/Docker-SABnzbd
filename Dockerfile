FROM bmoorman/ubuntu:focal

ARG DEBIAN_FRONTEND=noninteractive

ENV PIA_USER="**username**" \
    PIA_PASS="**password**" \
    LOCAL_NETWORK="192.168.0.0/16" \
    SABNZBD_PORT=8080

WORKDIR /etc/openvpn

RUN echo 'deb http://ppa.launchpad.net/jcfp/nobetas/ubuntu focal main' > /etc/apt/sources.list.d/sabnzbd.list \
 && echo 'deb-src http://ppa.launchpad.net/jcfp/nobetas/ubuntu focal main' >> /etc/apt/sources.list.d/sabnzbd.list \
 && echo 'deb http://ppa.launchpad.net/jcfp/sab-addons/ubuntu focal main' > /etc/apt/sources.list.d/sabnzbd-addons.list \
 && echo 'deb-src http://ppa.launchpad.net/jcfp/sab-addons/ubuntu focal main' >> /etc/apt/sources.list.d/sabnzbd-addons.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F13930B14BB9F05F \
 && apt-get update \
 && apt-get install --yes --no-install-recommends \
    curl \
    openssh-client \
    openvpn \
    p7zip-full \
    par2-tbb \
    python3-cryptography \
    python3-sabyenc \
    sabnzbdplus \
    unrar \
    unzip \
    wget \
 && wget --quiet --directory-prefix /tmp "http://ftp.debian.org/debian/pool/main/n/netselect/netselect_0.3.ds1-28+b1_amd64.deb" \
 && dpkg --install /tmp/netselect_*_amd64.deb \
 && wget --quiet --directory-prefix /usr/local/share/ca-certificates "https://raw.githubusercontent.com/pia-foss/manual-connections/master/ca.rsa.4096.crt" \
 && update-ca-certificates \
 && wget --quiet --directory-prefix /etc/openvpn "https://www.privateinternetaccess.com/openvpn/openvpn.zip" \
 && apt-get autoremove --yes --purge \
 && apt-get clean \
 && rm --recursive --force /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY openvpn/ /etc/openvpn/
COPY sabnzbd/ /etc/sabnzbd/

VOLUME /config /data

EXPOSE ${SABNZBD_PORT}

CMD ["/etc/openvpn/start.sh"]

HEALTHCHECK --interval=60s --timeout=5s CMD curl --head --insecure --silent --show-error --fail "http://localhost:${SABNZBD_PORT}/" || exit 1
