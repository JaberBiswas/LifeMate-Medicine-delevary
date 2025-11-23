# Project-level configuration.
cmake_minimum_required(VERSION 3.14)
project(lifemate LANGUAGES CXX)

# The name of the executable created for the application. Change this to change
# the on-disk name of your application.
set(BINARY_NAME "lifemate")

# Explicitly opt in to modern CMake behaviors to avoid warnings with recent
# versions of CMake.
cmake_policy(VERSION 3.14...3.25)

# Define build configuration option.
get_property(IS_MULTICONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(IS_MULTICONFIG)
  set(CMAKE_CONFIGURATION_TYPES "Debug;Profile;Release"
    CACHE STRING "" FORCE)
else()
  if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE "Debug" CACHE
      STRING "Flutter build mode" FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
      "Debug" "Profile" "Release")
  endif()
endif()
# Define settings for the Profile build mode.
set(CMAKE_EXE_LINKER_FLAGS_PROFILE "${CMAKE_EXE_LINKER_FLAGS_RELEASE}")
set(CMAKE_SHARED_LINKER_FLAGS_PROFILE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE}")
set(CMAKE_C_FLAGS_PROFILE "${CMAKE_C_FLAGS_RELEASE}")
set(CMAKE_CXX_FLAGS_PROFILE "${CMAKE_CXX_FLAGS_RELEASE}")

# Use Unicode for all projects.
add_definitions(-DUNICODE -D_UNICODE)

# Compilation settings that should be applied to most targets.
#
# Be cautious about adding new options here, as plugins use this function by
# default. In most cases, you should add new options to specific targets instead
# of modifying this function.
function(APPLY_STANDARD_SETTINGS TARGET)
  target_compile_features(${TARGET} PUBLIC cxx_std_17)
  target_compile_options(${TARGET} PRIVATE /W4 /WX /wd"4100")
  target_compile_options(${TARGET} PRIVATE /EHsc)
  target_compile_definitions(${TARGET} PRIVATE "_HAS_EXCEPTIONS=0")
  target_compile_definitions(${TARGET} PRIVATE "$<$<CONFIG:Debug>:_DEBUG>")
endfunction()

# Flutter library and tool build rules.
set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
add_subdirectory(${FLUTTER_MANAGED_DIR})

# Application build; see runner/CMakeLists.txt.
add_subdirectory("runner")

# Generated plugin build rules, which manage building the plugins and adding
# them to the application.
# Note: Firebase SDK CMakeLists.txt needs to be patched before plugins are included.
# The SDK is extracted during flutter_assemble, so we patch it if it exists during configuration.
# We also add a custom command to patch it after extraction during build.
set(FIREBASE_SDK_CMAKE "${CMAKE_BINARY_DIR}/x64/extracted/firebase_cpp_sdk_windows/CMakeLists.txt")

# Patch SDK if it exists during configuration (for subsequent builds)
if(EXISTS "${FIREBASE_SDK_CMAKE}")
  file(READ "${FIREBASE_SDK_CMAKE}" FIREBASE_CMAKE_CONTENT)
  # Check if it needs patching (has old version < 3.10)
  if(FIREBASE_CMAKE_CONTENT MATCHES "cmake_minimum_required\\(VERSION 3\\.[0-5]\\)")
    # Update cmake_minimum_required to 3.10 to avoid deprecation warnings
    string(REGEX REPLACE "cmake_minimum_required\\(VERSION 3\\.[0-9]+\\)" 
      "cmake_minimum_required(VERSION 3.10)" 
      FIREBASE_CMAKE_CONTENT "${FIREBASE_CMAKE_CONTENT}")
    file(WRITE "${FIREBASE_SDK_CMAKE}" "${FIREBASE_CMAKE_CONTENT}")
    message(STATUS "Patched Firebase SDK CMakeLists.txt to use CMake 3.10")
  endif()
endif()

# Add a custom command to patch SDK after flutter_assemble (for first builds)
# This runs during build phase after SDK is extracted
add_custom_command(
  OUTPUT "${CMAKE_BINARY_DIR}/_firebase_patched"
  COMMAND ${CMAKE_COMMAND} -E echo "Patching Firebase SDK..."
  COMMAND powershell -NoProfile -Command "if (Test-Path '${FIREBASE_SDK_CMAKE}') { $$content = Get-Content '${FIREBASE_SDK_CMAKE}' -Raw; if ($$content -match 'cmake_minimum_required\\(VERSION 3\\.[0-5]\\)') { $$content = $$content -replace 'cmake_minimum_required\\(VERSION 3\\.[0-9]+\\)', 'cmake_minimum_required(VERSION 3.10)'; Set-Content '${FIREBASE_SDK_CMAKE}' -Value $$content -NoNewline } }"
  COMMAND ${CMAKE_COMMAND} -E touch "${CMAKE_BINARY_DIR}/_firebase_patched"
  DEPENDS flutter_assemble
  COMMENT "Patching Firebase SDK CMakeLists.txt"
  VERBATIM
)

add_custom_target(patch_firebase_sdk AFTER flutter_assemble
  DEPENDS "${CMAKE_BINARY_DIR}/_firebase_patched"
)

include(flutter/generated_plugins.cmake)


# === Installation ===
# Support files are copied into place next to the executable, so that it can
# run in place. This is done instead of making a separate bundle (as on Linux)
# so that building and running from within Visual Studio will work.
set(BUILD_BUNDLE_DIR "$<TARGET_FILE_DIR:${BINARY_NAME}>")
# Make the "install" step default, as it's required to run.
set(CMAKE_VS_INCLUDE_INSTALL_TO_DEFAULT_BUILD 1)
# Set install prefix to the build output directory
# For multi-config generators (Visual Studio), install to the config-specific directory
# The install script will handle the config name at install time
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  # Set to a placeholder that will be resolved at install time
  # For Visual Studio multi-config, this will be resolved to the actual config directory
  set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/runner" CACHE PATH "..." FORCE)
endif()

# Use generator expressions directly in install commands for multi-config support
# BUILD_BUNDLE_DIR already uses generator expression, so use that for install destinations
set(INSTALL_BUNDLE_DATA_DIR "$<TARGET_FILE_DIR:${BINARY_NAME}>/data")
set(INSTALL_BUNDLE_LIB_DIR "$<TARGET_FILE_DIR:${BINARY_NAME}>")

install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
  COMPONENT Runtime)

install(FILES "${FLUTTER_ICU_DATA_FILE}" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}"
  COMPONENT Runtime)

install(FILES "${FLUTTER_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
  COMPONENT Runtime)

if(PLUGIN_BUNDLED_LIBRARIES)
  install(FILES "${PLUGIN_BUNDLED_LIBRARIES}"
    DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
    COMPONENT Runtime)
endif()

# Copy the native assets provided by the build.dart from all packages.
set(NATIVE_ASSETS_DIR "${PROJECT_BUILD_DIR}native_assets/windows/")
install(DIRECTORY "${NATIVE_ASSETS_DIR}"
   DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
   COMPONENT Runtime)

# Fully re-copy the assets directory on each build to avoid having stale files
# from a previous install.
set(FLUTTER_ASSET_DIR_NAME "flutter_assets")
install(CODE "
  file(REMOVE_RECURSE \"$<TARGET_FILE_DIR:${BINARY_NAME}>/data/${FLUTTER_ASSET_DIR_NAME}\")
  " COMPONENT Runtime)
install(DIRECTORY "${PROJECT_BUILD_DIR}/${FLUTTER_ASSET_DIR_NAME}"
  DESTINATION "${INSTALL_BUNDLE_DATA_DIR}" COMPONENT Runtime)

# Install the AOT library on non-Debug builds only.
install(FILES "${AOT_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}"
  CONFIGURATIONS Profile;Release
  COMPONENT Runtime)
