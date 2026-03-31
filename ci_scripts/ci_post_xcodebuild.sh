#!/bin/sh
# ci_post_xcodebuild.sh
# Xcode Cloud executes this automatically after every xcodebuild action.
#
# Fix: "Upload Symbols Failed" for GoogleMobileAds.framework and
# UserMessagingPlatform.framework. These are pre-built binary frameworks
# distributed via SPM without dSYMs. This script downloads them from
# Google's CDN and places them in the archive before Apple processes it.

set -e

# Only run during archive (not test/build)
if [ "$CI_XCODEBUILD_ACTION" != "archive" ]; then
    echo "ci_post_xcodebuild: skipping dSYM fix (action=$CI_XCODEBUILD_ACTION)"
    exit 0
fi

echo "ci_post_xcodebuild: downloading GoogleMobileAds dSYMs..."

DSYM_DIR="${CI_ARCHIVE_PATH}/dSYMs"
TEMP_DIR=$(mktemp -d)

# Download latest Google Mobile Ads SDK zip (contains dSYMs)
curl -L --silent --show-error \
    "https://dl.google.com/googleadmobadssdk/googlemobileadssdkios.zip" \
    --output "${TEMP_DIR}/googlemobileads.zip"

if [ $? -ne 0 ]; then
    echo "ci_post_xcodebuild: warning — could not download dSYMs. Symbols warning will appear in App Store Connect but will NOT block TestFlight submission."
    rm -rf "${TEMP_DIR}"
    exit 0
fi

# Extract zip
unzip -q "${TEMP_DIR}/googlemobileads.zip" -d "${TEMP_DIR}/extracted"

# Copy every dSYM found into the archive's dSYMs folder
find "${TEMP_DIR}/extracted" -name "*.dSYM" | while read DSYM_PATH; do
    DSYM_NAME=$(basename "${DSYM_PATH}")
    echo "ci_post_xcodebuild: copying ${DSYM_NAME}"
    cp -rf "${DSYM_PATH}" "${DSYM_DIR}/"
done

rm -rf "${TEMP_DIR}"
echo "ci_post_xcodebuild: dSYM copy complete."
