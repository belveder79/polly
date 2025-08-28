# Copyright (c) 2017-2019, Ruslan Baratov
# Copyright (c) 2023, Clemens Arth
# All rights reserved.

if(DEFINED POLLY_VISIONOS_2_5_ARM64_CMAKE_)
  return()
else()
  set(POLLY_VISIONOS_2_5_ARM64_CMAKE_ 1)
endif()

include("${CMAKE_CURRENT_LIST_DIR}/utilities/polly_clear_environment_variables.cmake")

include("${CMAKE_CURRENT_LIST_DIR}/utilities/polly_init.cmake")

set(VISIONOS_SDK_VERSION 2.5)
set(VISIONOS_DEPLOYMENT_SDK_VERSION 2.5)

set(POLLY_XCODE_COMPILER "clang")
polly_init(
    "visionOS ${VISIONOS_SDK_VERSION} / Deployment ${VISIONOS_DEPLOYMENT_SDK_VERSION} / Universal (arm64) / \
${POLLY_XCODE_COMPILER} / \
c++14 support"
    "Xcode"
)

include("${CMAKE_CURRENT_LIST_DIR}/utilities/polly_common.cmake")

include(polly_fatal_error)

# Fix try_compile
include(polly_visionos_bundle_identifier)

set(CMAKE_MACOSX_BUNDLE YES)
set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "Apple Development")

set(VISIONOS_ARCHS arm64)
set(VISIONOSSIMULATOR_ARCHS arm64)

include("${CMAKE_CURRENT_LIST_DIR}/compiler/xcode.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/os/visionos.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/flags/cxx14.cmake")

include("${CMAKE_CURRENT_LIST_DIR}/utilities/polly_visionos_development_team.cmake")
