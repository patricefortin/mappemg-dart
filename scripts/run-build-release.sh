#!/bin/bash
set -e
set -x

cd "$(dirname "$0")"
cd ..

VERSION=$(dart run lib/main_version.dart)
TARGET="releases/s2m-mappemg-${VERSION}.apk"

if [ -f $TARGET ]; then
    echo "Target $TARGET already exists. Please update version in lib/constants.dart"
    exit 1
fi


sed -i "s/^version:.*/version: ${VERSION}/" pubspec.yaml

flutter build apk
cp build/app/outputs/flutter-apk/app-release.apk $TARGET

#git add $TARGET $ANDROID_PROPERTIES
git add $TARGET lib/constants.dart pubspec.yaml
git status

echo "## Run this to push"
echo "# git commit -m 'release ${VERSION}' && git push"
