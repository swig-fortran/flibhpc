.. ############################################################################
.. File  : doc/introduction.rst
.. ############################################################################

************
Introduction
************

The Fortran programming language includes many mathematical functions but few
of the generic, high-performance software algorithms and data containers needed
by essentially all modern scientific software. Most Fortran software contains
hand-written code for such algorithms that may be burdensome to maintain and
inflexible, as well as unperformant and erroneous under certain conditions.

Flibhpc is a library for use by application developers that provides native
Fortran interfaces to existing high-quality algorithms and containers
implemented in C++ and available on all modern computer systems.

Flibhpc defines a carefully crafted set of interface files written for the
SWIG-Fortran code generator. These Fortran interfaces generate native Fortran
proxy code that comprises a set of thin wrappers to selected functionality in
the C++ standard library. The resulting code is a set of Fortran modules and
C++ wrappers that expose a concise and well-defined interface that may be built
into and distributed with the application.

The generated modules include functionality for efficient generic sorting and
searching, set operations, random number generation, value mapping, string
manipulation, and dynamically resizing vectors.

Installation
============

Flibhpc is built using modern CMake_, and it has no external dependencies. This
makes installation quite simple as long as you have a relatively recent
software stack with a Fortran and compatible C++ compiler.

1. Download and install CMake if it's not already on your system. It is highly
   recommended to use a package manager such as Homebrew_ for Mac or YUM_ for
   Red Hat Linux.
2. Download the `Flibhpc source code`_ from GitHub if you haven't already.
3. Create a new build directory (for example purposes, create a subdirectory
   named ``build`` inside your downloaded source directory) and ``cd`` to it.
4. Run CMake: ``cmake ..``
5. Make and install (by default it will install to ``/usr/local``):
   ``make install``.

By default, Flibhpc builds shared libraries. Add the CMake argument
``-DBUILD_SHARED_LIBS:BOOL=OFF`` to build static libraries.

.. _CMake: https://cmake.org
.. _Homebrew: https://brew.sh
.. _YUM: https://access.redhat.com/solutions/9934
.. _Flibhpc source code: https://github.com/swig-fortran/flibhpc/releases

Downstream usage as a library
=============================

The Flibhpc library is most easily used when your downstream app is built with
CMake. It should require a single line to initialize::

   find_package(Flibhpc REQUIRED CONFIG)

and a single line to link against your app or library::

   target_link_libraries(example_backend Flibhpc::flhpc_random Flibhpc::flhpc_algorithm)

If your installation prefix for Flibhpc is a system default path (such as
``/usr/local``) or in your ``$CMAKE_PREFIX_PATH`` environment variable, it
should automatically find the necessary CMake configure file.

An `example Fortran application`_ that depends only on Flibhpc is
available on Github.

.. _example Fortran application: https://github.com/swig-fortran/flibhpc-example-app

----

If you're using a simple standalone Makefile to build your Fortran code, you
will have to inform the compiler of the proper include path, library path, and
library names. Depending on your system configuration, you might have to
also explicitly link your app against the compiler's C++ standard libraries
using ``-lstdc++``.

Downstream usage as a component
===============================

Flibhpc's SWIG interface files can be used with your Fortran-accessible
C++ project to seamlessly integrate the Flibhpc Fortran wrapper code with
yours. To start, you must have the latest version of the `SWIG+Fortran`_ tool
installed on your machine: the version of SWIG used by your installation of
Flibhpc *must* match the version used by your downstream library/app. When you
build Flibhpc for downstream SWIG usage, you must configure using ``cmake
-DFLIBHPC_USE_SWIG=ON ..``. This will cause the SWIG interface files to be
installed to ``${CMAKE_PREFIX_PATH}/include`` to make them available
downstream. Finally, in your downstream SWIG interface code, instead of calling
``%import <flhpc.i>`` you must use ``%include <import_flhpc.i>``. This is necessary
to inject function declarations and other internal macros into your wrapper
code.

At that point, all you have to do is (for example) ``%import <flhpc_vector>`` to
allow ``std::vector<double>`` in your library headers to be wrapped by
Flibhpc's ``VectorReal8`` Fortran proxy derived type.

An `example C++/Fortran library`_ that integrates with Flibhpc will be made
available on Github.

.. _SWIG+Fortran: https://github.com/swig-fortran
.. _example C++/Fortran library: https://github.com/swig-fortran/flibhpc-example-lib).

Developing
==========

If you are interested in extending the capabilities of Flibhpc, you will need
the latest version of the `SWIG+Fortran`_ tool installed on your machine. When
configuring CMake, you will want to configure using
``cmake -DFLIBHPC_DEV=ON ..`` to enable tests and documentation. Tests,
examples, and documentation can be independently enabled using the
``FLIBHPC_BUILD_TESTS``, ``FLIBHPC_BUILD_EXAMPLES``, and ``FLIBHPC_BUILD_DOCS``
options.

.. ############################################################################
.. end of doc/introduction.rst
.. ############################################################################
