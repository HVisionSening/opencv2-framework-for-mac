#!/bin/bash

export CMAKE_OSX_ARCHITECTURES="x86_64;i386"
export FRAMEWORK_NAME="OpenCV2"
export FRAMEWORK_PROJECT_NAME="OpenCV_OSXFramework"
export FRAMEWORK_BUILD_CONFIGURATION="Release"

cd `dirname $0`
SOURCE_DIR=`pwd`
BUILD_DIR=$SOURCE_DIR/build
OUTPUT_DIR=$SOURCE_DIR/OSX-Frameworks

rm -rf $BUILD_DIR
mkdir $BUILD_DIR
rm -rf $OUTPUT_DIR
mkdir $OUTPUT_DIR

cd $BUILD_DIR
cmake -G "Xcode" \
-D "OSX_FRAMEWORK_NAME=$FRAMEWORK_NAME" \
-D "OSX_FRAMEWORK_TARGET_NAME=$FRAMEWORK_PROJECT_NAME" \
-D "OSX_FRAMEWORK_LINKER_PATH_ABSOLUTE=OFF" \
-D "WITH_AVFOUNDATION=ON" \
-D "BUILD_opencv_java=ON" \
-D "BUILD_opencv_python=ON" \
-D "BUILD_NEW_PYTHON_SUPPORT=ON" \
-D "BUILD_DOCS=OFF" \
-D "BUILD_EXAMPLES=OFF" \
-D "BUILD_TESTS=OFF" \
-D "BUILD_PERF_TESTS=OFF" \
-D "OSX_FRAMEWORK_CREATE_DSYM=ON" \
-D "PYTHON_EXECUTABLE=/usr/bin/python" \
-D "PYTHON_LIBRARIES=/System/Library/Frameworks/Python.framework/Versions/2.7/lib/libpython2.7.dylib" \
-D "PYTHON_INCLUDE_PATH=/System/Library/Frameworks/Python.framework/Versions/2.7/include/python2.7" \
-D "PYTHON_EXECUTABLE_PYTHONORG=/usr/local/bin/python" \
-D "PYTHON_LIBRARIES_PYTHONORG=/Library/Frameworks/Python.framework/Versions/2.7/lib/libpython2.7.dylib" \
-D "PYTHON_INCLUDE_PATH_PYTHONORG=/Library/Frameworks/Python.framework/Versions/2.7/include/python2.7" \
$SOURCE_DIR

xcodebuild -project OpenCV.xcodeproj -target $FRAMEWORK_PROJECT_NAME -configuration $FRAMEWORK_BUILD_CONFIGURATION
cp -PR lib/Release/$FRAMEWORK_NAME.framework $OUTPUT_DIR

echo
echo
echo "Done. $FRAMEWORK_NAME.framework is in OSX-Frameworks."

exit 0
