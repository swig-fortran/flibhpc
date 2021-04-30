!-----------------------------------------------------------------------------!
! \file   test/test_flhpc.F90
!
! Copyright (c) 2021 Oak Ridge National Laboratory, UT-Battelle, LLC.
! Distributed under an MIT open source license: see LICENSE for details.
!-----------------------------------------------------------------------------!

#include "fassert.h"

program test_flhpc
  implicit none
  call test_sort()
contains

!-----------------------------------------------------------------------------!
subroutine test_sort()
  use, intrinsic :: ISO_C_BINDING
  use flhpc
  implicit none

end subroutine

!-----------------------------------------------------------------------------!

end program

