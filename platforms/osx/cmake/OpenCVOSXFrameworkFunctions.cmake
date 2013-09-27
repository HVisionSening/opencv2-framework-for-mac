function (add_framework_bundle_directory TARGET NAME)
  get_target_property (HAS_DIR ${TARGET} HAS_${NAME}_DIRECTORY)
  if (NOT HAS_DIR)
    # Get full path to bundle directory
    set_target_properties (${TARGET} PROPERTIES HAS_${NAME}_DIRECTORY TRUE)
    get_target_property (FRAMEWORK_LOCATION ${TARGET} LOCATION)
    get_filename_component (FRAMEWORK_DIR "${FRAMEWORK_LOCATION}" PATH)
    set (TARGET_DIR "${FRAMEWORK_DIR}/${NAME}")
    get_filename_component (LINK_TARGET_PARENT_DIR "${FRAMEWORK_DIR}/../../" ABSOLUTE)
    set_target_properties ( ${TARGET} PROPERTIES ${NAME}_DIRECTORY "${TARGET_DIR}" )
    # Create Directory in Version/**/
    add_custom_command (TARGET ${TARGET}
      POST_BUILD
      COMMAND ${CMAKE_COMMAND}
      ARGS -E make_directory ${TARGET_DIR} )
    # Create symlink in outer directory to it
    add_custom_command (TARGET ${TARGET}
      POST_BUILD
      WORKING_DIRECTORY "${LINK_TARGET_PARENT_DIR}"
      COMMAND ${CMAKE_COMMAND}
      ARGS -E create_symlink "Versions/Current/${NAME}" "${NAME}" )
  endif (NOT HAS_DIR)
endfunction (add_framework_bundle_directory)

function (add_framework_bundle_directory_without_symlink TARGET NAME)
  get_target_property (HAS_DIR ${TARGET} HAS_${NAME}_DIRECTORY)
  if (NOT HAS_DIR)
    # Get full path to bundle directory
    set_target_properties (${TARGET} PROPERTIES HAS_${NAME}_DIRECTORY TRUE)
    get_target_property (FRAMEWORK_LOCATION ${TARGET} LOCATION)
    get_filename_component (FRAMEWORK_DIR "${FRAMEWORK_LOCATION}" PATH)
    set (TARGET_DIR "${FRAMEWORK_DIR}/${NAME}")
    get_filename_component (LINK_TARGET_PARENT_DIR "${FRAMEWORK_DIR}/../../" ABSOLUTE)
    set_target_properties ( ${TARGET} PROPERTIES ${NAME}_DIRECTORY "${TARGET_DIR}" )
    # Create Directory in Version/**/
    add_custom_command (TARGET ${TARGET}
      POST_BUILD
      COMMAND ${CMAKE_COMMAND}
      ARGS -E make_directory ${TARGET_DIR} )
  endif (NOT HAS_DIR)
endfunction (add_framework_bundle_directory_without_symlink)

function (add_file_to_framework_subdir TARGET DIR FILE_PATH)
  # Create DIR directory if not created yet
  add_framework_bundle_directory (${TARGET} "${DIR}")

  # get location of the new location for the copied file in the headers directory
  get_target_property (FRAMEWORK_LOCATION ${TARGET} LOCATION)
  get_filename_component (FRAMEWORK_DIR "${FRAMEWORK_LOCATION}" PATH)
  get_filename_component (FILE_NAME ${FILE_PATH} NAME)
  get_filename_component (COPY_FILE_PATH "${FRAMEWORK_DIR}/${DIR}/${FILE_NAME}" ABSOLUTE)

  get_target_property (HAS_FILE_IN_DIR ${TARGET} HAS_${FILE_NAME}_IN_${DIR}_DIRECTORY)

  if (NOT HAS_FILE_IN_DIR)
    set_target_properties (${TARGET} PROPERTIES HAS_${FILE_NAME}_IN_${DIR}_DIRECTORY TRUE)
    set (FILES_TO_ADD "${COPY_FILE_PATH}")

    # setup file copy
    add_custom_command (TARGET ${TARGET}
      POST_BUILD
      COMMAND cp
      ARGS -R ${FILE_PATH} ${COPY_FILE_PATH} )

    get_target_property (CONTENTS_OF_DIR ${TARGET} CONTENTS_OF_${DIR}_DIRECTORY)
    if (CONTENTS_OF_DIR)
      set_target_properties (${TARGET} PROPERTIES CONTENTS_OF_${DIR}_DIRECTORY "${CONTENTS_OF_DIR};${FILES_TO_ADD}")
    else (CONTENTS_OF_DIR)
      set_target_properties (${TARGET} PROPERTIES CONTENTS_OF_${DIR}_DIRECTORY "${FILES_TO_ADD}")
    endif (CONTENTS_OF_DIR)
  endif (NOT HAS_FILE_IN_DIR)
endfunction (add_file_to_framework_subdir)

function (add_file_to_framework_subdir_without_symlink TARGET DIR FILE_PATH)
  # Create DIR directory if not created yet
  add_framework_bundle_directory_without_symlink (${TARGET} "${DIR}")

  # get location of the new location for the copied file in the headers directory
  get_target_property (FRAMEWORK_LOCATION ${TARGET} LOCATION)
  get_filename_component (FRAMEWORK_DIR "${FRAMEWORK_LOCATION}" PATH)
  get_filename_component (FILE_NAME ${FILE_PATH} NAME)
  get_filename_component (COPY_FILE_PATH "${FRAMEWORK_DIR}/${DIR}/${FILE_NAME}" ABSOLUTE)

  get_target_property (HAS_FILE_IN_DIR ${TARGET} HAS_${FILE_NAME}_IN_${DIR}_DIRECTORY)

  if (NOT HAS_FILE_IN_DIR)
    set_target_properties (${TARGET} PROPERTIES HAS_${FILE_NAME}_IN_${DIR}_DIRECTORY TRUE)
    set (FILES_TO_ADD "${COPY_FILE_PATH}")

    # setup file copy
    add_custom_command (TARGET ${TARGET}
      POST_BUILD
      COMMAND cp
      ARGS -R ${FILE_PATH} ${COPY_FILE_PATH} )

    get_target_property (CONTENTS_OF_DIR ${TARGET} CONTENTS_OF_${DIR}_DIRECTORY)
    if (CONTENTS_OF_DIR)
      set_target_properties (${TARGET} PROPERTIES CONTENTS_OF_${DIR}_DIRECTORY "${CONTENTS_OF_DIR};${FILES_TO_ADD}")
    else (CONTENTS_OF_DIR)
      set_target_properties (${TARGET} PROPERTIES CONTENTS_OF_${DIR}_DIRECTORY "${FILES_TO_ADD}")
    endif (CONTENTS_OF_DIR)
  endif (NOT HAS_FILE_IN_DIR)
endfunction (add_file_to_framework_subdir_without_symlink)

function (add_symlink_directing_to_framework_subdir TARGET LIBRARY_TARGET_FILE)
  get_target_property (FRAMEWORK_LOCATION ${TARGET} LOCATION)
  get_filename_component (FRAMEWORK_DIR "${FRAMEWORK_LOCATION}" PATH)
  add_custom_command (TARGET ${TARGET}
    POST_BUILD
    WORKING_DIRECTORY "${FRAMEWORK_DIR}/../.."
    COMMAND ${CMAKE_COMMAND}
    ARGS -E create_symlink "Versions/Current/${LIBRARY_TARGET_FILE}" "${LIBRARY_TARGET_FILE}" )
endfunction (add_symlink_directing_to_framework_subdir)

function (add_framework_header TARGET HEADER)
  add_file_to_framework_subdir(${TARGET} "Headers" ${HEADER})
endfunction (add_framework_header)

function (add_framework_privateheader TARGET HEADER)
  add_file_to_framework_subdir(${TARGET} "PrivateHeaders" ${HEADER})
endfunction (add_framework_privateheader)

function (add_framework_resource TARGET FILE_PATH)
  add_file_to_framework_subdir(${TARGET} "Resources" ${FILE_PATH})
endfunction (add_framework_resource)

function (add_framework_sublibrary TARGET LIB DEPENDENCIES)
  # Check if we are also building $LIB. Otherwise if it isnt a
  # system library (i.e. not in /usr/lib) copy it and all
  # dependencies 
  if (TARGET ${LIB})
    # Create the framework Bundles directory if it has not been created yet
    add_framework_bundle_directory(${TARGET} "Libraries")
    
    # Add As Dependency
    add_dependencies(${TARGET} ${LIB})

    # Get location of library after it is built
    get_target_property (LIBRARY_LOCATION ${LIB} LOCATION)
    get_filename_component (LIBRARY_LOCATION_DIR "${LIBRARY_LOCATION}" PATH)

    # Get location of the framework's bundle directory ``Libraries''
    # and append the name of the library to said path in order to
    # get the full copy path for the library
    get_target_property (FRAMEWORK ${TARGET} LOCATION)
    get_filename_component (FRAMEWORK_DIR "${FRAMEWORK}" PATH)
    get_filename_component (LIBRARY_COPY_PATH "${FRAMEWORK_DIR}/Libraries/lib${LIB}.dylib" ABSOLUTE)

    # We want all the symbols in the library to be reexported since we are using
    # a sublibrary
    target_link_libraries (${TARGET} "-Wl,-reexport_library ${LIBRARY_LOCATION}")

    # Add copy command for library during post processing
    add_custom_command(TARGET ${TARGET}
      POST_BUILD
      COMMAND ${CMAKE_COMMAND}
      ARGS -E copy ${LIBRARY_LOCATION} ${LIBRARY_COPY_PATH})

    # Setup correct id of copied library
    add_custom_command(TARGET ${TARGET}
      POST_BUILD
      COMMAND install_name_tool
      ARGS -id "@loader_path/Libraries/lib${LIB}.dylib" "${LIBRARY_COPY_PATH}")

    # Add install name tool command to update the framework's path to library during post processing
    ## Different build tools will link the framework with one of the following paths:
    ## lib${LIB}.dylib
    ## lib${LIB}.${LIBRARY_SO_VERSION}.dylib
    ## lib${LIB}.${LIBRARY_VERSION}.dylib
    ## So we install name tool for all of them. If one of them was not linked, it will just be ignored
    get_filename_component (LIBRARY_LINK_PATH_VANILLA "${LIBRARY_LOCATION_DIR}/lib${LIB}.dylib" ABSOLUTE)
    add_custom_command(TARGET ${TARGET}
      POST_BUILD
      COMMAND install_name_tool
      ARGS -change ${LIBRARY_LINK_PATH_VANILLA} "@loader_path/Libraries/lib${LIB}.dylib" ${FRAMEWORK})

    get_target_property (LIBRARY_SO_VERSION ${LIB} SOVERSION)
    if (LIBRARY_SO_VERSION)
      get_filename_component (LIBRARY_LINK_PATH_SO_VERSION "${LIBRARY_LOCATION_DIR}/lib${LIB}.${LIBRARY_SO_VERSION}.dylib" ABSOLUTE)
      add_custom_command(TARGET ${TARGET}
        POST_BUILD
        COMMAND install_name_tool
        ARGS -change ${LIBRARY_LINK_PATH_SO_VERSION} "@loader_path/Libraries/lib${LIB}.dylib" ${FRAMEWORK})
    endif (LIBRARY_SO_VERSION)

    get_target_property (LIBRARY_VERSION ${LIB} VERSION)
    if (LIBRARY_VERSION)
      get_filename_component (LIBRARY_LINK_PATH_VERSION "${LIBRARY_LOCATION_DIR}/lib${LIB}.${LIBRARY_VERSION}.dylib" ABSOLUTE)
      add_custom_command(TARGET ${TARGET}
        POST_BUILD
        COMMAND install_name_tool
        ARGS -change ${LIBRARY_LINK_PATH_VERSION} "@loader_path/Libraries/lib${LIB}.dylib" ${FRAMEWORK})
    endif (LIBRARY_VERSION)

    # Setup install name tool command to update loader path for all dependent libraries
    foreach (DEP ${DEPENDENCIES})
      add_custom_command(TARGET ${TARGET}
        POST_BUILD
        COMMAND install_name_tool
        ARGS -change "${LIBRARY_LOCATION_DIR}/lib${DEP}.dylib"  "@loader_path/lib${DEP}.dylib" ${LIBRARY_COPY_PATH})
      get_target_property (DEP_SO_VERSION ${DEP} SOVERSION)
      if (DEP_SO_VERSION)
        add_custom_command(TARGET ${TARGET}
          POST_BUILD
          COMMAND install_name_tool
          ARGS -change "${LIBRARY_LOCATION_DIR}/lib${DEP}.${DEP_SO_VERSION}.dylib"  "@loader_path/lib${DEP}.dylib" ${LIBRARY_COPY_PATH})
      endif (DEP_SO_VERSION)
      get_target_property (DEP_VERSION ${DEP} VERSION)
      if (DEP_VERSION)
        add_custom_command(TARGET ${TARGET}
          POST_BUILD
          COMMAND install_name_tool
          ARGS -change "${LIBRARY_LOCATION_DIR}/lib${DEP}.${DEP_VERSION}.dylib"  "@loader_path/lib${DEP}.dylib" ${LIBRARY_COPY_PATH})
      endif (DEP_VERSION)
    endforeach (DEP ${DEPENDENCIES})

    # copy library dSYMs into framework dSYM if they exist
    if (OSX_FRAMEWORK_CREATE_DSYM)
      get_filename_component (FRAMEWORK_NAME "${FRAMEWORK}" NAME)
      add_custom_command (TARGET ${TARGET}
        POST_BUILD
        COMMAND if [ -a "${LIBRARY_LOCATION}.dSYM" ] \; then cp "${LIBRARY_LOCATION}.dSYM/Contents/Resources/DWARF/*" "${LIBRARY_LOCATION_DIR}/${FRAMEWORK_NAME}.framework.dSYM/Contents/Resources/DWARF" \; fi )
    endif (OSX_FRAMEWORK_CREATE_DSYM)

    # strip dylib if we are in Release mode
    add_custom_command (TARGET ${TARGET}
      POST_BUILD
      COMMAND if [ $<CONFIGURATION> == Release ] \; then strip -u ${LIBRARY_COPY_PATH} \; fi )

  endif (TARGET ${LIB})
endfunction (add_framework_sublibrary)

function (add_framework_independent_library TARGET LIB DEPENDENCIES INSTALL_NAME_TOOL_DIR)
  # Check if we are also building $LIB.
  if (TARGET ${LIB})
    # Create the framework Bundles directory if it has not been created yet
    add_framework_bundle_directory(${TARGET} "Libraries")

    # Add As Dependency
    add_dependencies(${TARGET} ${LIB})

    # Get location of library after it is built
    get_target_property (LIBRARY_LOCATION ${LIB} LOCATION)
    get_filename_component (LIBRARY_LOCATION_DIR "${LIBRARY_LOCATION}" PATH)

    # Get location of the framework's directory
    # to get the full copy path for the library
    get_target_property (FRAMEWORK ${TARGET} LOCATION)
    get_filename_component (FRAMEWORK_DIR "${FRAMEWORK}" PATH)
    get_target_property (LIBRARY_LOCATION ${LIB} LOCATION)
    get_filename_component (LIBRARY_TARGET_FILE ${LIBRARY_LOCATION} NAME)
    get_filename_component (LIBRARY_COPY_PATH "${FRAMEWORK_DIR}/${LIBRARY_TARGET_FILE}" ABSOLUTE)

    # Add copy command for library during post processing
    add_custom_command(TARGET ${TARGET}
      POST_BUILD
      COMMAND ${CMAKE_COMMAND}
      ARGS -E copy ${LIBRARY_LOCATION} ${LIBRARY_COPY_PATH})
    # setup install name tool command after post processing
    add_custom_command (TARGET ${TARGET}
      POST_BUILD
      COMMAND install_name_tool
      ARGS -id "${INSTALL_NAME_TOOL_DIR}/${FRAMEWORK_NAME}.framework/Versions/${VERSION}/${LIBRARY_TARGET_FILE}" "${LIBRARY_COPY_PATH}" )

    # Setup install name tool command to update loader path for all dependent libraries
    foreach (DEP ${DEPENDENCIES})
      set (DEP_NEW_LINK_PATH "@loader_path/Libraries/lib${DEP}.dylib")
      add_custom_command(TARGET ${TARGET}
        POST_BUILD
        COMMAND install_name_tool
        ARGS -change "${LIBRARY_LOCATION_DIR}/lib${DEP}.dylib"  "${DEP_NEW_LINK_PATH}" ${LIBRARY_COPY_PATH})
      get_target_property (DEP_SO_VERSION ${DEP} SOVERSION)
      if (DEP_SO_VERSION)
        add_custom_command(TARGET ${TARGET}
          POST_BUILD
          COMMAND install_name_tool
          ARGS -change "${LIBRARY_LOCATION_DIR}/lib${DEP}.${DEP_SO_VERSION}.dylib"  "${DEP_NEW_LINK_PATH}" ${LIBRARY_COPY_PATH})
      endif (DEP_SO_VERSION)
      get_target_property (DEP_VERSION ${DEP} VERSION)
      if (DEP_VERSION)
        add_custom_command(TARGET ${TARGET}
          POST_BUILD
          COMMAND install_name_tool
          ARGS -change "${LIBRARY_LOCATION_DIR}/lib${DEP}.${DEP_VERSION}.dylib"  "${DEP_NEW_LINK_PATH}" ${LIBRARY_COPY_PATH})
      endif (DEP_VERSION)
    endforeach (DEP ${DEPENDENCIES})    
    # Create symlink in outer directory to it
    add_custom_command (TARGET ${TARGET}
      POST_BUILD
      WORKING_DIRECTORY "${FRAMEWORK_DIR}/../.."
      COMMAND ${CMAKE_COMMAND}
      ARGS -E create_symlink "Versions/Current/${LIBRARY_TARGET_FILE}" "${LIBRARY_TARGET_FILE}" )
    # strip dylib if we are in Release mode
    add_custom_command (TARGET ${TARGET}
      POST_BUILD
      COMMAND if [ $<CONFIGURATION> == Release ] \; then strip -u ${LIBRARY_COPY_PATH} \; fi )
  endif (TARGET ${LIB})
  
  # copy library dSYMs into framework dSYM if they exist
  if (OSX_FRAMEWORK_CREATE_DSYM)
    get_filename_component (FRAMEWORK_NAME "${FRAMEWORK}" NAME)
    add_custom_command (TARGET ${TARGET}
      POST_BUILD
      COMMAND if [ -a "${LIBRARY_LOCATION}.dSYM" ] \; then cp "${LIBRARY_LOCATION}.dSYM/Contents/Resources/DWARF/*" "${LIBRARY_LOCATION_DIR}/${FRAMEWORK_NAME}.framework.dSYM/Contents/Resources/DWARF" \; fi )
  endif (OSX_FRAMEWORK_CREATE_DSYM)
endfunction (add_framework_independent_library)

function (add_framework TARGET FRAMEWORK_NAME FILES VERSION INSTALL_NAME_TOOL_DIR)
   # Create Actual Framework library and add files to it
  add_library(${TARGET} SHARED ${FILES})

  # Set Settings so it is a framework
  set_target_properties(${TARGET}
    PROPERTIES
    FRAMEWORK TRUE
    FRAMEWORK_VERSION ${VERSION}
    OUTPUT_NAME ${FRAMEWORK_NAME} )
  # get location of framework so we can install_name_tool it correctly
  get_target_property (FRAMEWORK_LOCATION ${TARGET} LOCATION)
  get_filename_component (FRAMEWORK_DIR "${FRAMEWORK_LOCATION}" PATH)   
  set_target_properties (${TARGET} PROPERTIES BUNDLE_DIRECTORY "${FRAMEWORK_DIR}/../.." )

  # setup install name tool command after post processing
  add_custom_command (TARGET ${TARGET}
    POST_BUILD
    COMMAND install_name_tool
    ARGS -id "${INSTALL_NAME_TOOL_DIR}/${FRAMEWORK_NAME}.framework/Versions/${VERSION}/${FRAMEWORK_NAME}" "${FRAMEWORK_LOCATION}" )
  # strip framework if we are in Release mode
  add_custom_command (TARGET ${TARGET}
    POST_BUILD
    COMMAND if [ $<CONFIGURATION> == Release ] \; then strip -u ${FRAMEWORK_LOCATION} \; fi )
endfunction (add_framework)

function (set_xcode_debug_info TARGET)
  if (OSX_FRAMEWORK_CREATE_DSYM)
    # CMake 2.8.8 and previous versions have a major bug regarding configuration-dependent Xcode attributes
    ## See CMake Bugtracker: http://public.kitware.com/Bug/view.php?id=12532
    ## All this can be cleaned once CMAKE_XCODE_ATTRIB_CONFIG is lower than the minimum required for Xcode 4.3
    ## CMAKE_XCODE_ATTRIB_CONFIG should be set to the first CMake version that supports configuration-dependent Xcode attributes
    set (CMAKE_XCODE_ATTRIB_CONFIG 9.9.9)
    if (${CMAKE_VERSION} VERSION_GREATER ${CMAKE_XCODE_ATTRIB_CONFIG})
      set_target_properties (${TARGET} PROPERTIES XCODE_ATTRIBUTE_DEBUG_INFORMATION_FORMAT[variant=Release] "dwarf-with-dsym")
    else (${CMAKE_VERSION} VERSION_GREATER ${CMAKE_XCODE_ATTRIB_CONFIG})
      set_target_properties (${TARGET} PROPERTIES XCODE_ATTRIBUTE_DEBUG_INFORMATION_FORMAT "dwarf-with-dsym")
    endif (${CMAKE_VERSION} VERSION_GREATER ${CMAKE_XCODE_ATTRIB_CONFIG})
    set_target_properties (${TARGET} PROPERTIES XCODE_ATTRIBUTE_GCC_GENERATE_DEBUGGING_SYMBOLS "YES")
  endif (OSX_FRAMEWORK_CREATE_DSYM)
endfunction (set_xcode_debug_info)
