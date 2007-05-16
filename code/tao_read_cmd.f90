!+
! Subroutine tao_read_cmd (who, file_name)
!
! Routine to read in stuff.
!
! Input:
!   who       -- Character(*): Must be 'lattice'.
!   file_name -- Character(*): Input file name.
!-

subroutine tao_read_cmd (who, file_name)

use tao_mod

implicit none

character(*) who, file_name

character(20) action
character(20) :: names(1) = (/ 'lattice' /)

character(20) :: r_name = 'tao_read_cmd'

integer i, j, ix, iu, nd, ii
logical err

!

call string_trim (who, action, ix)
call match_word (action, names, ix)
if (ix == 0) then
  call out_io (s_error$, r_name, 'UNRECOGNIZED "WHAT": ' // action)
  return
elseif (ix < 0) then
  call out_io (s_error$, r_name, 'AMBIGUOUS "WHAT": ' // action)
  return
endif
action = names(ix)

select case (action)

!-------------------------
! lattice

case ('lattice')

  iu = s%global%u_view
  call bmad_parser2 (file_name, s%u(iu)%model%lat)
  s%global%lattice_recalc = .true.
  

end select

end subroutine
