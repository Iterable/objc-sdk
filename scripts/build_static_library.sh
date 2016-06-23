# based on https://www.raywenderlich.com/65964/create-a-framework-for-ios and https://github.com/jverkoey/iOS-Framework#static_library_target
# also, need to explicitly add armv7s to target architectures; see also: http://stackoverflow.com/questions/28270582/building-ios-framework-missing-architecture-armv7s-and-x86-64-on-fat-file

set -o errexit
set +o nounset
# Avoid recursively calling this script.
if [[ $ITBL_MASTER_SCRIPT_RUNNING ]]; then
    exit 0
fi
set -o nounset
export ITBL_MASTER_SCRIPT_RUNNING=1

ITBL_TARGET_NAME=${PROJECT_NAME}
ITBL_EXECUTABLE_PATH="lib${ITBL_TARGET_NAME}.a"
ITBL_WRAPPER_NAME="${ITBL_TARGET_NAME}.framework"

# The following conditionals come from
# https://github.com/kstenerud/iOS-Universal-Framework

if [[ "$SDK_NAME" =~ ([A-Za-z]+) ]]; then
    ITBL_SDK_PLATFORM=${BASH_REMATCH[1]}
else
    echo "Could not find platform name from SDK_NAME: $SDK_NAME"
    exit 1
fi

if [[ "$SDK_NAME" =~ ([0-9]+.*$) ]]; then
    ITBL_SDK_VERSION=${BASH_REMATCH[1]}
else
    echo "Could not find sdk version from SDK_NAME: $SDK_NAME"
    exit 1
fi

# Build for the simulator architecture
echo "Building static library: workspace=${PROJECT_DIR}/${PROJECT_NAME}.xcworkspace, scheme=${ITBL_TARGET_NAME}, platform=iphonesimulator, destination='platform=iOS Simulator,name=iPad'"
# iPhone5 is the last one on armv7s, iPhone6+ is on armv7
xcrun xcodebuild ONLY_ACTIVE_ARCH=NO -workspace "${PROJECT_DIR}/${PROJECT_NAME}.xcworkspace" -scheme "${ITBL_TARGET_NAME}" -configuration "${CONFIGURATION}" -sdk iphonesimulator -destination "platform=iOS Simulator,name=iPhone 6" BUILD_DIR="${BUILD_DIR}" OBJROOT="${OBJROOT}" BUILD_ROOT="${BUILD_ROOT}" SYMROOT="${SYMROOT}" $ACTION

# Build for real devices
echo "Building static library: workspace=${PROJECT_DIR}/${PROJECT_NAME}.xcworkspace, scheme=${ITBL_TARGET_NAME}, platform=iphoneos, sdk version=${ITBL_SDK_VERSION}"
xcrun xcodebuild ONLY_ACTIVE_ARCH=NO -workspace "${PROJECT_DIR}/${PROJECT_NAME}.xcworkspace" -scheme "${ITBL_TARGET_NAME}" -configuration "${CONFIGURATION}" -sdk iphoneos${ITBL_SDK_VERSION} BUILD_DIR="${BUILD_DIR}" OBJROOT="${OBJROOT}" BUILD_ROOT="${BUILD_ROOT}" SYMROOT="${SYMROOT}" $ACTION

echo "Done building architectures. Running lipo..."

DESTINATION_UNIVERSAL_DIR="${BUILD_ROOT}/Universal/"
mkdir -p ${DESTINATION_UNIVERSAL_DIR}
# Smash the two static libraries into one fat binary and store it in the .framework
xcrun lipo -create "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${ITBL_EXECUTABLE_PATH}" "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${ITBL_EXECUTABLE_PATH}" -output "${DESTINATION_UNIVERSAL_DIR}/${ITBL_TARGET_NAME}.a"
