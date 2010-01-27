module synrad_write_power_mod

use synrad_mod

contains

!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------

subroutine write_power_header (iu, file, gen_params, synrad_mode)

  implicit none

  type (synrad_param_struct) gen_params
  type (synrad_mode_struct) synrad_mode
  character(*) file
  integer iu

!

  open (unit = iu, file = file)
  write (iu, *) 'Lattice: ', gen_params%lat_file
  write (iu, *) 'I_beam    =', gen_params%i_beam,    ' ! Amps/beam'
  write (iu, *) 'Epsilon_y =', gen_params%epsilon_y, ' ! Vertical emittance'

  write (iu, '(3(/,2x,a))') &
'          Segment                                  ', &
'  Ix  Name          S_seg      X_seg     P/len      P/Area     P_tot     Phot/sec      A Beta    B Beta    A Eta     Ele Type       Relevant               Ele',&
'                     (m)        (m)      (W/m)     (W/mm^2)      (W)      (1/s)         (m)        (m)      (m)      at s_mid       Attribute              Name'

end subroutine

!-------------------------------------------------------------------------
!-------------------------------------------------------------------------
!-------------------------------------------------------------------------

subroutine write_power_results (wall, lat, gen_params, use_ele_ix, synrad_mode)

  implicit none

  type (wall_struct), target :: wall
  type (wall_seg_struct), pointer :: seg
  type (seg_power_struct), pointer :: ep
  type (synrad_param_struct) gen_params
  type (synrad_mode_struct) :: synrad_mode
  type (lat_struct) lat

  integer use_ele_ix, i
  character*16 seg_name, ep_source_name, e_source_name, p_source_name
  character fmt*100, ep_name*2
  character file1*50, ele_num*6
  character ele_at_seg*16, attrib*10
  integer key
  real(rp) value

!

  call set_wall_eles (wall, lat)

  file1 = 'synch_power_' // trim(wall_name(wall%side))
  if (use_ele_ix .ne. 0) then
    write (ele_num, '(i6.6)') use_ele_ix
    file1 = trim(file1) // '_' // trim(ele_num)
  endif
  file1 = trim(file1) // '.dat'
  call downcase_string (file1)
  call write_power_header (1, file1, gen_params, synrad_mode)


  do i = 1, wall%n_seg_tot
    seg => wall%seg(i)
    key = lat%ele(seg%ix_ele)%key
    attrib = ' '
    value = 0

    if (key == quadrupole$) then
      attrib = 'k1 = '
      value = lat%ele(seg%ix_ele)%value(k1$)
    elseif (key == sol_quad$) then
      attrib = 'k1 = '
      value = lat%ele(seg%ix_ele)%value(k1$)
    elseif (key == solenoid$) then
      attrib = 'ks = '
      value = lat%ele(seg%ix_ele)%value(ks$)
    elseif (key == sbend$) then
      attrib = 'G = '
      value = lat%ele(seg%ix_ele)%value(g$)
    elseif (key == rbend$) then
      attrib = 'G = '
      value = lat%ele(seg%ix_ele)%value(g$)
    elseif (key == sextupole$) then
      attrib = 'k2 = '
      value = lat%ele(seg%ix_ele)%value(k2$)
    elseif (key == wiggler$) then
      attrib = 'B_max = '
      value = lat%ele(seg%ix_ele)%value(b_max$)
!      call type_ele(lat%ele(seg%ix_ele))
    end if

    ep => seg%power

    if (ep%ix_ele_source == 0) then
      ep_source_name = '--------'
      ep_name = '--'
    else
      ep_source_name = lat%ele(ep%ix_ele_source)%name
    endif

    seg_name = wall%pt(seg%ix_pt)%name
    call str_substitute (seg_name, ' ', '_', .true.)

    fmt = '(i6, 1x, a10, f10.4, 2es11.3, 3es12.4, 3f10.3, 2x, a16, 1x, a10, es12.4, 1x, a)'
    write (1, fmt) &
              i, seg_name, seg%s, seg%x, &
              ep%power_per_len, &
              1.e-6 * (ep%power_per_area), &
              ep%power_tot, ep%photons_per_sec, &
              seg%a%beta, seg%b%beta,seg%a%eta, key_name(key), &
              attrib, value, trim(lat%ele(seg%ix_ele)%name)

!    fmt = '(f10.4, 3es11.3)'
!    write (1, fmt) &
!              seg%s, &
!              ep%power_per_len, &
!              1.e-6 * (ep%power_per_area), &
!              ep%photons_per_sec

  enddo
  close (unit = 1)
  type *, 'Written: ', file1

end subroutine write_power_results

!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------

subroutine write_header (iu, file, gen_params, synrad_mode)

  implicit none

  type (synrad_param_struct) gen_params
  type (synrad_mode_struct) synrad_mode
  character(*) file
  integer iu

!

  open (unit = iu, file = file)
  write (iu, *) 'Lattice: ', gen_params%lat_file
  write (iu, *) 'I_beam    =', gen_params%i_beam,    ' ! Amps/beam'
  write (iu, *) 'Input eps_y =', 1.e6*gen_params%epsilon_y, ' ! mm-mrad'

  write (iu, *) 'Electron eps_x =', 1.e6*synrad_mode%ele_mode%a%emittance, ' ! mm-mrad'
  write (iu, *) 'Electron eps_y =', 1.e6*synrad_mode%ele_mode%b%emittance, ' ! mm-mrad'
  write (iu, *) 'Electron sig_z =', synrad_mode%ele_mode%sig_z, ' ! m'
  write (iu, *) 'Electron sigE/E =',1.e2*synrad_mode%ele_mode%sigE_E, ' ! %'

  write (iu, '(3(/,2x,a))') &
'          Segment                                  ', &
'  Ix  Name          S_seg      X_seg     P/len      P/Area     P_tot     Phot/sec      A Beta    B Beta    A Eta     Ele Type       Relevant               Ele',&
'                     (m)        (m)      (W/m)     (W/mm^2)      (W)      (1/s)         (m)        (m)      (m)      at s_mid       Attribute              Name'

end subroutine

!-------------------------------------------------------------------------
!-------------------------------------------------------------------------
!-------------------------------------------------------------------------

subroutine write_results (wall, lat, gen_params, use_ele_ix, synrad_mode)

  implicit none

  type (wall_struct), target :: wall
  type (wall_seg_struct), pointer :: seg
  type (seg_power_struct), pointer :: ep
  type (synrad_param_struct) gen_params
  type (synrad_mode_struct) :: synrad_mode
  type (lat_struct) lat

  integer use_ele_ix, i
  character*16 seg_name, ep_source_name, e_source_name, p_source_name
  character fmt*100, ep_name*2
  character file1*50, ele_num*6
  character ele_at_seg*16, attrib*10
  integer key
  real(rp) value

!

  call set_wall_eles (wall, lat)

  file1 = 'synrad_' // trim(wall_name(wall%side))
  if (use_ele_ix .ne. 0) then
    write (ele_num, '(i6.6)') use_ele_ix
    file1 = trim(file1) // '_' // trim(ele_num)
  endif
  file1 = trim(file1) // '.dat'
  call downcase_string (file1)
  call write_header (1, file1, gen_params, synrad_mode)


  do i = 1, wall%n_seg_tot
    seg => wall%seg(i)
    key = lat%ele(seg%ix_ele)%key
    attrib = ' '
    value = 0

    if (key == quadrupole$) then
      attrib = 'k1 = '
      value = lat%ele(seg%ix_ele)%value(k1$)
    elseif (key == sol_quad$) then
      attrib = 'k1 = '
      value = lat%ele(seg%ix_ele)%value(k1$)
    elseif (key == solenoid$) then
      attrib = 'ks = '
      value = lat%ele(seg%ix_ele)%value(ks$)
    elseif (key == sbend$) then
      attrib = 'G = '
      value = lat%ele(seg%ix_ele)%value(g$)
    elseif (key == rbend$) then
      attrib = 'G = '
      value = lat%ele(seg%ix_ele)%value(g$)
    elseif (key == sextupole$) then
      attrib = 'k2 = '
      value = lat%ele(seg%ix_ele)%value(k2$)
    elseif (key == wiggler$) then
      attrib = 'B_max = '
      value = lat%ele(seg%ix_ele)%value(b_max$)
!      call type_ele(lat%ele(seg%ix_ele))
    end if

    ep => seg%power

    if (ep%ix_ele_source == 0) then
      ep_source_name = '--------'
      ep_name = '--'
    else
      ep_source_name = lat%ele(ep%ix_ele_source)%name
    endif

    seg_name = wall%pt(seg%ix_pt)%name
    call str_substitute (seg_name, ' ', '_', .true.)

    fmt = '(i6, 1x, a10, f10.4, 2es11.3, 3es12.4, 3f10.3, 2x, a16, 1x, a10, es12.4, 1x, a)'
    write (1, fmt) &
              i, seg_name, seg%s, seg%x, &
              ep%power_per_len, &
              1.e-6 * (ep%power_per_area), &
              ep%power_tot, ep%photons_per_sec, &
              seg%a%beta, seg%b%beta,seg%a%eta, key_name(key), &
              attrib, value, trim(lat%ele(seg%ix_ele)%name)

!    fmt = '(f10.4, 2es11.3)'
!    write (1, fmt) &
!              seg%s, &
!              1.e-6 * (ep%power_per_area), &
!              ep%photons_per_sec

  enddo
  close (unit = 1)
  type *, 'Written: ', file1

end subroutine write_results

end module
