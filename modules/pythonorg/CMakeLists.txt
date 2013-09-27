# ----------------------------------------------------------------------------
#  CMake file for pythonorg-python support
# ----------------------------------------------------------------------------

if(ANDROID OR IOS OR NOT PYTHONLIBS_FOUND_PYTHONORG OR NOT PYTHON_USE_NUMPY_PYTHONORG)
  ocv_module_disable(pythonorg)
endif()

set(the_description "The pythonorg-python bindings")
ocv_add_module(pythonorg BINDINGS opencv_core opencv_flann opencv_imgproc opencv_video opencv_ml opencv_features2d opencv_highgui opencv_calib3d opencv_photo opencv_objdetect opencv_contrib opencv_legacy OPTIONAL opencv_nonfree)

add_definitions(-DPYTHON_USE_NUMPY=1)

ocv_module_include_directories(
    "${PYTHON_INCLUDE_PATH_PYTHONORG}"
    "${PYTHON_NUMPY_INCLUDE_DIR_PYTHONORG}"
    "${CMAKE_CURRENT_SOURCE_DIR}/src2"
    )

set(opencv_hdrs
    "${OPENCV_MODULE_opencv_core_LOCATION}/include/opencv2/core/core.hpp"
    "${OPENCV_MODULE_opencv_flann_LOCATION}/include/opencv2/flann/miniflann.hpp"
    "${OPENCV_MODULE_opencv_imgproc_LOCATION}/include/opencv2/imgproc/imgproc.hpp"
    "${OPENCV_MODULE_opencv_video_LOCATION}/include/opencv2/video/background_segm.hpp"
    "${OPENCV_MODULE_opencv_video_LOCATION}/include/opencv2/video/tracking.hpp"
    "${OPENCV_MODULE_opencv_photo_LOCATION}/include/opencv2/photo/photo.hpp"
    "${OPENCV_MODULE_opencv_highgui_LOCATION}/include/opencv2/highgui/highgui.hpp"
    "${OPENCV_MODULE_opencv_ml_LOCATION}/include/opencv2/ml/ml.hpp"
    "${OPENCV_MODULE_opencv_features2d_LOCATION}/include/opencv2/features2d/features2d.hpp"
    "${OPENCV_MODULE_opencv_calib3d_LOCATION}/include/opencv2/calib3d/calib3d.hpp"
    "${OPENCV_MODULE_opencv_objdetect_LOCATION}/include/opencv2/objdetect/objdetect.hpp"
    "${OPENCV_MODULE_opencv_contrib_LOCATION}/include/opencv2/contrib/contrib.hpp")

if(HAVE_opencv_nonfree)
  list(APPEND opencv_hdrs     "${OPENCV_MODULE_opencv_nonfree_LOCATION}/include/opencv2/nonfree/features2d.hpp"
                              "${OPENCV_MODULE_opencv_nonfree_LOCATION}/include/opencv2/nonfree/nonfree.hpp")
endif()

set(cv2_generated_hdrs
    "${CMAKE_CURRENT_BINARY_DIR}/pyopencv_generated_funcs.h"
    "${CMAKE_CURRENT_BINARY_DIR}/pyopencv_generated_func_tab.h"
    "${CMAKE_CURRENT_BINARY_DIR}/pyopencv_generated_types.h"
    "${CMAKE_CURRENT_BINARY_DIR}/pyopencv_generated_type_reg.h"
    "${CMAKE_CURRENT_BINARY_DIR}/pyopencv_generated_const_reg.h")

add_custom_command(
   OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/generated0.i
   COMMAND ${PYTHON_EXECUTABLE_PYTHONORG} "${CMAKE_CURRENT_SOURCE_DIR}/src2/gen.py" "${CMAKE_CURRENT_SOURCE_DIR}/src2"
   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/src2/api
   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/src2/defs
   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/src2/gen.py)

add_custom_command(
   OUTPUT ${cv2_generated_hdrs}
   COMMAND ${PYTHON_EXECUTABLE_PYTHONORG} "${CMAKE_CURRENT_SOURCE_DIR}/src2/gen2.py" ${CMAKE_CURRENT_BINARY_DIR} ${opencv_hdrs}
   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/src2/gen2.py
   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/src2/hdr_parser.py
   DEPENDS ${opencv_hdrs})

add_library(${the_module} SHARED src2/cv2.cpp ${CMAKE_CURRENT_BINARY_DIR}/generated0.i ${cv2_generated_hdrs} src2/cv2.cv.hpp)
if(PYTHON_DEBUG_LIBRARIES_PYTHONORG AND NOT PYTHON_LIBRARIES_PYTHONORG MATCHES "optimized.*debug")
  target_link_libraries(${the_module} debug ${PYTHON_DEBUG_LIBRARIES_PYTHONORG} optimized ${PYTHON_LIBRARIES_PYTHONORG})
else()
  target_link_libraries(${the_module} ${PYTHON_LIBRARIES_PYTHONORG})
endif()
target_link_libraries(${the_module} ${OPENCV_MODULE_${the_module}_DEPS})

execute_process(COMMAND ${PYTHON_EXECUTABLE_PYTHONORG} -c "import distutils.sysconfig; print distutils.sysconfig.get_config_var('SO')"
                RESULT_VARIABLE PYTHON_CVPY_PROCESS_PYTHONORG
                OUTPUT_VARIABLE CVPY_SUFFIX_PYTHONORG
                OUTPUT_STRIP_TRAILING_WHITESPACE)

set_target_properties(${the_module} PROPERTIES
                      PREFIX ""
                      OUTPUT_NAME cv2_pythonorg
                      SUFFIX ${CVPY_SUFFIX_PYTHONORG})

#set_target_properties(${the_module} PROPERTIES FOLDER "pythonorg")

if(CMAKE_COMPILER_IS_GNUCXX AND NOT ENABLE_NOISY_WARNINGS)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-unused-function")
endif()

set(PYTHON_INSTALL_CONFIGURATIONS_PYTHONORG "")

install(TARGETS ${the_module}
        ${PYTHON_INSTALL_CONFIGURATIONS_PYTHONORG}
        RUNTIME DESTINATION ${PYTHON_PACKAGES_PATH_PYTHONORG} COMPONENT main
        LIBRARY DESTINATION ${PYTHON_PACKAGES_PATH_PYTHONORG} COMPONENT main
        ARCHIVE DESTINATION ${PYTHON_PACKAGES_PATH_PYTHONORG} COMPONENT main
        )
install(FILES src2/cv.py ${PYTHON_INSTALL_CONFIGURATIONS_PYTHONORG} DESTINATION ${PYTHON_PACKAGES_PATH_PYTHONORG} COMPONENT main)
