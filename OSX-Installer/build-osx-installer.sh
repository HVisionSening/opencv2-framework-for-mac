#!/bin/bash
 
if [ $# -ne 1 ]; then
  echo "usage : createMacInstaller.sh VERSION"
  exit
fi

cd `dirname $0`
BASE_DIR=`pwd`
 
FILES="$BASE_DIR/../OSX-Frameworks"
DISTXML="$BASE_DIR/Distribution.xml"
TARGET="/Library/Frameworks"
IDENTIFIER="biz.kyogoku.apps.OpenCV2-framework"
RESOURCES="$BASE_DIR/Resources"
SCRIPTS="$BASE_DIR/Scripts"
PKGNAME="tmp.pkg"
OUTPUT="OpenCV2 Framework.pkg"
VERSION=$1
 
pkgbuild --root $FILES \
        --identifier $IDENTIFIER \
        --install-location $TARGET \
        --scripts $SCRIPTS \
        --version $VERSION \
        "$PKGNAME"

if [ $1 == "0" ]; then
productbuild --synthesize \
            --package tmp.pkg \
            ./Distribution.xml
fi
 
productbuild --distribution $DISTXML \
            --package-path . \
            --resources $RESOURCES \
            "$OUTPUT"
