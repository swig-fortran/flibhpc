#---------------------------------------------------------------------------#
# \file CMakeLists.txt
#
# Copyright (c) 2021 Oak Ridge National Laboratory, UT-Battelle, LLC.
# Distributed under an MIT open source license: see LICENSE for details.
#---------------------------------------------------------------------------#

cmake_minimum_required(VERSION 3.8)

# Determine version number from git metadata
include("${CMAKE_CURRENT_LIST_DIR}/cmake/CgvFindVersion.cmake")
cgv_find_version(Flibhpc)

project(Flibhpc VERSION "${Flibhpc_VERSION}" LANGUAGES CXX Fortran)
cmake_policy(VERSION 3.8...3.19)

#---------------------------------------------------------------------------#
# OPTIONS
#---------------------------------------------------------------------------#
option(BUILD_SHARED_LIBS "Build shared libraries" ON)
option(FLIBHPC_DEV "Default to using development-centered options" OFF)
option(FLIBHPC_BUILD_DOCS "Build documentation with Sphinx" ${FLIBHPC_DEV})
option(FLIBHPC_USE_SWIG "Regenerate source files using SWIG" ${FLIBHPC_DEV})

if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
  set(_DEFAULT_BUILD_EXAMPLES ON)
endif()
option(FLIBHPC_BUILD_EXAMPLES "Build examples" ${_DEFAULT_BUILD_EXAMPLES})

if(FLIBHPC_DEV)
  set(_DEFAULT_BUILD_TESTS ON)
endif()
option(FLIBHPC_BUILD_TESTS "Build Flibhpc tests" ${_DEFAULT_BUILD_TESTS})

if(FLIBHPC_BUILD_TESTS OR FLIBHPC_BUILD_EXAMPLES)
  set(_DEFAULT_BUILD_TESTING ON)
endif()

#---------------------------------------------------------------------------#
# FLAGS
#---------------------------------------------------------------------------#

# Fortran standard
set(FLIBHPC_FORTRAN_STD "03" CACHE STRING
   "Fortran standard for compiling generated code (options: 03/08/15/18/none)")
if(FLIBHPC_FORTRAN_STD AND NOT FLIBHPC_FORTRAN_STD STREQUAL "none")
  if(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
    set(_FLIBHPC_STD_FLAGS "-std=f20${FLIBHPC_FORTRAN_STD}")
  elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "Intel")
    set(_FLIBHPC_STD_FLAGS "-std${FLIBHPC_FORTRAN_STD}")
  else()
    message(WARNING "Fortran standard flags are not known for "
      "compilier '${CMAKE_Fortran_COMPILER_ID}': ignoring"
      "FLIBHPC_FORTRAN_STD=${FLIBHPC_FORTRAN_STD}. Configure with "
      "the FFLAGS environment variable or explicitly specify "
      "CMAKE_Fortran_FLAGS")
    set(FLIBHPC_FORTRAN_STD "none" CACHE FORCE STRING "")
  endif()
endif()

# Build type
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  if(FLIBHPC_DEV)
    set(_CMAKE_BUILD_TYPE "Debug")
  else ()
    set(_CMAKE_BUILD_TYPE "RelWithDebInfo")
  endif()
  message(STATUS "No build type selected, default to ${_CMAKE_BUILD_TYPE}")
  set(CMAKE_BUILD_TYPE "${_CMAKE_BUILD_TYPE}" CACHE STRING "Build type" FORCE)
endif()

#---------------------------------------------------------------------------#
# MODULES TO LOAD
#---------------------------------------------------------------------------#

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")
if(CMAKE_VERSION VERSION_LESS 3.18)
  list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/backport-cmake-318")
endif()

if(FLIBHPC_USE_SWIG)
  if(NOT SWIG_fortran_FOUND)
    find_package(SWIG COMPONENTS fortran REQUIRED)
  endif()

  if(CMAKE_VERSION VERSION_LESS 3.12)
    message(FATAL_ERROR "CMake 3.12 or higher is required to regenerate the "
      "Fortran bindings using SWIG. Set FLIBHPC_USE_SWIG to OFF "
      "and reconfigure.")
  endif()

  if(CMAKE_VERSION GREATER_EQUAL 3.13)
    cmake_policy(SET CMP0078 "NEW")
  else()
    set(FLIBHPC_CMP0078 "NEW")
  endif()
  if(CMAKE_VERSION GREATER_EQUAL 3.14)
    cmake_policy(SET CMP0086 "NEW")
  else()
    set(FLIBHPC_CMP0086 "NEW")
  endif()
  include(UseSWIG)
endif()

# Load CTest if applicable
if(FLIBHPC_BUILD_TESTS OR FLIBHPC_BUILD_EXAMPLES)
  include(CTest)
endif()

#---------------------------------------------------------------------------#
# LIBRARY
#---------------------------------------------------------------------------#

include(GNUInstallDirs)

set(CMAKE_Fortran_MODULE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/module")
set(FLIBHPC_INTERFACE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/include")
set(FLIBHPC_GENERATE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src")
set(FLIBHPC_INSTALL_CONFIGDIR "${CMAKE_INSTALL_LIBDIR}/cmake/Flibhpc")
set(FLIBHPC_INSTALL_MODULEDIR "${CMAKE_INSTALL_INCLUDEDIR}")
set(FLIBHPC_NAMESPACE "Flibhpc::")

# List of libraries exported by cmake/FlibhpcConfig.cmake.in
set(FLIBHPC_LIBRARIES)

function(flibhpc_add_module name)
  if(FLIBHPC_USE_SWIG)
    # SWIG is available; actually generate the library dynamically.

    set(src_file "${FLIBHPC_INTERFACE_DIR}/${name}.i")
    # We're using C++
    set_property(SOURCE "${src_file}" PROPERTY CPLUSPLUS ON)
    # We need to include the source directory
    set_property(SOURCE "${src_file}" PROPERTY USE_TARGET_INCLUDE_DIRECTORIES ON)

    # Create the library
    swig_add_library(${name}
      LANGUAGE Fortran
      TYPE USE_BUILD_SHARED_LIBS
      OUTPUT_DIR "${FLIBHPC_GENERATE_DIR}"
      SOURCES "${src_file}" ${ARGN}
    )

    # Add SWIG headers
    target_include_directories(${name}
      PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
    )

    # Install the interface file for downstream libraries to use
    install(FILES
      "${src_file}"
      DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
    )

  else()
    # SWIG is *not* being used: compile the code committed in the repository,
    # generated by the developer with SWIG.
    add_library(${name}
      "${FLIBHPC_GENERATE_DIR}/${name}.f90"
      "${FLIBHPC_GENERATE_DIR}/${name}FORTRAN_wrap.cxx"
      ${ARGN}
    )
  endif()

  # Allow the library to be referred to by its namespaced version, for use by
  # downstream projects that *directly* compile flibhpc
  add_library(${FLIBHPC_NAMESPACE}${name} ALIAS ${name})

  # Compile C++ code with C++11
  target_compile_features(${name}
    PRIVATE
      cxx_std_11
  )
  # Compile with e.g. std=c++11 instead of =gnu++11
  set_property(TARGET ${name} PROPERTY CXX_EXTENSIONS OFF)

  if(_FLIBHPC_STD_FLAGS)
    # Compile Fortran code with a particular standard
    target_compile_options(${name}
      PUBLIC $<$<COMPILE_LANGUAGE:Fortran>:${_FLIBHPC_STD_FLAGS}>
    )
  endif()

  target_include_directories(${name}
    PUBLIC
      # Fortran modules
      $<BUILD_INTERFACE:${CMAKE_Fortran_MODULE_DIRECTORY}>
      $<INSTALL_INTERFACE:${FLIBHPC_INSTALL_MODULEDIR}>
  )

  # Set up installation
  install(TARGETS
    ${name}
    EXPORT Flibhpc-targets
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  )
  # Add to list of targets to export
  set(FLIBHPC_LIBRARIES ${FLIBHPC_LIBRARIES} ${FLIBHPC_NAMESPACE}${name}
    PARENT_SCOPE
  )
endfunction()

# Configure version information and generate primary flibhpc module
set(FLIBHPC_VERSION_CPP "${CMAKE_CURRENT_BINARY_DIR}/flibhpc_version.cpp")
configure_file("${CMAKE_CURRENT_LIST_DIR}/cmake/flibhpc_version.cpp.in"
  "${FLIBHPC_VERSION_CPP}" @ONLY)
flibhpc_add_module(flhpc "${FLIBHPC_VERSION_CPP}")

# Also install 'import_flhpc' if using SWIG
if(FLIBHPC_USE_SWIG)
  install(FILES
    "${CMAKE_CURRENT_SOURCE_DIR}/include/import_flhpc.i"
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
  )
endif()

flibhpc_add_module(flhpc_algorithm)
target_link_libraries(flhpc_algorithm flhpc_random flhpc)

#---------------------------------------------------------------------------#
# INSTALLATION
#---------------------------------------------------------------------------#

# Install module files
install(DIRECTORY
  "${CMAKE_Fortran_MODULE_DIRECTORY}/"
  DESTINATION "${FLIBHPC_INSTALL_MODULEDIR}"
)

install(EXPORT Flibhpc-targets
  FILE FlibhpcTargets.cmake
  NAMESPACE ${FLIBHPC_NAMESPACE}
  DESTINATION ${FLIBHPC_INSTALL_CONFIGDIR}
)

# Create a ConfigVersion.cmake file
include(CMakePackageConfigHelpers)

configure_package_config_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/FlibhpcConfig.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/FlibhpcConfig.cmake"
  INSTALL_DESTINATION ${FLIBHPC_INSTALL_CONFIGDIR}
)

write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/FlibhpcConfigVersion.cmake"
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMajorVersion
)

install(FILES
  "${CMAKE_CURRENT_BINARY_DIR}/FlibhpcConfig.cmake"
  "${CMAKE_CURRENT_BINARY_DIR}/FlibhpcConfigVersion.cmake"
  DESTINATION ${FLIBHPC_INSTALL_CONFIGDIR}
)

#---------------------------------------------------------------------------#
# TESTING AND DOCS
#---------------------------------------------------------------------------#

if(FLIBHPC_BUILD_TESTS)
  add_subdirectory(test)
endif()

if(FLIBHPC_BUILD_EXAMPLES)
  add_subdirectory(example)
endif()

if(FLIBHPC_BUILD_DOCS)
  add_subdirectory(doc)
endif()

