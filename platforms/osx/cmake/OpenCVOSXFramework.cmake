include(platforms/osx/cmake/OpenCVOSXFrameworkFunctions.cmake REQUIRED)

# Set the framework's path to itself (first line of `otool -L ${OSX_FRAMEWORK_NAME}`)
if (OSX_FRAMEWORK_LINKER_PATH_CUSTOM)
  get_filename_component (OSX_FRAMEWORK_LINKER_PATH_CUSTOM_PATH ${OSX_FRAMEWORK_LINKER_PATH_CUSTOM} PATH)
  get_filename_component (OSX_FRAMEWORK_LINKER_PATH_CUSTOM_NAME ${OSX_FRAMEWORK_LINKER_PATH_CUSTOM} NAME)
  set (OSX_FRAMEWORK_LINKER_PATH "${OSX_FRAMEWORK_LINKER_PATH_CUSTOM_PATH}/${OSX_FRAMEWORK_LINKER_PATH_CUSTOM_NAME}")
else (OSX_FRAMEWORK_LINKER_PATH_CUSTOM)
  if (OSX_FRAMEWORK_LINKER_PATH_ABSOLUTE)
    set (OSX_FRAMEWORK_LINKER_PATH "/Library/Frameworks/")
  else (OSX_FRAMEWORK_LINKER_PATH_ABSOLUTE)
    set (OSX_FRAMEWORK_LINKER_PATH "@executable_path/../Frameworks")
  endif (OSX_FRAMEWORK_LINKER_PATH_ABSOLUTE)
endif (OSX_FRAMEWORK_LINKER_PATH_CUSTOM)

# General Framework Setup
add_framework (${OSX_FRAMEWORK_TARGET_NAME} ${OSX_FRAMEWORK_NAME} ${OSX_FRAMEWORK_CPP_FILE} ${OSX_FRAMEWORK_VERSION} ${OSX_FRAMEWORK_LINKER_PATH})
set_xcode_debug_info (${OSX_FRAMEWORK_TARGET_NAME})
include_directories (${OSX_FRAMEWORK_TARGET_NAME} "include")

# Include all OpenCV library modules
foreach (OPENCV_MODULE_FULL_NAME ${OPENCV_MODULES_BUILD})
  string (REGEX REPLACE "^opencv_" "" OPENCV_MODULE_SHORT_NAME "${OPENCV_MODULE_FULL_NAME}")
  # The dependencies are only used for install_name_tool
  ## Therefore having too many can never be a problem but missing one can
  ## So we'll just use all the modules currently being built
  ## This is necessary since in some cases (calib3d, gpu, nonfree, stitching)
  ## the linker flags contain a dependency to opencv_highgui when
  ## ${OPENCV_MODULE_${OPENCV_MODULE_FULL_NAME}_DEPS} doesn't
  set (OPENCV_MODULE_DEPS ${OPENCV_MODULES_BUILD})
  get_target_property (OPENCV_MODULE_VERSION "${OPENCV_MODULE_FULL_NAME}" VERSION)
  get_target_property (OPENCV_MODULE_SOVERSION "${OPENCV_MODULE_FULL_NAME}" SOVERSION)
  # This seperates sublibraries from independent ones such as the python module
  if (OPENCV_MODULE_VERSION AND OPENCV_MODULE_SOVERSION)
    add_framework_sublibrary (${OSX_FRAMEWORK_TARGET_NAME} "${OPENCV_MODULE_FULL_NAME}" "${OPENCV_MODULE_DEPS}")
    set (OPENCV_MODULE_INCLUDE_DIR "${OPENCV_MODULE_${OPENCV_MODULE_FULL_NAME}_LOCATION}/include")
    if (EXISTS ${OPENCV_MODULE_INCLUDE_DIR})
      include_directories (${OSX_FRAMEWORK_TARGET_NAME} "${OPENCV_MODULE_INCLUDE_DIR}")
      set (OPENCV_MODULE_INCLUDE_NAME_DIR "${OPENCV_MODULE_INCLUDE_DIR}/opencv2/${OPENCV_MODULE_SHORT_NAME}")
      if (EXISTS ${OPENCV_MODULE_INCLUDE_NAME_DIR})
        add_framework_header (${OSX_FRAMEWORK_TARGET_NAME} "${OPENCV_MODULE_INCLUDE_NAME_DIR}")
      endif (EXISTS ${OPENCV_MODULE_INCLUDE_NAME_DIR})
    else (EXISTS ${OPENCV_MODULE_INCLUDE_DIR})
      MESSAGE(STATUS "${OPENCV_MODULE_FULL_NAME} DOES NOT HAVE THIS DIRECTORY: ${OPENCV_MODULE_INCLUDE_DIR}")
    endif (EXISTS ${OPENCV_MODULE_INCLUDE_DIR})
  else (OPENCV_MODULE_VERSION AND OPENCV_MODULE_SOVERSION)
    add_framework_independent_library(${OSX_FRAMEWORK_TARGET_NAME} "${OPENCV_MODULE_FULL_NAME}" "${OPENCV_MODULE_DEPS}" "${OSX_FRAMEWORK_LINKER_PATH}")
  endif (OPENCV_MODULE_VERSION AND OPENCV_MODULE_SOVERSION)
  set_xcode_debug_info ("${OPENCV_MODULE_FULL_NAME}")
endforeach (OPENCV_MODULE_FULL_NAME ${OPENCV_MODULES_BUILD})

# Copy cv.py to framework
add_file_to_framework_subdir_without_symlink (${OSX_FRAMEWORK_TARGET_NAME} "." "${CMAKE_CURRENT_SOURCE_DIR}/modules/python/src2/cv.py")
add_symlink_directing_to_framework_subdir (${OSX_FRAMEWORK_TARGET_NAME} "cv.py")

# Copy all global OpenCV headers to framework
file (GLOB OPENCV_HEADERS "${CMAKE_CURRENT_SOURCE_DIR}/include/opencv2/*.hpp")
foreach (header_file ${OPENCV_HEADERS})
  add_framework_header (${OSX_FRAMEWORK_TARGET_NAME} ${header_file})
endforeach (header_file ${OPENCV_HEADERS})

# Copy training data to framework
file (GLOB OPENCV_HAARCASCADES "${CMAKE_CURRENT_SOURCE_DIR}/data/haarcascades/*")
foreach (data_file ${OPENCV_HAARCASCADES})
  add_file_to_framework_subdir_without_symlink (${OSX_FRAMEWORK_TARGET_NAME} "Resources/data/haarcascades" ${data_file})
endforeach (data_file ${OPENCV_HAARCASCADES})

file (GLOB OPENCV_HOGCASCADES "${CMAKE_CURRENT_SOURCE_DIR}/data/hogcascades/*")
foreach (data_file ${OPENCV_HOGCASCADES})
  add_file_to_framework_subdir_without_symlink (${OSX_FRAMEWORK_TARGET_NAME} "Resources/data/hogcascades" ${data_file})
endforeach (data_file ${OPENCV_HOGCASCADES})

file (GLOB OPENCV_LBPCASCADES "${CMAKE_CURRENT_SOURCE_DIR}/data/lbpcascades/*")
foreach (data_file ${OPENCV_LBPCASCADES})
  add_file_to_framework_subdir_without_symlink (${OSX_FRAMEWORK_TARGET_NAME} "Resources/data/lbpcascades" ${data_file})
endforeach (data_file ${OPENCV_LBPCASCADES})

file (GLOB OPENCV_VECFILES "${CMAKE_CURRENT_SOURCE_DIR}/data/vec_files/*")
foreach (data_file ${OPENCV_VECFILES})
  add_file_to_framework_subdir_without_symlink (${OSX_FRAMEWORK_TARGET_NAME} "Resources/data/vec_files" ${data_file})
endforeach (data_file ${OPENCV_VECFILES})

# Rewrite path to other header files in framework header files only if framework name has changed
if (NOT ("${OSX_FRAMEWORK_NAME}" STREQUAL "opencv2"))
  get_target_property (OPENCV_HEADERS_LOCATION ${OSX_FRAMEWORK_TARGET_NAME} CONTENTS_OF_Headers_DIRECTORY)
  foreach (header_file ${OPENCV_HEADERS_LOCATION})
    add_custom_command (TARGET ${OSX_FRAMEWORK_TARGET_NAME}
                               POST_BUILD
                               COMMAND find
                               ARGS ${header_file} -iregex "'.*hp*'" -exec sed -i "''" -e "'s|#include[ \\t]*\"opencv2/\\([^\"]*\\)\"|#include \"${OSX_FRAMEWORK_NAME}/\\1\"|'" {} +)
  endforeach (header_file ${OPENCV_HEADERS_LOCATION})
endif (NOT ("${OSX_FRAMEWORK_NAME}" STREQUAL "opencv2"))

