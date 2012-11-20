!........................................................................
!+
! Subroutine : q_tune (ring, Q_x, Q_y, ok)
!
! Description:
!
! Arguments  :
!
! Mod/Commons:
!
! Calls      :
!
! Author     :
!
! Modified   :
!-
!........................................................................
!
!
! $Log$
! Revision 1.3  2007/01/30 16:14:31  dcs
! merged with branch_bmad_1.
!
!
!
!........................................................................
!
  subroutine q_tune (ring, Q_x, Q_y, ok)

!  set fractional tunes to Q_x, Q_y

  use bmad
  use bmadz_interface
  use bsim_interface

  implicit none

  type (lat_struct) ring
  type (coord_struct), allocatable :: orb(:)

  real(rp) Q_x, Q_y
  real(rp), allocatable :: dk1(:) 
  real(rp) int_Q_x, int_Q_y, phi_x, phi_y

  logical ok

       call reallocate_coord(orb, ring%n_ele_max)       
       allocate(dk1(ring%n_ele_max))
       call closed_orbit_calc(ring, orb, 4)

       call choose_quads(ring, dk1)
       int_Q_x = int(ring%ele(ring%n_ele_track)%a%phi / twopi)
       int_Q_y = int(ring%ele(ring%n_ele_track)%b%phi / twopi)
       phi_x = (int_Q_x + Q_x) * twopi
       phi_y = (int_Q_y + Q_y) * twopi
       call custom_set_tune (phi_x, phi_y, dk1, ring, orb, ok)

       deallocate(dk1)
       deallocate(orb)


     return
     end






