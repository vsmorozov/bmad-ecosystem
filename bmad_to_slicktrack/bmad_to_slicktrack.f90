!+
! Program to convert a Bmad lattice file to a SLICKTRACK file.
!
! Usage:
!   bmad_to_slicktrack <bmad_file_name> {-no_split}
!
! The output file name will be the bmad_file_name with the '.bmad' suffix
! (or whatever suffix is there) replaced by '.slick'.
!
! The -no_split argument is optional. if the -no_split argument is present:
! Bends and quadrupoles will be split into two pieces in the slicktrack file and the
! resulting elements with have an ending "H" suffix applied.
! Exception: If two bends or two quadrupoles have the same name and are next to each other 
! then they will will be considered to be split elements and will not be further split
! and will have have their names mangled.
!-

program bmad_to_slicktrack

use bmad
use indexx_mod

implicit none

type (lat_struct), target :: lat
type (coord_struct), allocatable :: orbit(:)
type (ele_struct), pointer :: ele
type (nametable_struct) nametab

real(rp) slick_params(3), s_start, length, scale
integer i, j, ix, n_arg, slick_class, nb, nq, ne, n_count, n_edge

logical end_here, added, split_eles

character(200) slick_name, bmad_name
character(100) line
character(40) arg, name
character(*), parameter :: r_name = 'bmad_to_slicktrack'

!

n_arg = cesr_iargc()
bmad_name = ''
split_eles = .true.

do i = 1, n_arg
  call cesr_getarg (i, arg)
  if (index('-no_split', trim(arg)) == 1) then
    split_eles = .false.
  elseif (arg(1:1) == '-') then
    print *, 'Bad switch: ', trim(arg)
    bmad_name = ''
    exit
  else
    bmad_name = arg
  endif
enddo

if (bmad_name == '') then
  print '(a)', 'Usage: bmad_to_slicktrack <bmad_bmad_name> {-no_split}'
  stop
endif

call file_suffixer (bmad_name, slick_name, '.slick', .true.)
open (1, file = slick_name)
print *, 'Creating slicktrack file: ' // trim(slick_name)

! Get the lattice

call bmad_parser (bmad_name, lat)

!-------------------------------------------------------
! Write element defs

write (1, '(a)') '    1 IP        0.00000000  0.00000000  0.00000000    1   0.000000    0'


call nametable_init(nametab)

do i = 1, lat%n_ele_track
  ele => lat%ele(i)

  name = trim(ele%name)
  scale = 1.0_rp

  if (split_eles) then
    select case (ele%key)
    case (sbend$, quadrupole$)
      if (i == lat%n_ele_track) then
        if (lat%ele(i-1)%name /= ele%name) then
          name = trim(ele%name) // 'H'
          scale = 0.5_rp
        endif
      elseif (lat%ele(i+1)%name /= ele%name .and. lat%ele(i-1)%name /= ele%name) then
        name = trim(ele%name) // 'H'
        scale = 0.5_rp
      endif
    end select
  endif

  call find_indexx(name, nametab, ix, add_to_list = .true., has_been_added = added)
  if (.not. added) cycle   ! To avoid duplicates.

  call ele_to_slick_params(ele, slick_class, slick_params, scale)

  if (slick_class == -1) cycle
  write (1, '(i5, 1x, a8, 3f12.8, a)') slick_class, name, slick_params, '    1   0.000000    0'
enddo

!-----------------------------------------------------
! Write inserted element defs

write (1, *)
write (1, '(a)') '----------------------------------------------------------------------------'
write (1, *)

nb = 0
nq = 0
n_edge = 0

do i = 1, lat%n_ele_track
  ele => lat%ele(i)
  if (i == lat%n_ele_track .and. ele%name == 'END') cycle   ! will be handled after do loop

  if (lat%ele(i-1)%name == ele%name) then
    n_count = n_count + 1
  else
    n_count = 1
  endif

  select case (ele%key)
  case (sbend$)
    if (mod(n_count, 2) == 0) cycle
    if (ele%select) then  ! If k1 /= 0
      if (2*i < lat%n_ele_track) then  ! Write  HC, ..., CQ elements in reverse for the 2nd half of the lattice.
        call write_insert_ele_def (nq, ['HC', 'VC', 'HQ', 'VQ', 'RQ', 'CQ'])    
      else
        call write_insert_ele_def (nq, ['CQ', 'RQ', 'VQ', 'HQ', 'VC', 'HC'])    
      endif
    else
      call write_insert_ele_def (nb, ['VD'])
    endif

    if (ele%value(e1$) /= 0) call write_insert_ele_def (n_edge, ['EE'], tan(ele%value(e1$)) * ele%value(g$))
    if (ele%value(e2$) /= 0) call write_insert_ele_def (n_edge, ['EE'], tan(ele%value(e2$)) * ele%value(g$))

  case (quadrupole$)
    if (mod(n_count, 2) == 0) cycle    ! Skip second element in pair
    if (2*i < lat%n_ele_track) then
      call write_insert_ele_def (nq, ['HC', 'VC', 'HQ', 'VQ', 'RQ', 'CQ'])    
    else
      call write_insert_ele_def (nq, ['CQ', 'RQ', 'VQ', 'HQ', 'VC', 'HC'])    
    endif
  end select
enddo

write (1, '(a)') '    1 END'

!-----------------------------------------------------
! Write lattice element positions

write (1, *)
write (1, '(a)') '----------------------------------------------------------------------------'
write (1, *)

nb = 0
nq = 0
ne = 0
n_edge = 0

write (1, '(a)') 'IP              0'

do i = 1, lat%n_ele_track
  ele => lat%ele(i)
  if (i == lat%n_ele_track .and. ele%name == 'END') cycle   ! will be handled after do loop

  if (.not. split_eles) then
    select case (ele%key)
    case (sbend$)
      if (ele%value(e1$) /= 0) call write_insert_ele_position (line, ne, n_edge, ['EE'], ele%s, .true.)
      call write_ele_position (line, ne, ele%name, s_start + 0.5_rp * length)
      if (ele%value(e2$) /= 0) call write_insert_ele_position (line, ne, n_edge, ['EE'], ele%s, .true.)

    case (solenoid$)
      call write_ele_position (line, ne, ele%name, ele%s_start)

    case (sextupole$, rfcavity$, beambeam$, hkicker$, vkicker$, kicker$, quadrupole$, marker$)
      call write_ele_position (line, ne, ele%name, ele%s_start + 0.5_rp * ele%value(l$))
    end select

    cycle
  endif

  if (lat%ele(i-1)%name == ele%name) then
    n_count = n_count + 1
  else
    n_count = 1
  endif

  select case (ele%key)
  case (sbend$)
    if (lat%ele(i+1)%name == ele%name .and. mod(n_count, 2) == 1) cycle  ! Skip first element in pair

    if (mod(n_count, 2) == 0) then   ! If second element in pair
      s_start = lat%ele(i-1)%s_start
      length = 2 * ele%value(l$)
      name = trim(ele%name)
    else
      s_start = ele%s_start
      length = ele%value(l$)
      name = trim(ele%name) // 'H'
    endif

    if (ele%select) then  ! If k1 /= 0
      if (2*i < lat%n_ele_track) then
        call write_insert_ele_position (line, ne, nq, ['HC', 'VC'], s_start, .true.)
        if (ele%value(e1$) /= 0) call write_insert_ele_position (line, ne, n_edge, ['EE'], s_start, .true.)
        call write_ele_position (line, ne, name, s_start + 0.25_rp * length)
        call write_insert_ele_position (line, ne, nq, ['HQ', 'VQ', 'RQ', 'CQ'], s_start + 0.5_rp * length)
        call write_ele_position (line, ne, name, s_start + 0.75_rp * length)
        if (ele%value(e2$) /= 0) call write_insert_ele_position (line, ne, n_edge, ['EE'], ele%s, .true.)
      else
        if (ele%value(e1$) /= 0) call write_insert_ele_position (line, ne, n_edge, ['EE'], s_start, .true.)
        call write_ele_position (line, ne, name, s_start + 0.25_rp * length)
        call write_insert_ele_position (line, ne, nq, ['CQ', 'RQ', 'VQ', 'HQ'], s_start + 0.5_rp * length, .true.)
        call write_ele_position (line, ne, name, s_start + 0.75_rp * length)
        if (ele%value(e2$) /= 0) call write_insert_ele_position (line, ne, n_edge, ['EE'], ele%s, .true.)
        call write_insert_ele_position (line, ne, nq, ['VC', 'HC'], ele%s)
      endif
    else
      if (ele%value(e1$) /= 0) call write_insert_ele_position (line, ne, n_edge, ['EE'], s_start, .true.)
      call write_ele_position (line, ne, name, s_start + 0.25_rp * length)
      call write_insert_ele_position (line, ne, nb, ['VD'], s_start + 0.5_rp * length, .true.)
      call write_ele_position (line, ne, name, s_start + 0.75_rp * length)
      if (ele%value(e2$) /= 0) call write_insert_ele_position (line, ne, n_edge, ['EE'], ele%s, .true.)
    endif

  case (quadrupole$)
    if (lat%ele(i+1)%name == ele%name .and. mod(n_count, 2) == 1) cycle  ! Skip first element in pair

    if (mod(n_count, 2) == 0) then   ! If second element in pair
      s_start = lat%ele(i-1)%s_start
      length = 2 * ele%value(l$)
      name = trim(ele%name)
    else
      s_start = ele%s_start
      length = ele%value(l$)
      name = trim(ele%name) // 'H'
    endif

    if (2*i < lat%n_ele_track) then
      call write_insert_ele_position (line, ne, nq, ['HC', 'VC'], s_start, .true.)
      call write_ele_position (line, ne, name, s_start + 0.25_rp * length)
      call write_insert_ele_position (line, ne, nq, ['HQ', 'VQ', 'RQ', 'CQ'], s_start + 0.5_rp * length)
      call write_ele_position (line, ne, name, s_start + 0.75_rp * length)
    else
      call write_ele_position (line, ne, name, s_start + 0.25_rp * length)
      call write_insert_ele_position (line, ne, nq, ['CQ', 'RQ', 'VQ', 'HQ'], s_start + 0.5_rp * length, .true.)
      call write_ele_position (line, ne, name, s_start + 0.75_rp * length)
      call write_insert_ele_position (line, ne, nq, ['VC', 'HC'], ele%s)
    endif

  case (solenoid$)
    call write_ele_position (line, ne, ele%name, ele%s_start)

  case (sextupole$, rfcavity$, beambeam$, hkicker$, vkicker$, kicker$, marker$)
    call write_ele_position (line, ne, ele%name, ele%s_start + 0.5_rp * ele%value(l$))
  end select
enddo

call write_ele_position (line, ne, 'IP', lat%ele(lat%n_ele_track)%s)
call write_ele_position (line, ne, 'END', lat%ele(lat%n_ele_track)%s)

write (1, '(a)') line

!---------------------------------------------------------------------------
!---------------------------------------------------------------------------
contains

! Extract the element parameter valuse to be written to the slicktrack input file

subroutine ele_to_slick_params(ele, slick_class, slick_params, len_scale)

type (ele_struct) ele
real(rp) slick_params(3), len_scale, strength_scale
real(rp) knl(0:n_pole_maxx), tilt(0:n_pole_maxx)
integer slick_class, ix_pole_max

!

strength_scale = len_scale
if (.not. ele%is_on) strength_scale = 0

slick_params = 0
slick_class = -1
call multipole_ele_to_kt (ele, .true., ix_pole_max, knl, tilt, magnetic$, include_kicks$)

select case (ele%key)

case (sbend$)
  if (ele%value(ref_tilt$) == 0) then
    if (knl(1) == 0) then
      slick_class = 2
      ele%select = .false.  ! Mark k1 = 0
    else
      slick_class = 15
      ele%select = .true.   ! Mark k1 /= 0
    endif
    slick_params = [len_scale*ele%value(angle$), strength_scale*knl(1), len_scale*ele%value(l$)]

  else
    if (abs(abs(ele%value(ref_tilt$)) - pi/2) > 1d-6) then
      print *, 'Bend element has ref_tilt that is not +/- pi/2! ' // trim(ele%name)
    endif

    if (knl(1) == 0) then
      slick_class = 9
    else
      slick_class = 16
    endif
    slick_params = [-len_scale*ele%value(angle$)*sign_of(ele%value(ref_tilt$)), strength_scale*knl(1), len_scale*ele%value(l$)]
  endif

case (quadrupole$)
  if (ele%value(tilt$) == 0) then
    slick_class = 3
    slick_params = [strength_scale*knl(1), 0.0_rp, len_scale*ele%value(l$)]

  else
    if (abs(abs(tilt(1)) - pi/4) > 1d-6) then
      print *, 'Bend element has tilt that is not +/- pi/4! ' // trim(ele%name)
    endif
    slick_class = 4
    slick_params = [strength_scale*knl(1)*sign_of(tilt(1)), 0.0_rp, len_scale*ele%value(l$)]
  endif

case (rfcavity$)
  slick_class = 5
  slick_params = [strength_scale*1d-6*ele%value(voltage$), 0.0_rp, 0.0_rp]

case (sextupole$)
  if (ele%value(tilt$) /= 0) then
    print *, 'Cannot translate skew sextupole: ' // trim(ele%name)
    if (ele%value(l$) == 0) return
    print *, '   Will replace with a drift'
    slick_class = 1
    slick_params = [strength_scale*ele%value(l$), 0.0_rp, 0.0_rp]
  endif

  slick_class = 8
  slick_params = [strength_scale*knl(2), 0.0_rp, len_scale*ele%value(l$)]

case (solenoid$)
  slick_class = 10
  slick_params = [strength_scale*ele%value(ks$)*ele%value(l$), 0.0_rp, len_scale*ele%value(l$)]

case (beambeam$)
  slick_class = 17
  slick_params = [0.0_rp, 0.0_rp, 0.0_rp]

case (hkicker$, vkicker$, kicker$)
  if (tilt(0) == 0) then
    slick_class = 6
    slick_params = [strength_scale*knl(0), 0.0_rp, len_scale*ele%value(l$)]    
  else
    slick_class = 7
    slick_params = [strength_scale*knl(0)*sign_of(tilt(0)), 0.0_rp, len_scale*ele%value(l$)]    
  endif

case (marker$)
  slick_class = 1
  slick_params = 0

case (drift$, monitor$)
  ! Ignore

case default
  print *, 'Cannot translate: ' // trim(ele%name) // ': ' // trim(key_name(ele%key))
end select

end subroutine ele_to_slick_params

!---------------------------------------------------------------------------
! contains

subroutine write_insert_ele_def (nn, names, edge_kl)

real(rp), optional :: edge_kl
integer nn
integer i, j
character(*) names(:)
character(100) line
character(4) nc

!
nn = nn + 1
nc = int_str(nn)
j = len_trim(nc)

do i = 1, size(names)
  select case (names(i))
  case ('HC'); line = '    6 HC______  0.00000000  0.00000000  0.10000000    1   0.000000    0'
  case ('VC'); line = '    7 VC______  0.00000000  0.00000000  0.10000000    1   0.000000    0'
  case ('HQ'); line = '    6 HQ______  0.00000000  0.00000000  0.10000000    1   0.000000    0'
  case ('VQ'); line = '    7 VQ______  0.00000000  0.00000000  0.10000000    1   0.000000    0'
  case ('RQ'); line = '    4 RQ______  0.00000000  0.00000000  0.00000000    1   0.000000    0'
  case ('CQ'); line = '    3 CQ______  0.00000000  0.00000000  0.00000000    1   0.000000    0'
  case ('VD'); line = '    7 VD______  0.00000000  0.00000000  0.10000000    1   0.000000    0'
  case ('EE'); write (line, '(a, 2f12.8, a)') &
                      '   97 EE______', edge_kl, edge_kl,    ' 0.00000000    1   0.000000    0'
  end select

  line(15-j:14) = nc(1:j)
  write (1, '(a)') trim(line)
enddo


end subroutine write_insert_ele_def

!---------------------------------------------------------------------------
! contains

subroutine write_insert_ele_position (line, ne, nn, names, s, increment)

real(rp) s
integer ne, nn
integer i, j
character(*) line, names(:)
character(8) ele_name
character(4) nc
logical, optional :: increment

!

if (logic_option(.false., increment)) nn = nn + 1

do i = 1, size(names)
  ne = ne + 1
  if (ne == 5) then
    write (1, '(a)') trim(line)
    line = ''
    ne = 1
  endif

  nc = int_str(nn)
  j = len_trim(nc)
  ele_name = names(i) // '______'
  ele_name(9-j:8) = nc(1:j)

  write (line((ne-1)*22+1:), '(a, f13.6)') ele_name, s
!  write (line((ne-1)*22+1:), '(a, i12)') ele_name, nint(s*1d4)
enddo

end subroutine write_insert_ele_position

!---------------------------------------------------------------------------
! contains

subroutine write_ele_position (line, ne, name, s)

real(rp) s
integer ne
character(*) line, name
character(8) nam

!

ne = ne + 1
if (ne == 5) then
  write (1, '(a)') trim(line)
  line = ''
  ne = 1
endif

nam = name   ! In case name has less than 8 characters.
write (line((ne-1)*22+1:), '(a, f13.6)') nam, s
! write (line((ne-1)*22+1:), '(a, i12)') nam, nint(s*1d4)

end subroutine write_ele_position

end program



