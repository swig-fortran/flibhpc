# FlibHPC

This project uses SWIG-Fortran to generate Fortran-2003 wrappers to Thrust and
supports inter-language cooperation with MPI and OpenACC.
It can be used as a support library for
other libraries that want to generate MPI-friendly Fortran wrappers to their
code, or used by application developers who want to adapt Fortran CUDA/OpenACC
code to their C++ kernels.
