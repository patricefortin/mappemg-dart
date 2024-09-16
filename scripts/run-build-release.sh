#!/bin/bash
set -e
set -x

cd "$(dirname "$0")"
cd ..

VERSION=$(dart run lib/main_version.dart)
TARGET_APK="releases/s2m-mappemg-${VERSION}.apk"
TARGET_AAB="releases/s2m-mappemg-${VERSION}.aab"

if [ -f $TARGET_APK ]; then
    echo "Target $TARGET_APK already exists. Please update version in lib/constants.dart"
    exit 1
fi

if [ -f $TARGET_AAB ]; then
    echo "Target $TARGET_AAB already exists. Please update version in lib/constants.dart"
    exit 1
fi


sed -i "s/^version:.*/version: ${VERSION}/" pubspec.yaml

flutter build apk
cp build/app/outputs/flutter-apk/app-release.apk $TARGET_APK

flutter build appbundle
cp build/app/outputs/bundle/release/app-release.aab $TARGET_AAB

git add $TARGET_APK $TARGET_AAB lib/constants.dart pubspec.yaml
git status

echo "## Run this to push"
echo "# git commit -m 'release ${VERSION}' && git push"
