/*!
 * \file mpi.i
 *
 * MPI support for Fortran/C interoperability. Assumes a macro "HAVE_MPI" is
 * defined in the target code if and only if MPI is enabled. Add

     %insert("runtime") %{
     #include "myconfig.h"
     %}

 * in your code *before* including this file to guarantee that HAVE_MPI is set
 * correctly.
 * ------------------------------------------------------------------------- */
%{
#if FLIBHPC_USE_MPI
#include <mpi.h>
#endif
%}

/* -------------------------------------------------------------------------
 * MPI Fortran compatibility datatypes
 *
 * Use MPI/Fortran compatibility code to wrap C MPI types, but use ISO-C
 * compatibility layer to pass the Fortran integers (and convert back to native
 * MPI type in the wrapper result code).
 * ------------------------------------------------------------------------- */
%apply int { MPI_Comm };

%typemap(ftype) MPI_Comm
  "integer"
%typemap(fin) MPI_Comm
  "$1 = int($input, C_INT)"
%typemap(fout) MPI_Comm
  "$result = int($1)"

%typemap(in, noblock=1) MPI_Comm {
%#if FLIBHPC_USE_MPI
  $1 = MPI_Comm_f2c((MPI_Fint)*$input);
%#else
  $1 = *$input;
%#endif
}
%typemap(out, noblock=1) MPI_Comm {
%#if FLIBHPC_USE_MPI
  $result = (int)MPI_Comm_c2f($1);
%#else
  $result = $1;
%#endif
}
