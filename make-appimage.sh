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
quick-sharun /usr/lib/octave /usr/share/octave /usr/bin/octave /usr/bin/octave-cli /usr/lib/qt6/plugins/sqldrivers

# Override AppRun to launch via octave wrapper (needed for --gui flag, display init,
# and runtime Qt SQL plugin loading which quick-sharun can't auto-detect)
#cat > AppDir/AppRun << 'EOF'
#!/bin/sh
#CURRENTDIR="$(dirname "$(readlink -f "$0")")"
#HOOKSDIR="${CURRENTDIR}/.hooks"
#if [ -d "${HOOKSDIR}" ]; then
#    for hook in "${HOOKSDIR}"/*.hook; do
#        [ -f "${hook}" ] || continue
#        case "${hook}" in
#            *.bg.hook)
#                "${hook}" &
#                ;;
#            *)
#                . "${hook}"
#                ;;
#        esac
#    done
#fi
#. "${CURRENTDIR}/.env"
#exec "${CURRENTDIR}/bin/octave" --gui "$@"
#EOF

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --simple-test ./dist/*.AppImage
