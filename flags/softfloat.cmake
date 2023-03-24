# Copyright (c) 2017, NeroBurner
# All rights reserved.

if(DEFINED POLLY_FLAGS_SOFTFLOAT_CMAKE_)
  return()
else()
  set(POLLY_FLAGS_SOFTFLOAT_CMAKE_ 1)
endif()

include(polly_add_cache_flag)

polly_add_cache_flag(CMAKE_CXX_FLAGS "-mfloat-abi=soft")
polly_add_cache_flag(CMAKE_C_FLAGS "-mfloat-abi=soft")
