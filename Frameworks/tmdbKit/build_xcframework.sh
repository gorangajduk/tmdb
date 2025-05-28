#!/bin/bash

# Configuration
FRAMEWORK_NAME="tmdbKit"
SCHEME_IOS="tmdbKit"
SCHEME_TVOS="tmdbKitTV"
SCHEME_MACOS="tmdbKitMac"

# Output directories
CURRENT_DIR=$(pwd)
BUILD_DIR="${CURRENT_DIR}/Build"
OUTPUT_DIR="${CURRENT_DIR}/Products/${FRAMEWORK_NAME}.xcframework"

# --- Clean up previous builds ---
echo "🧹 Cleaning up previous builds..."
rm -rf "${BUILD_DIR}"
rm -rf "${OUTPUT_DIR}"
mkdir -p "${BUILD_DIR}"
mkdir -p "${OUTPUT_DIR}" # Create output directory for xcframework

# --- Build for iOS ---
echo "🚀 Building for iOS (Device)..."
xcodebuild archive \
    -scheme "${SCHEME_IOS}" \
    -destination "generic/platform=iOS" \
    -archivePath "${BUILD_DIR}/${FRAMEWORK_NAME}-iOS" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARIES_FOR_DISTRIBUTION=YES \
    SWIFT_BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    -quiet

echo "🚀 Building for iOS (Simulator)..."
xcodebuild archive \
    -scheme "${SCHEME_IOS}" \
    -destination "generic/platform=iOS Simulator" \
    -archivePath "${BUILD_DIR}/${FRAMEWORK_NAME}-iOS_Simulator" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARIES_FOR_DISTRIBUTION=YES \
    SWIFT_BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    -quiet

# --- Build for tvOS ---
echo "📺 Building for tvOS (Device)..."
xcodebuild archive \
    -scheme "${SCHEME_TVOS}" \
    -destination "generic/platform=tvOS" \
    -archivePath "${BUILD_DIR}/${FRAMEWORK_NAME}-tvOS" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARIES_FOR_DISTRIBUTION=YES \
    SWIFT_BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    -quiet

echo "📺 Building for tvOS (Simulator)..."
xcodebuild archive \
    -scheme "${SCHEME_TVOS}" \
    -destination "generic/platform=tvOS Simulator" \
    -archivePath "${BUILD_DIR}/${FRAMEWORK_NAME}-tvOS_Simulator" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARIES_FOR_DISTRIBUTION=YES \
    SWIFT_BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    -quiet

# --- Build for macOS ---
echo "💻 Building for macOS..."
xcodebuild archive \
    -scheme "${SCHEME_MACOS}" \
    -destination "generic/platform=macOS" \
    -archivePath "${BUILD_DIR}/${FRAMEWORK_NAME}-macOS" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARIES_FOR_DISTRIBUTION=YES \
    SWIFT_BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    -quiet


# --- Create XCFramework ---
echo "📦 Creating ${FRAMEWORK_NAME}.xcframework..."
xcodebuild -create-xcframework \
    -archive "${BUILD_DIR}/${FRAMEWORK_NAME}-iOS.xcarchive" -framework "${FRAMEWORK_NAME}.framework" \
    -archive "${BUILD_DIR}/${FRAMEWORK_NAME}-iOS_Simulator.xcarchive" -framework "${FRAMEWORK_NAME}.framework" \
    -archive "${BUILD_DIR}/${FRAMEWORK_NAME}-tvOS.xcarchive" -framework "${SCHEME_TVOS}.framework" \
    -archive "${BUILD_DIR}/${FRAMEWORK_NAME}-tvOS_Simulator.xcarchive" -framework "${SCHEME_TVOS}.framework" \
    -archive "${BUILD_DIR}/${FRAMEWORK_NAME}-macOS.xcarchive" -framework "${SCHEME_MACOS}.framework" \
    -output "${OUTPUT_DIR}"

# --- Clean up intermediate archives ---
echo "🗑️ Cleaning up intermediate archive files..."
rm -rf "${BUILD_DIR}"

echo "✅ ${FRAMEWORK_NAME}.xcframework created at: ${OUTPUT_DIR}"