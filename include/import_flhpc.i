/*!
 * \file import_flhpc.i
 *
 * Copyright (c) 2021 Oak Ridge National Laboratory, UT-Battelle, LLC.
 * Distributed under an MIT open source license: see LICENSE for details.
 */

// Make sure that the downstream module isn't doing ``%import "import_flhpc.i"``
// or ``%import "flhpc.i"``: only ``%include "import_flhpc.i"``
#ifndef SWIGIMPORTED
#define FLHPC_SWIGIMPORTED
#endif

// Set up macros, etc.
%import "flhpc.i"

// Support external exceptions
%include <extern_exception.i>
