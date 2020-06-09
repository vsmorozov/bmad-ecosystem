!+
! Subroutine type_ele (ele, type_zero_attrib, type_mat6, type_taylor, twiss_out, 
!        type_control, type_wake, type_floor_coords, type_field, type_wall, lines, n_lines)
!
! Subroutine to print or put in a string array information on a lattice element.
! If the lines(:) argument is not present, the element information is printed to the terminal.
!
! Input:
!   ele               -- Ele_struct: Element
!   type_zero_attrib  -- Logical, optional: If False then surpress printing of
!                           real attributes whose value is 0 or switch attributes that have
!                           their default value. Default is False.
!   type_mat6         -- Integer, optional:
!                            = 0   => Do not type ele%mat6
!                            = 4   => Type 4X4 xy submatrix
!                            = 6   => Type full 6x6 matrix (Default)
!   type_taylor       -- Logical, optional: Print out taylor map terms?
!                          If ele%taylor is not allocated then this is ignored.
!                          Default is False.
!   twiss_out         -- Integer, optional: Print the Twiss parameters at the element end?
!                          = 0         => Do not print the Twiss parameters
!                          = radians$  => Print Twiss, phi in radians (Default).
!                          = degrees$  => Print Twiss, phi in degrees.
!                          = cycles$   => Print Twiss, phi in radians/2pi.
!   type_control       -- Logical, optional: Print control status? Default is True.
!                           If ele%branch%lat is not associated cannot print status info.
!   type_wake         -- Logical, optional: If True then print the long-range and 
!                          short-range wakes information. If False then just print
!                          how many terms the wake has. Default is True.
!                          If ele%wake is not allocated then this is ignored.
!   type_floor_coords -- Logical, optional: If True then print the global ("floor")
!                          coordinates at the exit end of the element.
!                          Default is False.
!   type_field        -- Logical, optional: If True then print field maps, converter info, etc. Default is False.
!   type_wall         -- Logical, optional: If True then print wall info. Default is False.
!
! Output       
!   lines(:)     -- Character(200), allocatable, optional: Character array to hold the output. 
!                     If not present, the information is printed to the terminal.
!   n_lines      -- Integer, optional: Number of lines in lines(:) that hold valid output.
!                     n_lines must be present if lines(:) is. 
!-

subroutine type_ele (ele, type_zero_attrib, type_mat6, type_taylor, twiss_out, &
             type_control, type_wake, type_floor_coords, type_field, type_wall, lines, n_lines)

use bmad_interface, except_dummy => type_ele
use expression_mod
use indexx_mod

implicit none

type (ele_struct), target :: ele
type (ele_struct), pointer :: lord, slave, ele0, lord2
type (lat_struct), pointer :: lat
type (branch_struct), pointer :: branch
type (floor_position_struct) :: floor, f0, floor2
type (wake_lr_mode_struct), pointer :: lr
type (wake_sr_mode_struct), pointer :: mode
type (cartesian_map_struct), pointer :: ct_map
type (cartesian_map_term1_struct), pointer :: ct_term
type (cylindrical_map_struct), pointer :: cl_map
type (cylindrical_map_term1_struct), pointer :: cl_term
type (grid_field_struct), pointer :: g_field
type (grid_field_pt1_struct), pointer :: g_pt
type (taylor_field_struct), pointer :: t_field
type (taylor_field_plane1_struct), pointer :: t_term
type (wall3d_struct), pointer :: wall3d
type (wall3d_section_struct), pointer :: section
type (wall3d_vertex_struct), pointer :: v
type (photon_element_struct), pointer :: p
type (photon_surface_struct), pointer :: s
type (ele_attribute_struct) attrib, attrib2
type (lat_param_struct) param
type (control_struct), pointer :: ctl
type (all_pointer_struct) a_ptr
type (ac_kicker_struct), pointer :: ac
type (str_indexx_struct) str_index

integer, optional, intent(in) :: type_mat6, twiss_out
integer, optional, intent(out) :: n_lines
integer i, i1, j, n, is, ix, iw, ix2_attrib, iv, ic, nl2, l_status, a_type, default_val
integer nl, nt, n_term, n_att, attrib_type, n_char, iy, particle, ix_pole_max

real(rp) coef, val, L_mis(3), S_mis(3,3) 
real(rp) a(0:n_pole_maxx), b(0:n_pole_maxx)
real(rp) a2(0:n_pole_maxx), b2(0:n_pole_maxx)
real(rp) knl(0:n_pole_maxx), tn(0:n_pole_maxx)
real(rp), pointer :: r_ptr

character(*), optional, allocatable :: lines(:)
character(:), allocatable :: expression_str
character(200), allocatable, target :: li(:)
character(200), allocatable :: li2(:)
character(200) :: line
character(60) str1, str2
character(40) a_name, name, fmt_r, fmt_a, fmt_i, fmt_l, fmt
character(12) attrib_val_str, units, q_factor
character(8) angle, index_str

character(*), parameter :: r_name = 'type_ele'

logical, optional, intent(in) :: type_taylor, type_wake
logical, optional, intent(in) :: type_control, type_zero_attrib
logical, optional :: type_floor_coords, type_field, type_wall
logical type_zero, err_flag, print_it, is_default, has_it, has_been_added, z1, z2

! init

allocate (li(300))

type_zero = logic_option(.false., type_zero_attrib)
branch => pointer_to_branch(ele)

if (associated(branch)) then
  lat => branch%lat
  particle = branch%param%particle
  call lat_sanity_check(branch%lat, err_flag)
else
  nullify(lat)
  particle = electron$
endif

! Encode element name and type

nl = 0  

if (ele%ix_branch /= 0) then
  if (associated(lat)) then
    nl=nl+1; write (li(nl), *) 'Branch #      ', ele%ix_branch, ': ', trim(branch%name)
  else
    nl=nl+1; write (li(nl), *) 'Branch #      ', ele%ix_branch
  endif
endif
nl=nl+1; write (li(nl), *)     'Element #     ', ele%ix_ele
nl=nl+1; write (li(nl), *)     'Element Name: ', trim(ele%name)

if (ele%type /= blank_name$) then
  nl=nl+1; write (li(nl), *) 'Element Type: "', trim(ele%type), '"'
endif

if (ele%alias /= blank_name$) then
  nl=nl+1; write (li(nl), *) 'Element Alias: "', trim(ele%alias), '"'
endif

if (associated(ele%descrip)) then
  nl=nl+1; write (li(nl), *) 'Descrip: "', trim(ele%descrip), '"'
endif

! Encode element key and attributes

if (ele%key <= 0) then
  nl=nl+1; write (li(nl), *) 'Key: BAD VALUE!', ele%key
else
  nl=nl+1; write (li(nl), *) 'Key: ', key_name(ele%key)
endif

if (ele%sub_key /= 0) then
  nl=nl+1; write (li(nl), *) 'Sub Key: ', sub_key_name(ele%sub_key)
endif

nl=nl+1; write (li(nl), '(1x, 3(a, f14.6))')  'S_start, S:',  ele%s_start, ',', ele%s
nl=nl+1; write (li(nl), '(1x, a, es14.6)') 'Ref_time:', ele%ref_time

nl=nl+1; li(nl) = ''
if (type_zero) then
  nl=nl+1; write (li(nl), *) 'Attribute values:'
else
  nl=nl+1; write (li(nl), *) 'Attribute values [Only non-zero values shown]:'
endif

n_att = n_attrib_string_max_len() + 1
write (fmt_a, '(a, i0, a)') '(7x, a, t', n_att+9, ', a, 2x, 3a)'
write (fmt_i, '(a, i0, a)') '(7x, a, t', n_att+9, ', a, i6)'
write (fmt_l, '(a, i0, a)') '(7x, a, t', n_att+9, ', a, 2x, l1)'
write (fmt_r, '(a, i0, a)') '(7x, a, t', n_att+9, ', a, 2x, es15.7)'


do i = 1, num_ele_attrib$
  attrib = attribute_info(ele, i)
  attrib%value = ele%value(i)
  a_name = attrib%name
  if (a_name == null_name$) cycle
  if (a_name == 'MULTIPASS_REF_ENERGY' .and. (ele%lord_status /= multipass_lord$ .and. ele%slave_status /= multipass_slave$)) cycle
  if (a_name == 'LORD_PAD1' .and. ele%lord_status /= super_lord$) cycle
  if (attrib%state == private$) cycle
  if (is_2nd_column_attribute(ele, a_name, ix2_attrib)) cycle

  attrib2 = ele_attribute_struct()

  select case (a_name)
  case ('RF_FREQUENCY');    if (ele%value(i) /= 0) attrib2 = ele_attribute_struct('RF_WAVELENGTH', dependent$, is_real$, 'm', -1, &
                                                                            c_light * ele%value(p0c$) / (ele%value(i) * ele%value(e_tot$)))
  case ('P0C')
    if (particle == photon$) then
      attrib2 = ele_attribute_struct('REF_WAVELENGTH', dependent$, is_real$, 'm', -1, c_light * h_planck / ele%value(p0c$))
    else
      attrib2 = ele_attribute_struct('BETA', dependent$, is_real$, '', -1, ele%value(p0c$) / ele%value(e_tot$))
    endif
  case ('E_TOT'); if (particle /= photon$) attrib2 = ele_attribute_struct('GAMMA', dependent$, is_real$, '', -1, ele%value(e_tot$) / mass_of(particle))
  case ('P0C_START');       attrib2 = ele_attribute_struct('BETA_START', dependent$, is_real$, '', -1, ele%value(p0c_start$) / ele%value(e_tot_start$))
  case ('E_TOT_START');     attrib2 = ele_attribute_struct('DELTA_E', dependent$, is_real$, 'eV', -1, ele%value(e_tot$) - ele%value(e_tot_start$))
  case ('DARWIN_WIDTH_SIGMA', 'DARWIN_WIDTH_PI')
    attrib2 = ele_attribute_struct(a_name, dependent$, is_real$, 'eV', -1, ele%value(i) / ele%value(dbragg_angle_de$))
  case ('DBRAGG_ANGLE_DE'); attrib2 = ele_attribute_struct(a_name, dependent$, is_real$, 'deg/eV', -1, ele%value(i) * 180 / pi)
  case default
    if (index(a_name, 'ANGLE') /= 0 .and. a_name /= 'CRITICAL_ANGLE_FACTOR') then
      attrib2 = ele_attribute_struct(a_name, dependent$, is_real$, 'deg', -1, ele%value(i) * 180 / pi)
    else
      if (ix2_attrib > 0) then
        attrib2 = attribute_info(ele, ix2_attrib)
        attrib2%value = ele%value(ix2_attrib)
      endif
    endif
  end select

  z1 = ((attrib%kind == is_real$ .or. attrib%kind == is_integer$) .and. attrib%value == 0)
  z2 = ((attrib2%kind == is_real$ .or. attrib2%kind == is_integer$) .and. attrib2%value == 0)
  if (z1 .and. z2 .and. .not. type_zero) cycle

  line = ''
  call write_this_attribute (attrib, n_att, line(3:))
  call write_this_attribute (attrib2, 28, line(n_att+33:))
  nl=nl+1; li(nl) = line
enddo

! Custom attributes

if (ele%slave_status /= super_slave$) then
  do i = 1, custom_attribute_num$
    attrib = attribute_info(ele, i+custom_attribute0$)
    if (attrib%name(1:1) == '!') cycle
    nl=nl+1; write (li(nl), '(i5, 3x, 2a, es15.7, 3x, a)') &
                  i, attrib%name(1:n_att), '=', value_of_attribute(ele, attrib%name, err_flag), '! Custom attribute'
  enddo
endif

! Multipoles

if (associated(ele%a_pole) .or. associated(ele%a_pole_elec)) then
  nl=nl+1; write (li(nl), '(5x, a, l1)') 'MULTIPOLES_ON    = ', ele%multipoles_on 
endif

if (associated(ele%a_pole)) then
  if (attribute_index(ele, 'SCALE_MULTIPOLES') == scale_multipoles$) then
    nl=nl+1; write (li(nl), '(5x, a, l1, 2x, a)') 'SCALE_MULTIPOLES = ', ele%scale_multipoles, &
                                    '! Magnet strength scaling? Reference momentum scaling done if FIELD_MASTER = T.'
  endif

  if (associated(branch)) param = branch%param

  a = 0; b = 0; a2 = 0; b2 = 0; knl = 0; tn = 0
  if (ele%key == multipole$) then
    call multipole_ele_to_ab (ele, .false., ix_pole_max, a,  b)
    call multipole_ele_to_kt (ele, .true.,  ix_pole_max, knl, tn)
  else
    call multipole_ele_to_ab (ele, .false., ix_pole_max, a,  b)
    call multipole_ele_to_ab (ele, .true.,  ix_pole_max, a2, b2)
    call multipole_ele_to_kt (ele, .true.,  ix_pole_max, knl, tn)
  endif

  do i = 0, n_pole_maxx
    if (a(i) == 0 .and. b(i) == 0) cycle

    if (ele%key == multipole$) then
      nl=nl+1; write (li(nl), '(2x, 3(3x, a, i0, a, es11.3))') &
              'K', i, 'L       =', ele%a_pole(i), 'KS', i, '       =', ele%a_pole_elec(i), 'T', i, '        =', ele%b_pole(i)
      nl=nl+1; write (li(nl), '(2x, 3(3x, a, i0, a, es11.3))') &
              'B', i, '(equiv) =', b(i),          'A', i,  '(equiv) =', a(i),              'T', i, '(equiv) =', tn(i)

    elseif (ele%key == ab_multipole$) then
      nl=nl+1; write (li(nl), '(2x, 3(3x, a, i0, a, es11.3))') &
                 'A', i, ' =', ele%a_pole(i), 'A', i, '(w/Tilt) =', a2(i), 'K', i, 'L(equiv) =', knl(i)
      nl=nl+1; write (li(nl), '(2x, 3(3x, a, i0, a, es11.3))') &
                 'B', i, ' =', ele%b_pole(i), 'B', i, '(w/Tilt) =', b2(i), 'T', i, '(equiv)  =', tn(i)

    else
      nl=nl+1; write (li(nl), '(2x, 4(3x, a, i0, a, es11.3))') 'A', i, ' =', ele%a_pole(i), &
                 'A', i, '(Scaled) =', a(i), 'A', i, '(w/Tilt) =', a2(i), 'K', i, 'L(equiv) =', knl(i)
      nl=nl+1; write (li(nl), '(2x, 4(3x, a, i0, a, es11.3))') 'B', i, ' =', ele%b_pole(i), &
                 'B', i, '(Scaled) =', b(i), 'B', i, '(w/Tilt) =', b2(i), 'T', i, '(equiv)  =', tn(i)
    endif

  enddo
endif

! Electric Multipoles

if (associated(ele%a_pole_elec)) then
  call multipole_ele_to_ab (ele, .false., ix_pole_max, a, b, electric$)

  do i = 0, n_pole_maxx
    if (a(i) == 0 .and. b(i) == 0) cycle
    nl=nl+1; write (li(nl), '(2x, 4(3x, a, i0, a, es11.3))') 'A', i, '_elec =', ele%a_pole_elec(i), 'A', i, '_elec(Scaled) =', a(i)
    nl=nl+1; write (li(nl), '(2x, 4(3x, a, i0, a, es11.3))') 'B', i, '_elec =', ele%b_pole_elec(i), 'B', i, '_elec(Scaled) =', b(i)
  enddo
endif

! Encode on/off status etc.

if (.not. ele%is_on) then
  nl=nl+1; write (li(nl), *) '*** Note: Element is turned OFF ***'
endif

! Encode methods, etc.

nl=nl+1; write (li(nl), *) ''
nl2 = nl     ! For 2nd column parameters

if (attribute_name(ele, crystal_type$) == 'CRYSTAL_TYPE') then
  nl=nl+1; write (li(nl), fmt_a) 'CRYSTAL_TYPE', '=', ele%component_name
endif

if (attribute_name(ele, material_type$) == 'MATERIAL_TYPE') then
  nl=nl+1; write (li(nl), fmt_a) 'MATERIAL_TYPE', '=', ele%component_name
endif

if (attribute_name(ele, origin_ele$) == 'ORIGIN_ELE') then
  nl=nl+1; write (li(nl), fmt_a) 'ORIGIN_ELE', '=', '"', trim(ele%component_name), '"'
endif

if (attribute_name(ele, physical_source$) == 'PHYSICAL_SOURCE') then
  nl=nl+1; write (li(nl), fmt_a) 'PHYSICAL_SOURCE', '=', '"', trim(ele%component_name), '"'
endif

if (attribute_name(ele, tracking_method$) == 'TRACKING_METHOD') then
  nl=nl+1; write (li(nl), fmt_a) &
                  'TRACKING_METHOD', '=', tracking_method_name(ele%tracking_method)
endif

if (attribute_name(ele, mat6_calc_method$) == 'MAT6_CALC_METHOD') then
  nl=nl+1; write (li(nl), fmt_a) &
                  'MAT6_CALC_METHOD', '=', mat6_calc_method_name(ele%mat6_calc_method)
endif

if (attribute_name(ele, spin_tracking_method$) == 'SPIN_TRACKING_METHOD') then
  nl=nl+1; write (li(nl), fmt_a) &
                  'SPIN_TRACKING_METHOD', '=', spin_tracking_method_name(ele%spin_tracking_method)
endif

if (attribute_name(ele, ptc_integration_type$) == 'PTC_INTEGRATION_TYPE') then
  nl=nl+1; write (li(nl), fmt_a) &
                  'PTC_INTEGRATION_TYPE', '=', ptc_integration_type_name(ele%ptc_integration_type)
endif

! csr_method and space_charge_method not defined for multipass_lord elements.

if (ele%lord_status /= multipass_lord$ .and. attribute_name(ele, csr_method$) == 'CSR_METHOD') then
  nl=nl+1; write (li(nl), fmt_a) &
                  'CSR_METHOD', '=', csr_method_name(ele%csr_method)
endif

if (ele%lord_status /= multipass_lord$ .and. attribute_name(ele, space_charge_method$) == 'SPACE_CHARGE_METHOD') then
  nl=nl+1; write (li(nl), fmt_a) &
                  'SPACE_CHARGE_METHOD', '=', space_charge_method_name(ele%space_charge_method)
endif

if (attribute_name(ele, field_calc$) == 'FIELD_CALC') then
  nl=nl+1; write (li(nl), fmt_a) 'FIELD_CALC', '=', field_calc_name(ele%field_calc)
endif

! Write second column parameters

if (ele%key == beambeam$ .and. associated(branch)) then
  call encode_2nd_column_parameter (li, nl2, nl, 'PARAMETER[N_PART]', re_val = branch%param%n_part)
endif

if (attribute_name(ele, aperture_at$) == 'APERTURE_AT' .and. ele%aperture_at /= 0) then
  call encode_2nd_column_parameter (li, nl2, nl, 'APERTURE_AT', str_val = aperture_at_name(ele%aperture_at))
  call encode_2nd_column_parameter (li, nl2, nl, 'APERTURE_TYPE', str_val = aperture_type_name(ele%aperture_type))
  call encode_2nd_column_parameter (li, nl2, nl, 'OFFSET_MOVES_APERTURE', logic_val = ele%offset_moves_aperture)
endif

if (attribute_index(ele, 'SYMPLECTIFY') /= 0) then
  call encode_2nd_column_parameter (li, nl2, nl, 'SYMPLECTIFY', logic_val = ele%symplectify)
endif
  
if (attribute_index(ele, 'FIELD_MASTER') /= 0) then
  call encode_2nd_column_parameter (li, nl2, nl, 'FIELD_MASTER', logic_val = ele%field_master)
endif

if (ele%key /= overlay$ .and. ele%key /= group$ .and. ele%key /= girder$) then
  call encode_2nd_column_parameter (li, nl2, nl, 'LONGITUDINAL ORIENTATION', int_val = ele%orientation)
endif

! Converter

if (associated(ele%converter)) then
  do i = 1, size(ele%converter%dist)
  enddo
endif

! Cartesian map

if (associated(ele%cartesian_map)) then
  if (logic_option(.false., type_field)) then
    nl=nl+1; li(nl) = ''
    if (ele%field_calc == bmad_standard$) then
      nl=nl+1; li(nl) = 'Cartesian_map: [NOT USED SINCE FIELD_CALC = BMAD_STANDARD]'
    else
      nl=nl+1; li(nl) = 'Cartesian_map:'
    endif
    do i = 1, size(ele%cartesian_map)
      ct_map => ele%cartesian_map(i)
      if (ct_map%master_parameter == 0) then
        name = '<None>'
      else
        name = attribute_name(ele, ct_map%master_parameter)
      endif

      nl=nl+1; write (li(nl), '(a, i0)')      '  Mode #:', i
      nl=nl+1; write (li(nl), '(2a)')         '    From file:        ', trim(ct_map%ptr%file)
      nl=nl+1; write (li(nl), '(2a)')         '    field_type        ', trim(em_field_type_name(ct_map%field_type))
      nl=nl+1; write (li(nl), '(2a)')         '    master_parameter: ', trim(name)
      nl=nl+1; write (li(nl), '(2a)')         '    ele_anchor_pt:    ', anchor_pt_name(ct_map%ele_anchor_pt)
      nl=nl+1; write (li(nl), '(a, es16.8)')  '    field_scale:      ', ct_map%field_scale
      nl=nl+1; write (li(nl), '(a, 3es16.8)') '    r0:               ', ct_map%r0
      nl=nl+1; write (li(nl), '(a, i0)')      '    n_link:           ', ct_map%ptr%n_link
      nl=nl+1; write (li(nl), '(5x, a, 6x, a, 3(9x, a), 2(12x, a), 9x, a, 3x, a)') 'Term#', &
                                    'Coef', 'K_x', 'K_y', 'K_z', 'x0', 'y0', 'phi_z', 'Type'
      do j = 1, min(10, size(ct_map%ptr%term))
        if (nl+1 > size(li)) call re_allocate(li, 2 * nl, .false.)
        ct_term => ct_map%ptr%term(j)
        nl=nl+1; write (li(nl), '(i8, 4f12.6, 3f14.6, 3x, a, 2x, a)') j, ct_term%coef, ct_term%kx, ct_term%ky, ct_term%kz, ct_term%x0, &
                               ct_term%y0, ct_term%phi_z, cartesian_map_family_name(ct_term%family), cartesian_map_form_name(ct_term%form)
      enddo
      if (size(ct_map%ptr%term) > 10) then
        nl=nl+1; write (li(nl), '(a, i0, a)') '     .... etc ... (#Terms = ', size(ct_map%ptr%term), ')' 
      endif
    enddo
  else
    nl=nl+1; write (li(nl), '(a, i5)') 'Number of Cartesian_map modes:', size(ele%cartesian_map)
  endif
endif

! Cylindrical_map

if (associated(ele%cylindrical_map)) then
  if (logic_option(.false., type_field)) then
    nl=nl+1; li(nl) = ''
    if (ele%field_calc == bmad_standard$) then
      nl=nl+1; li(nl) = 'Cylindrical_map: [NOT USED SINCE FIELD_CALC = BMAD_STANDARD]'
    else
      nl=nl+1; li(nl) = 'Cylindrical_map:'
    endif
    do i = 1, size(ele%cylindrical_map)
      cl_map => ele%cylindrical_map(i)
      if (cl_map%master_parameter == 0) then
        name = '<None>'
      else
        name = attribute_name(ele, cl_map%master_parameter)
      endif

      nl=nl+1; write (li(nl), '(a, i0)')      '  Mode #:', i
      nl=nl+1; write (li(nl), '(2a)')         '    From file:        ', trim(cl_map%ptr%file)
      nl=nl+1; write (li(nl), '(2a)')         '    master_parameter: ', trim(name)
      nl=nl+1; write (li(nl), '(a, i0)')      '    harmonic:         ', cl_map%harmonic
      nl=nl+1; write (li(nl), '(a, i0)')      '    m:                ', cl_map%m
      nl=nl+1; write (li(nl), '(a, es16.8)')  '    field_scale:      ', cl_map%field_scale
      nl=nl+1; write (li(nl), '(a, es16.8)')  '    dz:               ', cl_map%dz
      nl=nl+1; write (li(nl), '(a, 3es16.8)') '    r0:               ', cl_map%r0
      nl=nl+1; write (li(nl), '(a, es16.8)')  '    phi0_fieldmap:    ', cl_map%phi0_fieldmap
      nl=nl+1; write (li(nl), '(a, es16.8)')  '    theta0_azimuth:   ', cl_map%theta0_azimuth
      nl=nl+1; write (li(nl), '(2a)')         '    ele_anchor_pt:    ', anchor_pt_name(cl_map%ele_anchor_pt)
      nl=nl+1; write (li(nl), '(a, i0)')      '    n_link:           ', cl_map%ptr%n_link
      nl=nl+1; write (li(nl), '(a)')          '    Term                E                           B'
      do j = 1, min(10, size(cl_map%ptr%term))
        if (nl+1 > size(li)) call re_allocate(li, 2 * nl, .false.)
        cl_term => cl_map%ptr%term(j)
        nl=nl+1; write (li(nl), '(i5, 3x, 2(a, 2es12.4), a)') j, '(', cl_term%e_coef, ')  (', cl_term%b_coef, ')'
      enddo
      if (size(cl_map%ptr%term) > 10) then
        nl=nl+1; write (li(nl), '(a, i0, a)') '     .... etc ... (#Terms = ', size(cl_map%ptr%term), ')' 
      endif
    enddo
  else
    nl=nl+1; write (li(nl), '(a, i5)') 'Number of Cylindrical_map modes:', size(ele%cylindrical_map)
  endif
endif

! Grid_field

if (associated(ele%grid_field)) then
  if (logic_option(.false., type_field)) then
    nl=nl+1; li(nl) = ''
    if (ele%field_calc == bmad_standard$) then
      nl=nl+1; li(nl) = 'Grid_field: [NOT USED SINCE FIELD_CALC = BMAD_STANDARD]'
    else
      nl=nl+1; li(nl) = 'Grid_field:'
    endif
    do i = 1, size(ele%grid_field)
      g_field => ele%grid_field(i)
      if (g_field%master_parameter == 0) then
        name = '<None>'
      else
        name = attribute_name(ele, g_field%master_parameter)
      endif

      nl=nl+1; write (li(nl), '(a, i0)')      '  Mode #:', i
      nl=nl+1; write (li(nl), '(2a)')         '    From file:          ', trim(g_field%ptr%file)
      nl=nl+1; write (li(nl), '(2a)')         '    field_type:         ', em_field_type_name(g_field%field_type)
      nl=nl+1; write (li(nl), '(2a)')         '    geometry:           ', grid_field_geometry_name(g_field%geometry)
      nl=nl+1; write (li(nl), '(2a)')         '    master_parameter:   ', trim(name)
      nl=nl+1; write (li(nl), '(2a)')         '    ele_anchor_pt:      ', anchor_pt_name(g_field%ele_anchor_pt)
      nl=nl+1; write (li(nl), '(a, i0)')      '    harmonic:           ', g_field%harmonic
      nl=nl+1; write (li(nl), '(a, i0)')      '    interpolation_order ', g_field%interpolation_order
      nl=nl+1; write (li(nl), '(a, es16.8)')  '    field_scale:        ', g_field%field_scale
      nl=nl+1; write (li(nl), '(a, es16.8)')  '    phi0_fieldmap:      ', g_field%phi0_fieldmap
      nl=nl+1; write (li(nl), '(a, l1)')      '    curved_ref_frame    ', g_field%curved_ref_frame
      nl=nl+1; write (li(nl), '(a, i0)')      '    n_link:             ', g_field%ptr%n_link
      nl=nl+1; write (li(nl), '(a, 3f14.6)')  '    dr:                 ', g_field%dr
      nl=nl+1; write (li(nl), '(a, 3f14.6)')  '    r0:                 ', g_field%r0
      nl=nl+1; write (li(nl), '(a, 3i14)')    '    Index_max:          ', ubound(g_field%ptr%pt)
      nl=nl+1; write (li(nl), '(a, 3i14)')    '    Index_min:          ', lbound(g_field%ptr%pt)
      nl=nl+1; write (li(nl), '(a, 3f14.6)')  '    r_max:              ', ubound(g_field%ptr%pt)*g_field%dr + g_field%r0
      nl=nl+1; write (li(nl), '(a, 3f14.6)')  '    r_min:              ', lbound(g_field%ptr%pt)*g_field%dr + g_field%r0
    enddo
  else
    nl=nl+1; write (li(nl), '(a, i5)') 'Number of Grid_field modes:', size(ele%grid_field)
  endif
endif

! Taylor_field

if (associated(ele%taylor_field)) then
  if (logic_option(.false., type_field)) then
    nl=nl+1; li(nl) = ''
    if (ele%field_calc == bmad_standard$) then
      nl=nl+1; li(nl) = 'Taylor_field: [NOT USED SINCE FIELD_CALC = BMAD_STANDARD]'
    else
      nl=nl+1; li(nl) = 'Taylor_field:'
    endif
    do i = 1, size(ele%taylor_field)
      t_field => ele%taylor_field(i)
      if (t_field%master_parameter == 0) then
        name = '<None>'
      else
        name = attribute_name(ele, t_field%master_parameter)
      endif

      nl=nl+1; write (li(nl), '(a, i0)')      '  Mode #:', i
      nl=nl+1; write (li(nl), '(2a)')         '    From file:         ', trim(t_field%ptr%file)
      nl=nl+1; write (li(nl), '(2a)')         '    field_type:        ', em_field_type_name(t_field%field_type)
      nl=nl+1; write (li(nl), '(a, es16.8)')  '    field_scale:       ', t_field%field_scale
      nl=nl+1; write (li(nl), '(a, es16.8)')  '    dz:                ', t_field%dz
      nl=nl+1; write (li(nl), '(a, 3es16.8)') '    r0:                ', t_field%r0
      nl=nl+1; write (li(nl), '(2a)')         '    master_parameter:  ', trim(name)
      nl=nl+1; write (li(nl), '(2a)')         '    ele_anchor_pt:     ', anchor_pt_name(t_field%ele_anchor_pt)
      nl=nl+1; write (li(nl), '(a, l1)')      '    curved_ref_frame   ', t_field%curved_ref_frame
      nl=nl+1; write (li(nl), '(a, l1)')      '    canonical_tracking ', t_field%canonical_tracking
      nl=nl+1; write (li(nl), '(a, i0)')      '    n_link:            ', t_field%ptr%n_link
      nl=nl+1; write (li(nl), '(a, i0)')      '    n_plane:           ', size(t_field%ptr%plane)
    enddo
  else
    nl=nl+1; write (li(nl), '(a, i5)') 'Number of Taylor_field modes:', size(ele%taylor_field)
  endif
endif

! ac_kick

if (associated(ele%ac_kick) .and. logic_option(.false., type_field)) then
  ac => ele%ac_kick
  nl=nl+1; li(nl) = ''

  if (allocated(ac%amp_vs_time)) then
    nl=nl+1; li(nl) = '     Indx      Time       Amplitude'    
    do i = 1, size(ac%amp_vs_time)
      nl=nl+1; write (li(nl), '(i9, 2es14.6)') i, ac%amp_vs_time(i)%time, ac%amp_vs_time(i)%amp
    enddo
  endif

  if (allocated(ac%frequencies)) then
    nl=nl+1; li(nl) = '     Indx          Freq     Amplitude           Phi'    
    do i = 1, size(ac%frequencies)
      nl=nl+1; write (li(nl), '(i9, 3es14.6)') i, &
                                ac%frequencies(i)%f, ac%frequencies(i)%amp, ac%frequencies(i)%phi
    enddo
  endif
endif

! wall3d cross-sections.
! Do not print more than 100 sections.

if (associated(ele%wall3d)) then
  do iw = 1, size(ele%wall3d)
    wall3d => ele%wall3d(iw)
    nl=nl+1; write (li(nl), '(a, i5)') ''
    nl=nl+1; write (li(nl), '(2a)') 'Wall name: ', trim(wall3d%name)
    nl=nl+1; write (li(nl), '(a, i5)') 'Number of Wall Sections:', size(wall3d%section)
    nl=nl+1; write (li(nl), '(a, 2f11.5)') 'Wall region:',  wall3d%section(1)%s, wall3d%section(size(wall3d%section))%s
    if (logic_option(.false., type_wall)) then
      nl=nl+1; write (li(nl), '(2a)') 'Wall%ele_anchor_pt = ', anchor_pt_name(wall3d%ele_anchor_pt)
      select case (ele%key)
      case (capillary$)
      case (diffraction_plate$, mask$)
        nl=nl+1; write (li(nl), '(a, f10.6)') 'Wall%thickness       = ', wall3d%thickness
        nl=nl+1; write (li(nl), '(3a)')       'Wall%clear_material  = ', quote(wall3d%clear_material)
        nl=nl+1; write (li(nl), '(3a)')       'Wall%opaque_material = ', quote(wall3d%opaque_material)
      case default
        nl=nl+1; write (li(nl), '(a, l)') 'Wall%superimpose     = ', wall3d%superimpose
      end select
      n = min(size(wall3d%section), 100)
      do i = 1, n
        call re_allocate (li, nl+100, .false.) 
        section => wall3d%section(i)
        if (section%dr_ds == real_garbage$) then
          write (str1, '(a)')        ',  dr_ds = Not-set'
        else
          write (str1, '(a, f10.6)') ',  dr_ds =', section%dr_ds
        endif
        str2 = ''
        if (ele%key /= capillary$) then
          write (str2, '(2a)') ',   Type = ', trim(wall3d_section_type_name(section%type))
        endif

        nl=nl+1; write (li(nl), '(a, i0, a, f10.6, 2a, 2(f11.6, a), a)') &
                    'Wall%Section(', i, '):  S =', section%s, trim(str1),  ',   r0 = (', &
                    section%r0(1), ',', section%r0(2), ')', trim(str2)


        do j = 1, size(section%v)
          v => section%v(j)
          nl=nl+1; write (li(nl), '(4x, a, i0, a, 5f11.6)') &
                                'v(', j, ') =', v%x, v%y, v%radius_x, v%radius_y, v%tilt
        enddo
      enddo
    endif
  enddo
elseif (logic_option(.false., type_wall)) then
  nl=nl+1; write (li(nl), '(a)') 'No associated Wall.'
endif

! surface info

p => ele%photon
if (associated(p)) then
  s => ele%photon%surface
  nl=nl+1; write (li(nl), *)
  nl=nl+1; write (li(nl), *) 'Surface:'
 
  if (s%has_curvature) then
    nl=nl+1; write (li(nl), '(a, f11.6)')  'Spherical_Curvature        = ', s%spherical_curvature
    nl=nl+1; write (li(nl), '(a, 3f11.6)') 'Elliptical_Curvature_X/Y/Z = ', s%elliptical_curvature
    do ix = 0, ubound(s%curvature_xy, 1)
    do iy = 0, ubound(s%curvature_xy, 2)
      if (s%curvature_xy(ix,iy) == 0) cycle
      nl=nl+1; write (li(nl), '(2x, 2(2x, 2(a, i0), a, es14.6))') 'CURVATURE_X', ix, '_Y', iy, ' =', s%curvature_xy(ix,iy)
    enddo
    enddo
  else
    nl=nl+1; li(nl) = '    No Curvature'
  endif
  nl=nl+1; write (li(nl), '(4x, 2a)') 'Grid type:    ', surface_grid_type_name(s%grid%type)
  if (s%grid%type /= off$) then
    nl=nl+1; write (li(nl), '(4x, a, 2f10.6)')   'Grid dr:     ', s%grid%dr
    if (allocated(s%grid%pt)) then
      nl=nl+1; write (li(nl), '(4x, a, 2f10.6)') 'Grid r0:     ', s%grid%r0
      nl=nl+1; write (li(nl), '(4x, a, 2i10)')   'Num grid pts:', ubound(s%grid%pt) + 1
      nl=nl+1; write (li(nl), '(4x, a, 2(a, f10.6, a, f10.6, a, 4x))') &
                                                  'Grid bounds:', &
                        '(', -s%grid%r0(1), ',', -s%grid%r0(1) + ubound(s%grid%pt, 1) * s%grid%dr(1), ')', & 
                        '(', -s%grid%r0(2), ',', -s%grid%r0(2) + ubound(s%grid%pt, 2) * s%grid%dr(2), ')' 
    endif
  endif

  if (p%material%f_h /= 0) then
    if (ele%key == multilayer_mirror$) then
      nl = nl+1; write (li(nl), '(2(a,f10.3))') 'F_0 (Material 1):', real(p%material%f0_m1), ' + I ', aimag(p%material%f0_m1)
      nl = nl+1; write (li(nl), '(2(a,f10.3))') 'F_0 (Material 2):', real(p%material%f0_m2), ' + I ', aimag(p%material%f0_m2)
    else
      nl = nl+1; write (li(nl), '(2(a,f10.3))') 'F_0:             ', real(p%material%f_0), ' + I ', aimag(p%material%f_0)
    endif
    nl = nl+1; write (li(nl), '(2(a,f10.3))') 'F_H:             ', real(p%material%f_h), ' + I ', aimag(p%material%f_h)
    nl = nl+1; write (li(nl), '(2(a,f10.3))') 'F_Hbar:          ', real(p%material%f_hbar), ' + I ', aimag(p%material%f_hbar)
    nl = nl+1; write (li(nl), '(2(a,f10.3))') 'Sqrt(F_H*F_Hbar):', real(p%material%f_hkl), ' + I ', aimag(p%material%f_hkl)
  endif

endif

! Encode branch info

if (ele%key == fork$ .or. ele%key == photon_fork$) then
  if (li(nl) /= '') then
    nl=nl+1; li(nl) = ' '
  endif

  n = nint(ele%value(ix_to_branch$))
  i = nint(ele%value(ix_to_element$))
  if (associated(lat)) then
    nl=nl+1; write (li(nl), '(5a, 2(i0, a))') 'Branch to: ', trim(lat%branch(n)%name), '>>', &
                                  trim(lat%branch(n)%ele(i)%name), '  [', n, '>>', i, ']'
  else
    nl=nl+1; write (li(nl), '(a, i0, a, i0)') 'Branch to: ', n, '>>', i
  endif
endif

! Encode lord/slave info.
! For super_lords there is no attribute_name associated with a slave.
! For slaves who are overlay_lords then the attribute_name is obtained by
!   looking at the overlay_lord's 1st slave (slave of slave of the input ele).

if (associated(lat) .and. logic_option(.true., type_control)) then
  ! Print info on element's lords

  if (li(nl) /= '') then
    nl=nl+1; li(nl) = ' '
  endif

  if (ele%slave_status <= 0) then
    nl=nl+1; write (li(nl), '(a)') 'Slave_status: BAD! PLEASE SEEK HELP!', ele%slave_status
  else
    nl=nl+1; write (li(nl), '(2a)') 'Slave_status: ', control_name(ele%slave_status)
  endif

  if (nL + ele%n_lord + 100 > size(li)) call re_allocate(li, nl + ele%n_lord + 100)

  select case (ele%slave_status)
  case (multipass_slave$)
    lord => pointer_to_lord(ele, 1)
    nl=nl+1; write (li(nl), '(3a, i0, a)') 'Associated Multipass_Lord: ', trim(lord%name), '  (Index: ', lord%ix_ele, ')'
    nl=nl+1; li(nl) = 'Other slaves of this Lord:'
    nl=nl+1; li(nl) = '     Index   Name'
    do i = 1, lord%n_slave
      slave => pointer_to_slave(lord, i)
      if (slave%ix_ele == ele%ix_ele .and. slave%ix_branch == ele%ix_branch) cycle
      nl=nl+1; write (li(nl), '(a, 3x, a)') adjustr(ele_loc_name(slave)), trim(slave%name)
    enddo

  case (super_slave$)
    nl=nl+1; write (li(nl), '(3a, i0, a)') 'Associated Super_Lord(s):'
    nl=nl+1; li(nl) = '   Index   Name                             Type'
    do i = 1, ele%n_lord
      lord => pointer_to_lord(ele, i)
      if (lord%lord_status /= super_lord$) cycle
      if (lord%slave_status == multipass_slave$) then
        lord2 => pointer_to_lord(lord, 1)
        nl=nl+1; write (li(nl), '(i8, 3x, a, t45, 3a, 2x, a)') lord%ix_ele, trim(lord%name), trim(key_name(lord%key)), &
                      '   --> Multipass_slave of: ', trim(ele_loc_name(lord2)), lord2%name
      else
        nl=nl+1; write (li(nl), '(i8, 3x, a, t45, a)') lord%ix_ele, trim(lord%name), trim(key_name(lord%key))
      endif
    enddo
  end select

  ! Print controller lords

  has_it = .false.
  do i = 1, ele%n_lord
    lord => pointer_to_lord(ele, i)
    if (lord%lord_status == multipass_lord$ .or. lord%lord_status == super_lord$) cycle
    has_it = .true.
    exit
  enddo

  if (has_it) then
    nl=nl+1; li(nl) = 'Controller Lord(s):'
    nl=nl+1; li(nl) = '   Index   Name                            Attribute           Lord_Type           Expression'

    allocate (character(100) :: expression_str)
    do i = 1, ele%n_lord
      lord => pointer_to_lord (ele, i, ctl)
      select case (lord%lord_status)
      case (super_lord$, multipass_lord$)
        cycle
      case (girder_lord$)
        expression_str = ''
        a_name = ''
      case default
        if (allocated(ctl%stack)) then
          call split_expression_string (expression_stack_to_string (ctl%stack), 70, 5, li2)
        else
          call re_allocate (li2, 1)
          li2(1) = '<Knots>'
        endif
        iv = ctl%ix_attrib
        a_name = attribute_name(ele, iv)
      end select

      nl=nl+1; write (li(nl), '(i8, 3x, a32, a18, 2x, a20, a)') &
            lord%ix_ele, lord%name, a_name, key_name(lord%key), trim(li2(1))
      do j = 2, size(li2)
        nl=nl+1; li(nl) = ''; li(nl)(84:) = li2(j)
      enddo
    enddo
  endif

  !

  has_it = .false.
  nl=nl+1; li(nl) = ' '
  nl=nl+1; li(nl) = 'Elements whose fields overlap this one:'
  nl=nl+1; li(nl) = '   Index   Name                               Type'

  if (ele%slave_status == super_slave$ .or. ele%slave_status == multipass_slave$) then
    do i = 1, ele%n_lord
      lord => pointer_to_lord(ele, i)
      if (lord%slave_status == multipass_slave$) lord => pointer_to_lord(lord, 1)
      do j = 1, lord%n_lord_field
        has_it = .true.
        lord2 => pointer_to_lord(lord, lord%n_lord+i)
        nl=nl+1; write (li(nl), '(a8, t12, a35, a16, f10.3)') &
                      trim(ele_loc_name(lord2)), lord2%name, key_name(lord2%key)
      enddo
    enddo
  else
    do i = 1, ele%n_lord_field
      has_it = .true.
      lord2 => pointer_to_lord(lord, lord%n_lord+i)
      nl=nl+1; write (li(nl), '(a8, t12, a35, a16, f10.3)') &
                    trim(ele_loc_name(lord2)), lord2%name, key_name(lord2%key)

    enddo
  endif

  if (.not. has_it) nl = nl - 3

  ! Print info on elements slaves.

  nl=nl+1; li(nl) = ' '

  if (ele%lord_status <= 0) then
    nl=nl+1; write (li(nl), '(a)') 'Lord_status: BAD!', ele%lord_status
  else
    nl=nl+1; write (li(nl), '(2a)') 'Lord_status:  ', control_name(ele%lord_status)
  endif

  if (associated(ele%control)) then
    nl=nl+1; li(nl) = 'Control Variables:'
    n_att = maxval(len_trim(ele%control%var%name))

    if (ele%lord_status == group_lord$) then
      do i = 1, size(ele%control%var)
        a_name = ele%control%var(i)%name
        nl=nl+1; write (li(nl), '(i5, 3x, 2a, es15.7, 11x, 3a, es15.7)')  i, &
                      a_name(1:n_att), '  =', ele%control%var(i)%value, &
                      'OLD_', a_name(1:n_att), '  =', ele%control%var(i)%old_value
      enddo
    else  ! overlay_lord
      do i = 1, size(ele%control%var)
        nl=nl+1; write (li(nl), '(i5, 3x, 2a, es15.7)')  i, &
                      ele%control%var(i)%name, '  =', ele%control%var(i)%value
      enddo
    endif

    if (ele%control%type == spline$ .or. ele%control%type == linear$) then
      do i = 1, size(ele%control%x_knot)
      enddo
    endif

    ! Print named constants if present

    print_it = .true.
    do is = 1, ele%n_slave
      slave => pointer_to_slave (ele, is, ctl)
      if (allocated(ctl%stack)) then
        if (nl + size(ctl%stack) + 100 > size(li)) call re_allocate(li, nl + size(ctl%stack) + 100)
        do i = 1, size(ctl%stack)
          if (ctl%stack(i)%type == end_stack$) exit
          if (ctl%stack(i)%type /= variable$) cycle
          if (ctl%stack(i)%name == '') cycle
          if (any(ctl%stack(i)%name == physical_const_list%name)) cycle
          call find_indexx(ctl%stack(i)%name, str_index, ix, add_to_list = .true., has_been_added = has_been_added)
          if (.not. (has_been_added)) cycle  ! Avoid duuplicates
          if (print_it) then
            nl=nl+1; li(nl) = 'Named Constants:'
            print_it = .false.
          endif
          nl=nl+1; write (li(nl), '(8x, 2a, es15.7)') trim(ctl%stack(i)%name), ' = ', ctl%stack(i)%value
        enddo
      endif
    enddo
  endif

  !

  if (ele%n_slave /= 0) then
    if (nl + ele%n_slave + 100 > size(li)) call re_allocate(li, nl + ele%n_slave + 100)

    n_char = 10
    do i = 1, ele%n_slave
      slave => pointer_to_slave (ele, i)
      n_char = max(n_char, len_trim(slave%name))
    enddo

    select case (ele%lord_status)

    case (multipass_lord$, super_lord$, girder_lord$)
      nl=nl+1; write (li(nl), '(a, i4)') 'Slaves:'
      nl=nl+1; li(nl) = '   Index   Name';  li(nl)(n_char+14:) = 'Type                     S'
      do i = 1, ele%n_slave
        slave => pointer_to_slave (ele, i)
        nl=nl+1; write (li(nl), '(a8, t12, a, 2x, a16, 3x, f14.6)') &
                    trim(ele_loc_name(slave)), slave%name(1:n_char), key_name(slave%key), slave%s
      enddo

    case default
      if (ele%key == overlay$) then
        nl=nl+1; write (li(nl), '(a, i4)') 'Slaves: [Attrib_Value = Expression_Val summed over all Overlays controlling the attribute.]'
      else ! Group
        nl=nl+1; write (li(nl), '(a, i4)') 'Slaves: [Attrib_Value = Value of the controlled attribute, Expression_Val = Value calculated by this Group element.]'
      endif
      nl=nl+1; li(nl) = '   Index   Ele_Name';  li(nl)(n_char+14:) = 'Attribute         Attrib_Value  Expression_Val     Expression'
      do ix = 1, ele%n_slave
        slave => pointer_to_slave (ele, ix, ctl)

        select case (ctl%attribute)
        case ('ACCORDION_EDGE', 'START_EDGE', 'END_EDGE', 'S_POSITION')  ! Special group constructs
          attrib_val_str = ' ----'
        case default
          call pointer_to_attribute (slave, ctl%attribute, .false., a_ptr, err_flag)
          attrib_val_str = ' ----'
          if (associated(a_ptr%r)) write (attrib_val_str, '(es12.4)') a_ptr%r
        end select

        if (.not. allocated(expression_str)) allocate(character(100):: expression_str)
        write (str1, '(es12.4)') ctl%value
        if (allocated(ctl%stack)) then
          call split_expression_string (str1(1:17) // expression_stack_to_string (ctl%stack), 70, 5, li2)
        else  ! Spline
          call re_allocate (li2, 1)
          li2(1) = str1(1:17) // '<Knots>'
        endif

        nl=nl+1; write (li(nl), '(a8, t12, a, 2x, a18, a, 4x, a)') trim(ele_loc_name(slave)), slave%name(1:n_char), ctl%attribute, attrib_val_str, li2(1)
        do i = 2, size(li2)
          n = 44 + n_char + len(attrib_val_str)
          nl=nl+1; li(nl) = ''; li(nl)(n:) = li2(i)
        enddo

      enddo
    end select
  endif

  ! Print elements that are field overlapped.

  has_it = .false.
  nl=nl+1; li(nl) = ' '
  nl=nl+1; li(nl) = "This element's field overlaps:"
  nl=nl+1; li(nl) = '   Index   Name                                      Type '

  if (ele%slave_status == super_slave$ .or. ele%slave_status == multipass_slave$) then
    do i = 1, ele%n_lord
      lord => pointer_to_lord(ele, i)
      if (lord%slave_status == multipass_slave$) lord => pointer_to_lord(lord, 1)
      do j = 1, lord%n_slave_field
        has_it = .true.
        slave => pointer_to_slave(ele, ele%n_slave+i)
        nl=nl+1; write (li(nl), '(a8, t12, a30, a16, f10.3)') &
                      trim(ele_loc_name(slave)), slave%name, trim(key_name(slave%key))
      enddo
    enddo
  else
    do i = 1, ele%n_slave_field
      has_it = .true.
      slave => pointer_to_slave(ele, ele%n_slave+i)
      nl=nl+1; write (li(nl), '(a8, t12, a30, a16, f10.3)') &
                    trim(ele_loc_name(slave)), slave%name, trim(key_name(slave%key))
    enddo
  endif

  if (.not. has_it) nl = nl - 3
endif

! Encode Twiss info

if (associated(branch) .and. ele%lord_status == not_a_lord$) then
  if (.not. branch%param%live_branch) then
    nl=nl+1; li(nl) = ''
    nl=nl+1; li(nl) = 'NOTE: Branch containing element is not live (branch''s live_branch parameter has been set to False).'
  endif
endif

if (integer_option(radians$, twiss_out) /= 0 .and. ele%a%beta /= 0) then
  nl=nl+1; li(nl) = ''
  nl=nl+1; li(nl) = 'Twiss at end of element:'
  call type_twiss (ele, twiss_out, .false., li(nl+1:), nl2)
  nl = nl + nl2
endif

l_status = ele%lord_status
if (l_status /= overlay_lord$ .and. l_status /= multipass_lord$ .and. &
    l_status /= group_lord$ .and. l_status /= girder_lord$) then

  ! Encode mat6 info

  n = integer_option (6, type_mat6)
  if (n > 6) n = 6
  if (n < 0) n = 0

  if (n /= 0) then
    nl=nl+1; li(nl) = ' '
    nl=nl+1; write (li(nl), '(a, es12.3, a, t82, a, t95, a, t108, a)') 'Transfer Matrix : Kick  [Mat symplectic error:', &
                 mat_symp_error(ele%mat6), ']', 'Vec0'
  endif

  if (any(abs(ele%mat6(1:n,1:n)) >= 1d3)) then
    write (fmt, '(a, i0, a)') '(', n, 'es12.4, a, es13.5, 2es15.5)'
  else
    write (fmt, '(a, i0, a)') '(', n, 'f12.7, a, es13.5, 2es15.5)'
  endif

  do i = 1, n
    nl=nl+1; write (li(nl), fmt) (ele%mat6(i, j), j = 1, n), '   : ', ele%vec0(i)
  enddo

  ! Encode taylor series

  if (associated(ele%taylor(1)%term)) then
    nl=nl+1; li(nl) = ' '
    nl=nl+1; write (li(nl), '(a, l1)') 'taylor_map_includes_offsets: ', ele%taylor_map_includes_offsets
    if (logic_option(.false., type_taylor)) then
      call type_taylors (ele%taylor, lines = li2, n_lines = nt, out_type = 'PHASE')
      call re_allocate (li, nl+nt+100, .false.)
      li(1+nl:nt+nl) = li2(1:nt)
      deallocate (li2)
      nl = nl + nt
    else
      n_term = 0
      do i = 1, size(ele%taylor)
        n_term = n_term + size(ele%taylor(i)%term)
      enddo
      nl=nl+1; write (li(nl), '(a, i6)') 'Taylor map total number of terms:', n_term
    endif
  endif

  if (associated(ele%spin_taylor(0)%term) .or. ele%key == taylor$) then
    if (logic_option(.false., type_taylor)) then
      nl=nl+1; li(nl) = ''
      call type_taylors (ele%spin_taylor, lines = li2, n_lines = nt, out_type = 'SPIN')
      call re_allocate (li, nl+nt+100, .false.)
      li(1+nl:nt+nl) = li2(1:nt)
      deallocate (li2)
      nl = nl + nt
    else
      n_term = 0
      do i = 0, 3
        n_term = n_term + size(ele%spin_taylor(i)%term)
      enddo
      nl=nl+1; write (li(nl), '(a, i6)') 'Spin_Taylor map total number of terms:', n_term
    endif
  endif

endif

! Print wake info

if (associated(ele%wake)) then

  if (logic_option (.true., type_wake) .and. (size(ele%wake%sr%long) /= 0 .or. &
                                                       size(ele%wake%sr%trans) /= 0)) then
    nl=nl+1; li(nl) = ''
    nl=nl+1; li(nl) = 'Short-Range Wake:'
    if (ele%wake%sr%file /= '') then
      nl=nl+1; li(nl) = '  SR_File: ' // trim(ele%wake%sr%file)
    endif
    nl=nl+1; write (li(nl), '(2x, a, l2)') 'scale_with_length =', ele%wake%sr%scale_with_length
    nl=nl+1; write (li(nl), '(2x, 2a)')    'amp_scale         = ', to_str(ele%wake%sr%amp_scale)
    nl=nl+1; write (li(nl), '(2x, 2a)')    'z_scale           = ', to_str(ele%wake%sr%z_scale)
    nl=nl+1; write (li(nl), '(2x, 2a)')    'z_max             = ', to_str(ele%wake%sr%z_max)
  endif

  if (size(ele%wake%sr%long) /= 0) then
    nl=nl+1; write (li(nl), *)
    if (logic_option (.true., type_wake)) then
      call re_allocate (li, nl+size(ele%wake%sr%long)+100, .false.)
      nl=nl+1; li(nl) = '  Short-Range Longitudinal Pseudo Modes:'
      nl=nl+1; li(nl) = &
            '   #        Amp        Damp           K         Phi   Transverse_Dependence'
      do i = 1, size(ele%wake%sr%long)
        mode => ele%wake%sr%long(i)
        nl=nl+1; write (li(nl), '(i4, 4es12.4, a15, a16)') i, mode%amp, mode%damp, mode%k, mode%phi, &
                  sr_longitudinal_position_dep_name(mode%position_dependence)
      enddo
    else
      nl=nl+1; li(nl) = '  No short-range longitudinal pseudo modes.'
    endif
  endif

  if (size(ele%wake%sr%trans) /= 0) then
    nl=nl+1; write (li(nl), *)
    if (logic_option (.true., type_wake)) then
      call re_allocate (li, nl+size(ele%wake%sr%trans)+100, .false.)
      nl=nl+1; li(nl) = '  Short-Range Transverse Pseudo Modes:'
      nl=nl+1; li(nl) = &
            '   #        Amp        Damp           K         Phi   Polarization  Transverse_Dependence'
      do i = 1, size(ele%wake%sr%trans)
        mode => ele%wake%sr%trans(i)
        nl=nl+1; write (li(nl), '(i4, 4es12.4, a15, a16)') i, mode%amp, mode%damp, mode%k, mode%phi, &
                  sr_transverse_polarization_name(mode%polarization), sr_transverse_position_dep_name(mode%position_dependence)
      enddo
    else
     nl=nl+1; li(nl) = '  No short-range transverse pseudo modes.'
    endif
  endif

  if (logic_option (.true., type_wake) .and. size(ele%wake%lr%mode) /= 0) then
    nl=nl+1; li(nl) = ''
    nl=nl+1; li(nl) = 'Long-Range Wake:'
    if (ele%wake%lr%file /= '') then
      nl=nl+1; li(nl) = '  LR_File: ' // trim(ele%wake%lr%file)
    endif
    nl=nl+1; write (li(nl), '(2x, 2a)')    'amp_scale    = ', to_str(ele%wake%lr%amp_scale)
    nl=nl+1; write (li(nl), '(2x, 2a)')    'time_scale   = ', to_str(ele%wake%lr%time_scale)
    nl=nl+1; write (li(nl), '(2x, 2a)')    'freq_spread  = ', to_str(ele%wake%lr%freq_spread)
    nl=nl+1; write (li(nl), '(2x, a, l1)') 'self_wake_on = ', ele%wake%lr%self_wake_on
    nl=nl+1; write (li(nl), '(2x, 2a)')    't_ref        = ', to_str(ele%wake%lr%t_ref)
  endif

  if (size(ele%wake%lr%mode) /= 0) then
    nl=nl+1; write (li(nl), *)
    if (logic_option (.true., type_wake)) then
      call re_allocate (li, nl+size(ele%wake%lr%mode)+100, .false.)
      nl=nl+1; li(nl) = '  Long-Range Wake Modes [Note: Freq will not be equal to Freq_in if there is a frequency spread]:'
      nl=nl+1; li(nl) = &
            '  #     Freq_in        Freq         R/Q        Damp           Q        Phi   m   Angle    b_sin     b_cos     a_sin     a_cos'
      do i = 1, size(ele%wake%lr%mode)
        lr => ele%wake%lr%mode(i)
        angle = ' unpolar'
        if (lr%polarized) write (angle, '(f8.3)') lr%angle
        if (lr%damp == 0 .or. lr%freq <= 0) then
          q_factor = '      ------'
        else
          write (q_factor, '(es12.4)') pi * lr%freq / lr%damp
        endif


        nl=nl+1; write (li(nl), '(i3, 4es12.4, a, es12.4, i3, a, 5es10.2)') i, &
                lr%freq_in, lr%freq, lr%R_over_Q, lr%damp, q_factor, lr%phi, lr%m, angle, &
                lr%b_sin, lr%b_cos, lr%a_sin, lr%a_cos
      enddo
    else
      nl=nl+1; li(nl) = '  No long-range HOM modes.'
    endif
  endif

endif

! Encode Floor coords. 
! Elements not associated with a lattice do not have floor coords.

if (logic_option(.false., type_floor_coords) .and. associated(ele%branch)) then
  ele0 => pointer_to_next_ele(ele, -1)

  select case (ele%key)
  case (crystal$, mirror$, multilayer_mirror$)
    call ele_geometry (ele0%floor, ele, floor2, 0.5_rp)
    floor = ele_geometry_with_misalignments (ele, 0.5_rp)

    nl=nl+1; li(nl) = ''
    nl=nl+1; li(nl) = 'Global Floor Coords at Surface of Element:'
    nl=nl+1; write (li(nl), '(a)')         '                   X           Y           Z       Theta         Phi         Psi'
    nl=nl+1; write (li(nl), '(a, 6f12.5, 3x, a)') 'Reference', floor2%r, floor2%theta, floor2%phi, floor2%psi, '! Position without misalignments'
    nl=nl+1; write (li(nl), '(a, 6f12.5, 3x, a)') 'Actual   ', floor%r, floor%theta, floor%phi, floor%psi, '! Position with offset/pitch/tilt misalignments'
  end select

  !

  floor = ele_geometry_with_misalignments (ele)

  nl=nl+1; li(nl) = ''
  nl=nl+1; li(nl) = 'Global Floor Coords at End of Element:'
  nl=nl+1; write (li(nl), '(a)')         '                   X           Y           Z       Theta         Phi         Psi'
  nl=nl+1; write (li(nl), '(a, 6f12.5, 3x, a)') 'Reference', ele%floor%r, ele%floor%theta, ele%floor%phi, ele%floor%psi, '! Position without misalignments'
  nl=nl+1; write (li(nl), '(a, 6f12.5, 3x, a)') 'Actual   ', floor%r, floor%theta, floor%phi, floor%psi, '! Position with offset/pitch/tilt misalignments'

  ! Note: If ele is a multipass_lord then ele0 does not exist

  if (associated(ele0) .and. (ele%ix_ele /= 0 .or. branch%param%geometry == closed$)) then
    f0 = ele0%floor
    nl=nl+1; write (li(nl), '(a, 6f12.5, 3x, a)') 'delta Ref', floor%r-f0%r, floor%theta-f0%theta, floor%phi-f0%phi, floor%psi-f0%psi, &
                                                                                                       '! Delta with respect to last element'  
  endif
endif

! finish

if (present(lines)) then
  call re_allocate(lines, nl, .false.)
  n_lines = nl
  lines(1:nl) = li(1:nl)
else
  do i = 1, nl
    print '(1x, a)', trim(li(i))
  enddo
endif

!----------------------------------------------------------------------------------------------------
contains

subroutine encode_2nd_column_parameter (li, nl2, nl, attrib_name, re_val, str_val, logic_val, int_val)

integer nl2, nl, ix0
integer, optional :: int_val
real(rp), optional :: re_val
logical, optional :: logic_val

character(*), target :: li(:), attrib_name
character(*), optional :: str_val
character(200), pointer :: line
character(40) value, name

!

nl2 = nl2 + 1
line => li(nl2)

! If the number of second column parameters exceeds number of first column parameters.
if (nl < nl2) then
  nl = nl2
  line = ''  ! In case there is garbage
endif

if (present(re_val)) then
  write (value, '(es15.7)') re_val
elseif (present(str_val)) then
  value = str_val
elseif (present(logic_val)) then
  write (value, '(l1)') logic_val
elseif (present(int_val)) then
  write (value, '(i6)') int_val
else
  call err_exit
endif

name = attrib_name
n = 8 + n_attrib_string_max_len() + 31
write (line(n:), '(a27, a, 2x, a)') name, '=', value

end subroutine encode_2nd_column_parameter 

!--------------------------------------------------------------------------
! contains
!+
! Function is_2nd_column_attribute (ele, attrib_name, ix2_attrib) result (is_2nd_col_attrib)
!
! Function to:
!     1) Return True if attribute is to be displayed in the 2nd column.
!     2) If attribute is a 1st column attribute with a corresponding 2nd column attribute: Set ix2_attrib accordingly.
! 
! Input:
!   ele           -- ele_struct: Element
!   attrib_name   -- character(*): Name of attribute     
!
! Output:
!   is_2nd_col_attrib -- logical: True if a second column attribute. False otherwise.
!   ix2_attrib        -- integer: If  > 0 --> Index of corresponding second column attribute.
!-

function is_2nd_column_attribute (ele, attrib_name, ix2_attrib) result (is_2nd_col_attrib)

type (ele_struct) ele
integer ix, ia, ix_attrib, ix2_attrib
character(*) attrib_name
character(40) a_name, a2_name
logical is_2nd_col_attrib

character(40), parameter :: att_name(46) = [character(40):: 'X_PITCH', 'Y_PITCH', 'X_OFFSET', &
                'Y_OFFSET', 'Z_OFFSET', 'REF_TILT', 'TILT', 'ROLL', 'X1_LIMIT', 'Y1_LIMIT', &
                'FB1', 'FQ1', 'LORD_PAD1', 'HKICK', 'VKICK', 'FRINGE_TYPE', 'DS_STEP', 'R0_MAG', &
                'KS', 'K1', 'K2', 'G', 'G_ERR', 'H1', 'E1', 'FINT', 'HGAP', &
                'L_CHORD', 'PTC_FIELD_GEOMETRY', 'AUTOSCALE_AMPLITUDE', 'FIELD_AUTOSCALE', 'COUPLER_AT', &
                'VOLTAGE', 'PHI0', 'N_CELL', 'X_GAIN_ERR', 'X_GAIN_CALIB', 'X_OFFSET_CALIB', &
                'BETA_A', 'ALPHA_A', 'CRAB_X1', 'CRAB_X3', 'PX_APERTURE_WIDTH2', 'PY_APERTURE_WIDTH2', &
                'PZ_APERTURE_WIDTH2', 'Z_APERTURE_WIDTH2']

character(40), parameter :: att2_name(46) = [character(40):: 'X_PITCH_TOT', 'Y_PITCH_TOT', 'X_OFFSET_TOT', &
                'Y_OFFSET_TOT', 'Z_OFFSET_TOT', 'REF_TILT_TOT', 'TILT_TOT', 'ROLL_TOT', 'X2_LIMIT', 'Y2_LIMIT', &
                'FB2', 'FQ2', 'LORD_PAD2', 'BL_HKICK', 'BL_VKICK', 'FRINGE_AT', 'NUM_STEPS', 'R0_ELEC', &
                'BS_FIELD', 'B1_GRADIENT', 'B2_GRADIENT', 'B_FIELD', 'B_FIELD_ERR', 'H2', 'E2', 'FINTX', 'HGAPX', &
                'L_SAGITTA', 'PTC_FRINGE_GEOMETRY', 'AUTOSCALE_PHASE', 'PHI0_AUTOSCALE', 'COUPLER_STRENGTH', &
                'GRADIENT', 'PHI0_MULTIPASS', 'CAVITY_TYPE', 'Y_GAIN_ERR', 'Y_GAIN_CALIB', 'Y_OFFSET_CALIB', &
                'BETA_B', 'ALPHA_B', 'CRAB_X2', 'CRAB_TILT', 'PX_APERTURE_CENTER', 'PY_APERTURE_CENTER', &
                'PZ_APERTURE_CENTER', 'Z_APERTURE_CENTER']

! Exceptional cases

ix2_attrib = -1
is_2nd_col_attrib = .false.

select case (attrib_name)
case ('L')
  is_2nd_col_attrib = .false.
  if (has_attribute(ele, 'L_HARD_EDGE')) then
    ix2_attrib = l_hard_edge$
  elseif (has_attribute(ele, 'L_SOFT_EDGE')) then
    ix2_attrib = l_soft_edge$
  endif
  return

case ('L_SOFT_EDGE', 'L_HARD_EDGE')
  is_2nd_col_attrib = .true.
  return
end select

! Is a 2nd column attribute if corresponding first column attribute exists

call match_word (attrib_name, att2_name, ix, .true., .false.)
if (ix > 0) then
  ia = attribute_index(ele, att_name(ix))
  is_2nd_col_attrib = (ia > 0)
  return
endif

! If the attribute has a corresponding 2nd column attribute, set ix2_attrib accordingly.

call match_word (attrib_name, att_name, ix, .true., .false.)
if (ix > 0) ix2_attrib = attribute_index(ele, att2_name(ix))

end function is_2nd_column_attribute

!--------------------------------------------------------------------------
! contains

subroutine write_this_attribute (attrib, n_name_width, line)

type (ele_attribute_struct) attrib
integer n_name_width
character(*) line
character(40) name
character(3) str_ix

!

if (attrib%kind == does_not_exist$) return

if (attrib%ix_attrib > 0) then
  write (str_ix, '(i3)') attrib%ix_attrib
else
  str_ix = ''
endif

select case (attrib%kind)
case (is_logical$)
  if (ele%value(i) /= 0) ele%value(i) = 1
  write (line, '(a, 2x, 2a, l1, a, i0, a)')  str_ix, attrib%name(1:n_name_width), '=  ', is_true(attrib%value), ' (', nint(attrib%value), ')'
case (is_integer$)
  write (line, '(a, 2x, 2a, i0)')  str_ix, attrib%name(1:n_name_width), '= ', nint(attrib%value)
case (is_real$)
  write (line, '(a, 2x, 2a, es15.7, 1x, a8)')  str_ix, attrib%name(1:n_name_width), '=', attrib%value, attrib%units
case (is_switch$)
  name = switch_attrib_value_name (attrib%name, attrib%value, ele, is_default)
  write (line, '(a, 2x, 4a, i0, a)')  str_ix, attrib%name(1:n_name_width), '=  ', trim(name), ' (', nint(attrib%value), ')'
end select

end subroutine write_this_attribute

end subroutine type_ele
