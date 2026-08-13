#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q octave | awk '{print $2; exit}') # example command to get version of application here
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/256x256/apps/octave.png
export DEPLOY_QT=1
export QT_DIR=qt6

# Deploy dependencies
#quick-sharun /usr/bin/gnuplot* \
#/usr/bin/octave \
#/usr/bin/octave-cli \
#/usr/lib/octave \
#/usr/lib/qt6/plugins/sqldrivers \
#/usr/share/octave \
#/usr/share/gnuplot

quick-sharun \
/usr/bin/octave \
/usr/bin/octave-cli \
/usr/lib/octave \
/usr/lib/qt6/plugins/sqldrivers \
/usr/share/octave

# Additional changes can be done in between here
echo 'OCTAVE_HOME=$APPDIR' >> ./AppDir/.env

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --simple-test ./dist/*.AppImage
