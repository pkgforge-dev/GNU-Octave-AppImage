#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q octave | awk '{print $2; exit}')
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export DESKTOP=/usr/share/applications/org.octave.Octave.desktop
export ICON=/usr/share/icons/hicolor/256x256/apps/octave.png
export USE_HOST_DRIVERS_EXPERIMENTAL=1

# The arch package incorrectly gives executacle bit to files in /usr/lib/octave/11.3.0/oct
# These are all shared objects and not executables, this confuses quick-sharun
find /usr/lib/octave/*/oct -type f -exec chmod -x {} \;

# Deploy dependencies
quick-sharun \
	/usr/bin/octave*   \
	/usr/lib/octave    \
	/usr/share/octave  \
	/usr/bin/gnuplot*  \
	/usr/share/gnuplot \
	/usr/lib/qt6/plugins/sqldrivers

echo 'OCTAVE_HOME=$APPDIR' >> ./AppDir/.env

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the app normally quits before that time
# then skip this or check if some flag can be passed that makes it stay open
quick-sharun --simple-test ./dist/*.AppImage
