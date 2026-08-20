FROM ubuntu:26.04

COPY Makefile /
COPY patch-mlme.patch /
COPY dkms.conf /

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y patch dkms dpkg-dev linux-headers-generic linux-source build-essential linux-image-generic

COPY /scripts/uname /usr/local/bin/

RUN chmod +x /usr/local/bin/uname && \
    cd / && make && \
    mkdir -p /usr/src/sane-mac80211-1.0 && \
    cp dkms.conf Makefile patch-mlme.patch /usr/src/sane-mac80211-1.0/ #&& \
    #dkms build sane-mac80211/1.0
