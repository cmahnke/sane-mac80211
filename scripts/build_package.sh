#!/bin/sh
set -e

rm -r -f build repo-dist

mkdir -p build/sane-mac80211_1.0_all/usr/src/sane-mac80211-1.0
mkdir -p build/sane-mac80211_1.0_all/DEBIAN

cp DEBIAN/* build/sane-mac80211_1.0_all/DEBIAN/
cp dkms.conf Makefile patch-mlme.patch build/sane-mac80211_1.0_all/usr/src/sane-mac80211-1.0/

dpkg-deb --build build/sane-mac80211_1.0_all
mkdir repo-dist
mv build/sane-mac80211_1.0_all.deb repo-dist/

cd repo-dist
dpkg-scanpackages --multiversion . > Packages
gzip -k -f Packages

apt-ftparchive release . > Release

# sq soesn't have a stable interface, this will fail on ubuntu 26.04
sq sign --signer-file ../private.key --cleartext-signature Release > InRelease
sq sign --signer-file ../private.key --detached Release > Release.gpg

cp ../public.key public.gpg
rm -f ../private.key
