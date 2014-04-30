program mat6_calc_method_test

use bmad
use mad_mod

implicit none

type (lat_struct), target :: lat
type (ele_struct), target, allocatable :: eles(:)
type (coord_struct) start_orb, end_orb
type (ele_struct), pointer :: ele, ele2
type (lat_param_struct) param
type (branch_struct), pointer :: branch

real(rp) err_mat(6,6)

character(40) :: lat_file  = 'mat6_calc_method_test.bmad'
character(44) :: final_str
character(*), PARAMETER  :: fmt1 = '(a,a,6es22.13)'
character(*), PARAMETER  :: fmt2 = '(a,a,es22.13)'

integer :: i, j, k, ib, nargs
logical print_extra

!

print_extra = .false.
nargs = cesr_iargc()
if (nargs == 1)then
   call cesr_getarg(1, lat_file)
   print *, 'Using ', trim(lat_file)
   print_extra = .true.
elseif (nargs > 1) then
  print *, 'Only one command line arg permitted.'
  call err_exit
endif


call bmad_parser (lat_file, lat, make_mats6 = .false.)
call lattice_bookkeeper (lat)

open (1, file = 'output.now', recl = 200)

allocate (eles(n_methods$)) 

do ib = 0, ubound(lat%branch, 1)
  branch => lat%branch(ib)
  DO i = 1, branch%n_ele_max - 1
    ele => branch%ele(i)

    do j = 1, n_methods$
      if(.not. valid_mat6_calc_method(ele, branch%param%particle, j) .or. j == static$ .or. j == custom$) cycle
      call kill_taylor(ele%taylor)
      ele%mat6_calc_method = j
      call init_coord (start_orb, lat%beam_start, ele, .false., branch%param%particle)
      call make_mat6 (ele, branch%param, start_orb, end_orb)
      call transfer_ele(ele, eles(j), .true.)
      if (print_extra .and. ele%mat6_calc_method == bmad_standard$) then
        write (1, '(a, 6es22.13)'), 'Start track:', start_orb%vec
        write (1, '(a, 6es22.13)'), 'End track:  ', end_orb%vec 
        write (1, *)
      endif
    enddo

    DO k = 1, 8
      DO j = 1, n_methods$
        if(.not. valid_mat6_calc_method(ele, branch%param%particle, j) .or. j == static$ .or. j == custom$) cycle
        ele2 => eles(j)
        if (k < 7) then
          final_str = '"' // trim(ele2%name) // ':' // trim(mat6_calc_method_name(j)) // ':MatrixRow' // trim(convert_to_string(k)) // '"' 
          write (1, fmt1) final_str, tolerance(final_str), ele2%mat6(k,:)
        else if (k == 7) then
          final_str = '"' // trim(ele2%name) // ':' // trim(mat6_calc_method_name(j)) // ':Vector"' 
          write (1, fmt1) final_str, tolerance(final_str), ele2%vec0
        else if (k == 8) then
          final_str = '"' // trim(ele2%name) // ':' // trim(mat6_calc_method_name(j)) // ':Symp_Err"' 
          write (1, fmt2) final_str, tolerance(final_str), mat_symp_error(ele2%mat6, ele2%value(p0c$)/ele2%value(p0c_start$), err_mat)
        end if
      END DO
      if (print_extra .and. k == 8) then
        err_mat = abs(eles(bmad_standard$)%mat6 - eles(tracking$)%mat6)
        write (1, '(a, 2i4, es12.2)'),   'Max diff |BS - track|:   ', maxloc(err_mat), maxval(err_mat)
      endif
      write (1,*)
    END DO
  END DO
enddo

close(1)

!----------------------------------------------------------------------
contains

character(8) function convert_to_string(a)
integer :: a
write(convert_to_string, '(I1.1)') a
end function convert_to_string

!----------------------------------------------------------------------
! contains

character(10) function tolerance(instr)
character(44) :: instr

select case (instr)

case ('"CRYSTAL1:Tracking:MatrixRow2"')            ; tolerance = 'ABS 2e-11'
case ('"CRYSTAL1:Tracking:MatrixRow4"')            ; tolerance = 'ABS 2e-12'
case ('"CRYSTAL1:Tracking:MatrixRow6"')            ; tolerance = 'ABS 2e-11'

case ('"E_GUN1:Tracking:MatrixRow1"')              ; tolerance = 'ABS 5e-10'
case ('"E_GUN1:Tracking:MatrixRow2"')              ; tolerance = 'ABS 5e-11'
case ('"E_GUN1:Tracking:MatrixRow3"')              ; tolerance = 'ABS 7e-10'
case ('"E_GUN1:Tracking:MatrixRow4"')              ; tolerance = 'ABS 1e-10'
case ('"E_GUN1:Tracking:MatrixRow5"')              ; tolerance = 'ABS 4e-07'
case ('"E_GUN1:Tracking:MatrixRow6"')              ; tolerance = 'ABS 6e-08'
case ('"E_GUN1:Tracking:Symp_Err"')                ; tolerance = 'ABS 4e-07'
case ('"E_GUN1:Tracking:Vector"')                  ; tolerance = 'ABS 6e-10'

case ('"ELSEPARATOR1:Tracking:MatrixRow5"')       ; tolerance = 'ABS 1e-10'
case ('"ELSEPARATOR2:Tracking:MatrixRow5"')       ; tolerance = 'ABS 6e-11'

case ('"PATCH1:Tracking:MatrixRow5"')              ; tolerance = 'ABS 3e-11'
case ('"PATCH1:Tracking:Symp_Err"')                ; tolerance = 'ABS 1e-11'

case ('"RFCAVITY1:Tracking:MatrixRow5"')           ; tolerance = 'ABS 2e-11'
case ('"RFCAVITY1:Tracking:MatrixRow6"')           ; tolerance = 'ABS 1e-10'
case ('"RFCAVITY1:Tracking:Symp_Err"')             ; tolerance = 'ABS 9e-11'
case ('"RFCAVITY2:Tracking:MatrixRow1"')           ; tolerance = 'ABS 1e-11'
case ('"RFCAVITY2:Tracking:MatrixRow2"')           ; tolerance = 'ABS 6e-12'
case ('"RFCAVITY2:Tracking:MatrixRow3"')           ; tolerance = 'ABS 4e-12'
case ('"RFCAVITY2:Tracking:MatrixRow4"')           ; tolerance = 'ABS 2e-12'
case ('"RFCAVITY2:Tracking:MatrixRow5"')           ; tolerance = 'ABS 2e-10'
case ('"RFCAVITY2:Tracking:MatrixRow6"')           ; tolerance = 'ABS 1e-09'
case ('"RFCAVITY2:Tracking:Symp_Err"')             ; tolerance = 'ABS 6e-11'
case ('"RFCAVITY2:Tracking:Vector"')               ; tolerance = 'ABS 4e-12'

case ('"SBEND2:Tracking:MatrixRow5"')              ; tolerance = 'ABS 2e-12'
case ('"SBEND4:Symp_Lie_PTC:MatrixRow1"')         ; tolerance = 'ABS 4e-09'
case ('"SBEND4:Taylor:MatrixRow1"')               ; tolerance = 'ABS 4e-09'
case ('"SBEND4:Symp_Lie_PTC:MatrixRow3"')         ; tolerance = 'ABS 4e-08'
case ('"SBEND4:Taylor:MatrixRow3"')               ; tolerance = 'ABS 4e-08'
case ('"SBEND4:Symp_Lie_PTC:MatrixRow5"')         ; tolerance = 'ABS 2e-07'
case ('"SBEND4:Taylor:MatrixRow5"')               ; tolerance = 'ABS 2e-07'
case ('"SBEND4:Symp_Lie_PTC:Vector"')             ; tolerance = 'ABS 4e-08'
case ('"SBEND4:Taylor:Vector"')                   ; tolerance = 'ABS 4e-08'
case ('"SBEND4:Symp_Lie_PTC:Symp_Err"')           ; tolerance = 'ABS 2e-07'
case ('"SBEND4:Taylor:Symp_Err"')                 ; tolerance = 'ABS 2e-07'
case ('"SBEND4:Bmad_Standard:MatrixRow3"')         ; tolerance = 'ABS 9e-12'
case ('"SBEND4:Bmad_Standard:MatrixRow5"')         ; tolerance = 'ABS 4e-09'
case ('"SBEND4:Bmad_Standard:Symp_Err"')           ; tolerance = 'ABS 1e-11'
case ('"SBEND4:Bmad_Standard:Vector"')             ; tolerance = 'ABS 2e-11'
case ('"SBEND4:Tracking:MatrixRow2"')              ; tolerance = 'ABS 2e-12'
case ('"SBEND5:Tracking:MatrixRow1"')              ; tolerance = 'ABS 8e-09'
case ('"SBEND5:Tracking:MatrixRow2"')              ; tolerance = 'ABS 2e-11'
case ('"SBEND5:Tracking:MatrixRow3"')              ; tolerance = 'ABS 8e-10'
case ('"SBEND5:Tracking:MatrixRow4"')              ; tolerance = 'ABS 2e-10'
case ('"SBEND5:Tracking:MatrixRow5"')              ; tolerance = 'ABS 4e-10'
case ('"SBEND5:Tracking:Symp_Err"')                ; tolerance = 'ABS 1e-09'
case ('"SBEND5:Tracking:Vector"')                  ; tolerance = 'ABS 2e-11'
case ('"SBEND6:Symp_Lie_PTC:MatrixRow1"')          ; tolerance = 'ABS 3e-09'
case ('"SBEND6:Taylor:MatrixRow1"')                ; tolerance = 'ABS 3e-09'
case ('"SBEND6:Symp_Lie_PTC:MatrixRow3"')          ; tolerance = 'ABS 3e-08'
case ('"SBEND6:Taylor:MatrixRow3"')                ; tolerance = 'ABS 3e-08'
case ('"SBEND6:Symp_Lie_PTC:MatrixRow5"')          ; tolerance = 'ABS 3e-08'
case ('"SBEND6:Taylor:MatrixRow5"')                ; tolerance = 'ABS 3e-08'
case ('"SBEND6:Symp_Lie_PTC:Vector"')              ; tolerance = 'ABS 3e-08'
case ('"SBEND6:Taylor:Vector"')                    ; tolerance = 'ABS 4e-08'
case ('"SBEND7:Tracking:MatrixRow1"')              ; tolerance = 'ABS 1e-08'
case ('"SBEND7:Tracking:MatrixRow2"')              ; tolerance = 'ABS 3e-11'
case ('"SBEND7:Tracking:MatrixRow3"')              ; tolerance = 'ABS 1e-09'
case ('"SBEND7:Tracking:MatrixRow4"')              ; tolerance = 'ABS 4e-10'
case ('"SBEND7:Tracking:MatrixRow5"')              ; tolerance = 'ABS 4e-11'
case ('"SBEND7:Tracking:Symp_Err"')                ; tolerance = 'ABS 2e-09'
case ('"SBEND7:Tracking:Vector"')                  ; tolerance = 'ABS 2e-11'

case ('"SOL_QUAD1:Tracking:Symp_Err"')             ; tolerance = 'ABS 2e-11'
case ('"SOL_QUAD2:Bmad_Standard:MatrixRow1"')      ; tolerance = 'ABS 3e-12'
case ('"SOL_QUAD2:Bmad_Standard:MatrixRow4"')      ; tolerance = 'ABS 2e-12'
case ('"SOL_QUAD2:Tracking:MatrixRow1"')           ; tolerance = 'ABS 8e-10'
case ('"SOL_QUAD2:Tracking:MatrixRow2"')           ; tolerance = 'ABS 2e-11'
case ('"SOL_QUAD2:Tracking:MatrixRow3"')           ; tolerance = 'ABS 8e-11'
case ('"SOL_QUAD2:Tracking:MatrixRow4"')           ; tolerance = 'ABS 2e-10'
case ('"SOL_QUAD2:Tracking:MatrixRow5"')           ; tolerance = 'ABS 5e-12'
case ('"SOL_QUAD2:Tracking:Symp_Err"')             ; tolerance = 'ABS 2e-10'
case ('"SOL_QUAD2:Tracking:Vector"')               ; tolerance = 'ABS 6e-12'

case ('"WIGGLER_PERIODIC1:Tracking:MatrixRow4"')   ; tolerance = 'ABS 6e-12'
case ('"WIGGLER_PERIODIC1:Tracking:Symp_Err"')     ; tolerance = 'ABS 7e-12'
case default                                       ; tolerance = 'ABS 2E-12'
end select

end function tolerance

end program
