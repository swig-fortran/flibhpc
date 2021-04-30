/*!
 * \file flhpc.i
 *
 * Copyright (c) 2021 Oak Ridge National Laboratory, UT-Battelle, LLC.
 * Distributed under an MIT open source license: see LICENSE for details.
 */

%module "flhpc"

#if defined(SWIGIMPORTED) && !defined(FLHPC_SWIGIMPORTED)
#error "To import the FLHPC module correctly, use ``%include \"import_flhpc.i\"``"
#endif

/* -------------------------------------------------------------------------
 * Header definition macros
 * ------------------------------------------------------------------------- */

%define %flhpc_add_header
%insert("fbegin") %{
! Flibhpc project, https://github.com/swig-fortran/flibhpc
! Copyright (c) 2021 Oak Ridge National Laboratory, UT-Battelle, LLC.
! Distributed under an MIT open source license: see LICENSE for details.
%}
%insert("begin") %{
/*
 * Flibhpc project, https://github.com/swig-fortran/flibhpc
 * Copyright (c) 2021 Oak Ridge National Laboratory, UT-Battelle, LLC.
 * Distributed under an MIT open source license: see LICENSE for details.
 */
%}
%enddef

%flhpc_add_header

/* -------------------------------------------------------------------------
 * Exception handling
 * ------------------------------------------------------------------------- */

// Rename the error variables' internal C symbols
#define SWIG_FORTRAN_ERROR_INT flhpc_ierr
#define SWIG_FORTRAN_ERROR_STR flhpc_get_serr

// Restore names in the wrapper code
%rename(ierr) flhpc_ierr;
%rename(get_serr) flhpc_get_serr;

// Unless we're directly building this module, delay exception handling
#ifndef SWIGIMPORTED
%include <exception.i>
#endif

/* -------------------------------------------------------------------------
 * Data types and instantiation
 * ------------------------------------------------------------------------- */

// Note: stdint.i inserts #include <stdint.h>
%include <stdint.i>

%define %flhpc_template_numeric(SRC, DST)
%template(DST) SRC<int32_t>;
%template(DST) SRC<int64_t>;
%template(DST) SRC<double>;
%enddef

/* -------------------------------------------------------------------------
 * Array view translation
 * ------------------------------------------------------------------------- */

%include <typemaps.i>
%apply (SWIGTYPE *DATA, size_t SIZE) {
       (int16_t  *DATA, size_t DATASIZE),
       (int32_t  *DATA, size_t DATASIZE),
       (int64_t  *DATA, size_t DATASIZE),
       (float    *DATA, size_t DATASIZE),
       (double   *DATA, size_t DATASIZE),
       (void    **DATA, size_t DATASIZE)};

%apply (SWIGTYPE const *DATA, size_t SIZE) {
       (int16_t  const *DATA, size_t DATASIZE),
       (int32_t  const *DATA, size_t DATASIZE),
       (int64_t  const *DATA, size_t DATASIZE),
       (float    const *DATA, size_t DATASIZE),
       (double   const *DATA, size_t DATASIZE),
       (void*    const *DATA, size_t DATASIZE)};

/* -------------------------------------------------------------------------
 * Version information
 * ------------------------------------------------------------------------- */

%apply char* { const char flibhpc_version[] };
%fortranbindc flibhpc_version_major;
%fortranbindc flibhpc_version_minor;
%fortranbindc flibhpc_version_patch;

// These symbols are defined in the CMake-generated `flibhpc_version.cpp`
%inline %{
extern "C" {
extern const char flibhpc_version[];
extern const int flibhpc_version_major;
extern const int flibhpc_version_minor;
extern const int flibhpc_version_patch;
}
%}
