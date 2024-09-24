# Copyright (c) 2014, Ruslan Baratov
# All rights reserved.

if(DEFINED POLLY_OS_VISIONOS_CMAKE)
  return()
else()
  set(POLLY_OS_VISIONOS_CMAKE 1)
endif()

set(CMAKE_OSX_SYSROOT "xros" CACHE STRING "System root for visionOS" FORCE)
set(CMAKE_XCODE_EFFECTIVE_PLATFORMS "-xros;-xrsimulator")

# find 'iphoneos' and 'iphonesimulator' roots and version
find_program(XCODE_SELECT_EXECUTABLE xcode-select)
if(NOT XCODE_SELECT_EXECUTABLE)
  polly_fatal_error("xcode-select not found")
endif()

if(XCODE_VERSION VERSION_LESS "5.0.0")
  polly_fatal_error("Works since Xcode 5.0.0 (current ver: ${XCODE_VERSION})")
endif()

if(CMAKE_VERSION VERSION_LESS "3.5")
  polly_fatal_error(
      "CMake minimum required version for iOS is 3.5 (current ver: ${CMAKE_VERSION})"
  )
endif()

string(COMPARE EQUAL "$ENV{DEVELOPER_DIR}" "" _is_empty)
if(NOT _is_empty)
  polly_status_debug("Developer root (env): $ENV{DEVELOPER_DIR}")
endif()

execute_process(
    COMMAND
    ${XCODE_SELECT_EXECUTABLE}
    "-print-path"
    OUTPUT_VARIABLE
    XCODE_DEVELOPER_ROOT # /.../Xcode.app/Contents/Developer
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

polly_status_debug("Developer root: ${XCODE_DEVELOPER_ROOT}")

find_program(XCODEBUILD_EXECUTABLE xcodebuild)
if(NOT XCODEBUILD_EXECUTABLE)
  polly_fatal_error("xcodebuild not found")
endif()

# Check version exists
execute_process(
    COMMAND
    "${XCODEBUILD_EXECUTABLE}"
    -showsdks
    -sdk
    "xros${VISIONOS_SDK_VERSION}"
    RESULT_VARIABLE
    VISIONOS_SDK_VERSION_RESULT
    OUTPUT_QUIET
    ERROR_QUIET
)
if(NOT "${VISIONOS_SDK_VERSION_RESULT}" EQUAL 0)
  polly_fatal_error("visionOS version `${VISIONOS_SDK_VERSION}` not found (${VISIONOS_SDK_VERSION_RESULT})")
endif()

# visionOS simulator root
set(
    VISIONOSSIMULATOR_ROOT
    "${XCODE_DEVELOPER_ROOT}/Platforms/XRSimulator.platform/Developer"
)
if(NOT EXISTS "${VISIONOSSIMULATOR_ROOT}")
  polly_fatal_error(
      "VISIONOSSIMULATOR_ROOT not found (${VISIONOSSIMULATOR_ROOT})\n"
      "XCODE_DEVELOPER_ROOT: ${XCODE_DEVELOPER_ROOT}\n"
  )
endif()

# visionOS simulator SDK root
set(
    VISIONOSSIMULATOR_SDK_ROOT
    "${VISIONOSSIMULATOR_ROOT}/SDKs/XRSimulator${VISIONOS_SDK_VERSION}.sdk"
)

if(NOT EXISTS ${VISIONOSSIMULATOR_SDK_ROOT})
  polly_fatal_error(
      "VISIONOSSIMULATOR_SDK_ROOT not found (${VISIONOSSIMULATOR_SDK_ROOT})\n"
      "VISIONOSSIMULATOR_ROOT: ${VISIONOSSIMULATOR_ROOT}\n"
      "VISIONOS_SDK_VERSION: ${VISIONOS_SDK_VERSION}\n"
  )
endif()

# iPhone root
set(
    VISIONOS_ROOT
    "${XCODE_DEVELOPER_ROOT}/Platforms/XROS.platform/Developer"
)
if(NOT EXISTS "${VISIONOS_ROOT}")
  polly_fatal_error(
      "VISIONOS_ROOT not found (${VISIONOS_ROOT})\n"
      "XCODE_DEVELOPER_ROOT: ${XCODE_DEVELOPER_ROOT}\n"
  )
endif()

# iPhone SDK root
set(VISIONOS_SDK_ROOT "${VISIONOS_ROOT}/SDKs/XROS${VISIONOS_SDK_VERSION}.sdk")

if(NOT EXISTS ${VISIONOS_SDK_ROOT})
  hunter_fatal_error(
      "VISIONOS_SDK_ROOT not found (${VISIONOS_SDK_ROOT})\n"
      "VISIONOS_ROOT: ${VISIONOS_ROOT}\n"
      "VISIONOS_SDK_VERSION: ${VISIONOS_SDK_VERSION}\n"
  )
endif()

string(COMPARE EQUAL "${VISIONOS_DEPLOYMENT_SDK_VERSION}" "" _is_empty)
if(_is_empty)
  set(
      CMAKE_OSX_DEPLOYMENT_TARGET
      #CMAKE_XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET
      "${VISIONOS_SDK_ROOT}"
  )
else()
  set(
      CMAKE_OSX_DEPLOYMENT_TARGET
      #CMAKE_XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET
      "${VISIONOS_DEPLOYMENT_SDK_VERSION}"
  )
endif()

# Emulate OpenCV toolchain --
set(IOS NO)
set(VISIONOS YES)
# -- end

# Set iPhoneOS architectures
set(archs "")
foreach(arch ${VISIONOS_ARCHS})
  set(archs "${archs} ${arch}")
endforeach()
set(CMAKE_XCODE_ATTRIBUTE_ARCHS[sdk=xros*] "${archs}")
set(CMAKE_XCODE_ATTRIBUTE_VALID_ARCHS[sdk=xros*] "${archs}")

# Set iPhoneSimulator architectures
set(archs "")
foreach(arch ${VISIONOSSIMULATOR_ARCHS})
  set(archs "${archs} ${arch}")
endforeach()
set(CMAKE_XCODE_ATTRIBUTE_ARCHS[sdk=xrsimulator*] "${archs}")
set(CMAKE_XCODE_ATTRIBUTE_VALID_ARCHS[sdk=xrsimulator*] "${archs}")

# Introduced in iOS 9.0
set(CMAKE_XCODE_ATTRIBUTE_ENABLE_BITCODE NO)

# This will set CMAKE_CROSSCOMPILING to TRUE.
# CMAKE_CROSSCOMPILING needed for try_run:
# * https://cmake.org/cmake/help/latest/command/try_run.html#behavior-when-cross-compiling
# (used in CURL)
set(CMAKE_SYSTEM_NAME "Darwin")

# Set CMAKE_SYSTEM_PROCESSOR for one-arch toolchain
# (needed for OpenCV 3.3)
set(_all_archs ${VISIONOSSIMULATOR_ARCHS} ${VISIONOS_ARCHS})
list(LENGTH _all_archs _all_archs_len)
if(_all_archs_len EQUAL 1)
  set(CMAKE_SYSTEM_PROCESSOR ${_all_archs})
else()
  set(CMAKE_SYSTEM_PROCESSOR "")
endif()
