module opal_interface_mod

use bmad_struct
use beam_def_struct
use bmad_interface
use write_lat_file_mod
use time_tracker_mod


contains

!------------------------------------------------------------------------
!------------------------------------------------------------------------
!------------------------------------------------------------------------
!+ 
! Subroutine write_opal_lattice_file (opal_file_unit, lat, err)
!
! Subroutine to write an OPAL lattice file using the information in
! a lat_struct. Optionally only part of the lattice can be generated.
!
! Modules needed:
!   ?? use write_lat_file_mod
!
! Input:
!   opal_file_unit -- Integer: unit number to write to
!   lat            -- lat_struct: Holds the lattice information.
!
! Output:
!   err    -- Logical, optional: Set True if, say a file could not be opened.
!-

subroutine write_opal_lattice_file (opal_file_unit, lat, err)

implicit none


type (ele_struct), pointer :: ele
type (lat_struct), target :: lat

integer      :: opal_file_unit
character(200)  :: file_name
character(40)  :: r_name = 'write_opal_lattice_file', name
character(2)   :: continue_char, eol_char, comment_char
character(24)  :: rfmt
character(4000)  :: line

integer      :: iu,  ios, ix_match, ie, ix_start, ix_end, iu_fieldgrid
integer      :: n_names, n
integer     :: q_sign

type (char_indexx_struct) :: fieldgrid_names, ele_names
integer, allocatable      :: ele_name_occurrences(:)

real(rp), pointer :: val(:)
real(rp)        :: absmax_Ez, absmax_Bz, phase_lag, freq, gap

character(40)   :: fieldgrid_output_name

logical, optional :: err

if (present(err)) err = .true.

! If unit number is zero, make a new file
if (opal_file_unit == 0 ) then
  ! Open the file
  iu = lunget()  
  call file_suffixer (lat%input_file_name, file_name, 'opal', .true.)
  open (iu, file = file_name, iostat = ios)
  if (ios /= 0) then
    call out_io (s_error$, r_name, 'CANNOT OPEN FILE: ' // trim(file_name))
    return
  endif
else
  iu = opal_file_unit
endif

! OPAL formatting characters
comment_char = '//'
continue_char = ''
eol_char = ';'

! Elements to write
! Loop over all track and lord elements
ix_start = 1
ix_end = lat%n_ele_max

! Check order
if (ix_start > ix_end) then
  call out_io (s_error$, r_name, 'Bad index range')
  return
endif

! Initialize unique name list
n = ix_end - ix_start + 1
allocate ( ele_names%names(n) ) 
allocate ( ele_names%indexx(n) )
allocate ( ele_name_occurrences(n) )
ele_names%n_max = 0
ele_name_occurrences = 0


! Initialize fieldgrid filename list
n = ix_end - ix_start + 1
allocate ( fieldgrid_names%names(n) ) 
allocate ( fieldgrid_names%indexx(n) )
fieldgrid_names%n_max = 0



!-------------------------------------------
! Write info to the output file...
! lat lattice name

write (iu, '(2a)') comment_char, ' Generated by: write_opal_lattice_file'
write (iu, '(3a)') comment_char, ' Bmad Lattice File: ', trim(lat%input_file_name)
write (iu, '(3a)') comment_char, ' Bmad Lattice Name: ', trim(lat%lattice)
write (iu, *)

! Helper variables
! sign of particle charge
q_sign = sign(1,  charge_of(lat%param%particle) ) 

! Loop over all elements
ele_loop: do ie = ix_start, ix_end
  ele => lat%ele(ie)
  
  ! Skip these elements:
  if (ele%slave_status == super_slave$ .or. &
      ele%slave_status == multipass_slave$ .or. &
      ele%key == girder$ .or. &
      ele%key == overlay$ .or. &
      ele%key == group$) cycle
  
  ! point to value array for convenience
  val => ele%value
  
  ! Clean up "#" and "\" symbols in element name
  call str_substitute (ele%name, "#", "_part_")
  call str_substitute (ele%name, "\", "_and_")  ! "
  
  ! Make unique names  
  call find_indexx (ele%name, ele_names, ix_match)
  if (ix_match > 0) then
    ele_name_occurrences(ix_match) = ele_name_occurrences(ix_match) + 1
    ! Replace ele%name with a unique name
    write(ele%name, '(2a,i0)') trim(ele%name), '_', ele_name_occurrences(ix_match) 
    ! Be careful with this internal write statement
    ! This only works because ele%name is first in the write list
  end if
  ! add name to list  
  call find_indexx (ele%name, ele_names, ix_match, add_to_list = .true.)

  ! Format for numbers
  rfmt = 'es13.5'


  !----------------------------------------------------------
  !----------------------------------------------------------
  ! Element attributes
  select case (ele%key)

  !----------------------------------------------------------
  ! Marker -----------------------------------
  !----------------------------------------------------------
    case (marker$, detector$)
        write (line, '(a)' ) trim(ele%name) // ': marker'
      ! Write ELEMEDGE
      call value_to_line (line, ele%s - val(L$), 'elemedge', rfmt, 'R', ignore_if_zero = .false.)

  !----------------------------------------------------------
  ! Drift -----------------------------------   
  !----------------------------------------------------------
     case (drift$, pipe$, instrument$)
        write (line, '(a, ' // rfmt //')' ) trim(ele%name) // ': drift, l =', val(l$)
      ! Write ELEMEDGE
      call value_to_line (line, ele%s - val(L$), 'elemedge', rfmt, 'R', ignore_if_zero = .false.)

  !----------------------------------------------------------
  ! Sbend -----------------------------------       
  !----------------------------------------------------------
  case (sbend$)
    write (line, '(a, '//rfmt//')') trim(ele%name) // ': sbend, l =', val(L_CHORD$)
    call value_to_line (line, val(b_field$), 'k0', rfmt, 'R')
   ! OPAL's designenergy is in MeV (!!) 
    call value_to_line (line, 1e-6_rp*val(e_tot$), 'designenergy', rfmt, 'R')
    !Edge angles are in radians
    call value_to_line (line, val(e1$), 'E1', rfmt, 'R')
    call value_to_line (line, val(e2$), 'E2', rfmt, 'R')
   ! Full GAP (OPAL) =  2*H_GAP (BMAD)
   ! OPAL will the default fieldmap if the gap is zero  
    if ( val(hgap$) == 0) then
      gap = 1e-6_rp
      write (line, '(2a)') trim(line),  ', fmapfn = "1DPROFILE1-DEFAULT"' 
    else
      gap = 2*val(hgap$)
      ! Write new fieldgrid file, based on the element's name
      fieldgrid_output_name = ''
      write(fieldgrid_output_name, '(3a)') 'fmap_', trim(ele%name), '.t7'
      iu_fieldgrid = lunget()
      open (iu_fieldgrid, file = fieldgrid_output_name, iostat = ios)
      call write_opal_field_grid_file (iu_fieldgrid, ele, lat%param, absmax_Ez)
      close(iu_fieldgrid)
      !Add FMAPFN to line
      write (line, '(4a)') trim(line),  ', fmapfn = "', trim(fieldgrid_output_name), '"'
    endif
    
    call value_to_line (line, gap, 'GAP', rfmt, 'R')

   



  ! elemedge
        call value_to_line (line, ele%s - val(L$), 'elemedge', rfmt, 'R', ignore_if_zero = .false.)

  !----------------------------------------------------------
  ! Solenoid -----------------------------------       
  !----------------------------------------------------------
  case (solenoid$)
  ! Check that there is a map or grid associated to make a decent field grid for OPAL
  if (.not. associated(ele%em_field)  )then
    call out_io (s_error$, r_name, 'No em_field for: ' // key_name(ele%key))
    if (global_com%exit_on_error) call err_exit
  endif
    
    write (line, '(a, '//rfmt//')') trim(ele%name) // ': solenoid, l =', val(l$)

    ! Get field grid name and scaling. This writes the file if needed. 

    call get_opal_fieldgrid_name_and_scaling(&
       ele, lat%param, fieldgrid_names, &
       fieldgrid_output_name, absmax_bz)

   ! Add FMAPFN to line
    write (line, '(4a)') trim(line),  ', fmapfn = "', trim(fieldgrid_output_name), '"'

    ! ks field strength TODO: check specification. Seems to be Tesla
    call value_to_line (line, absmax_bz, 'ks', rfmt, 'R')

  ! elemedge
    call value_to_line (line, ele%s - val(L$), 'elemedge', rfmt, 'R', ignore_if_zero = .false.)    
    
  !----------------------------------------------------------
  ! Quadrupole -----------------------------------   
  !----------------------------------------------------------
     case (quadrupole$)
        write (line, '(a, es13.5)') trim(ele%name) // ': quadrupole, l =', val(l$)
        ! Note that OPAL-T has k1 = dBy/dx, and that bmad needs a -1 sign for electrons
        call value_to_line (line, q_sign*val(b1_gradient$), 'k1', rfmt, 'R')
        call value_to_line (line, ele%s - val(L$), 'elemedge', rfmt, 'R', ignore_if_zero = .false.)
    
  !----------------------------------------------------------
  ! Lcavity, RFCavity, E_gun -----------------------------------
  !----------------------------------------------------------
    case (lcavity$, rfcavity$, e_gun$)
    ! Check that there is a map or grid associated to make a decent field grid for OPAL
    if (.not. associated(ele%em_field)  )then
      call out_io (s_error$, r_name, 'No em_field for: ' // key_name(ele%key))
      if (global_com%exit_on_error) call err_exit
    endif
    
    if (.not. associated(ele%em_field%mode(1)%grid)  )then
      call out_io (s_error$, r_name, 'No grid for: ' // key_name(ele%key), &
                                     '----')
        if (global_com%exit_on_error) call err_exit
      endif
      
    write (line, '(a, es13.5)') trim(ele%name) // ': rfcavity, type = "STANDING", l =', val(l$)

    ! Get field grid name and scaling. This writes the file if needed. 
    call get_opal_fieldgrid_name_and_scaling(&
       ele, lat%param, fieldgrid_names,  &
       fieldgrid_output_name, absmax_ez)

   ! Add FMAPFN to line
    write (line, '(4a)') trim(line),  ', fmapfn = "', trim(fieldgrid_output_name), '"'
  
    ! Write field scaling in MV/m
    call value_to_line (line, 1d-6*absmax_ez, 'volt', rfmt, 'R')
  
    ! Write frequency in MHz
    freq = ele%value(rf_frequency$) * ele%em_field%mode(1)%harmonic
    call value_to_line (line, 1d-6*freq, 'freq', rfmt, 'R')
  
    ! Write phase in rad
    phase_lag = twopi*(ele%value(phi0$) +  ele%value(phi0_err$))
    ! OPAL only autophases for maximum acceleration, so adjust the lag for 'zero-crossing' 
    if (ele%key == rfcavity$) phase_lag = phase_lag - twopi*( ele%value(phi0_max$) - ele%em_field%mode(1)%phi0_ref )
    ! The e_gun needs phase_lag to be pi/2 for some reason
    if (ele%key == e_gun$) phase_lag = 0  !used to be pi/2
    call value_to_line (line, phase_lag, 'lag', rfmt, 'R')
 
    ! Write ELEMEDGE
    call value_to_line (line, ele%s - val(L$), 'elemedge', rfmt, 'R', ignore_if_zero = .false.)
      

  !----------------------------------------------------------
  ! Default -----------------------------------
  !----------------------------------------------------------
     case default
        call out_io (s_error$, r_name, 'UNKNOWN ELEMENT TYPE: ' // key_name(ele%key), &
             'CONVERTING TO DRIFT')
        write (line, '(a, es13.5)') trim(ele%name) // ': drift, l =', val(l$)
        ! Write ELEMEDGE
        call value_to_line (line, ele%s - val(L$), 'elemedge', rfmt, 'R',ignore_if_zero = .false.)
  end select
  
  ! type (general attribute)
  ! if (ele%type /= '') write (line, '(4a)') trim(line), ', type = "', trim(ele%type), '"'
  
  ! end line
  write (line, '(2a)') trim(line), trim(eol_char)

  ! call write_opal_field_map()

  !----------------------------------------------------------
  !----------------------------------------------------------


  ! Finally write out line
  call write_lat_line (line, iu, .true., continue_char = continue_char )  
enddo ele_loop


! Write lattice line
write (iu, *)
line = 'lattice: line = ('

lat_loop: do ie = ix_start, ix_end
  ele => lat%ele(ie)
  ! Skip these elements:
  if (ele%slave_status == super_slave$ .or. &
      ele%slave_status == multipass_slave$ .or. &
      ele%key == girder$ .or. &
      ele%key == overlay$ .or. &
      ele%key == group$) cycle
      
  write (line, '(4a)') trim(line), ' ', trim(ele%name), ','
  if (len_trim(line) > 80) call write_lat_line(line, iu, .false., continue_char = continue_char)
enddo lat_loop    
! write closing parenthesis
line = line(:len_trim(line)-1) // ')' // eol_char
call write_lat_line (line, iu, .true., continue_char = continue_char)



! Cleanup
deallocate ( ele_names%names ) 
deallocate ( ele_names%indexx )
deallocate ( ele_name_occurrences )

deallocate ( fieldgrid_names%names ) 
deallocate ( fieldgrid_names%indexx )

if (present(err)) err = .false.

end subroutine write_opal_lattice_file

!------------------------------------------------------------------------
!------------------------------------------------------------------------
!------------------------------------------------------------------------
!+ 
! Subroutine  get_opal_fieldgrid_name_and_scaling(&
!               ele, param, name_indexx, output_name, field_scale)
!
! Subroutine to get a field grid filename and its scaling. Calls write_opal_field_grid_file.
!   If the field grid file does not exist, it is written 
!
!
! Input:
!   ele              -- ele_struct: element to make map
!   param            -- lat_param_struct: Contains lattice information
!   name_indexx      -- char_indexx_struct: contains field grid filenames
!
! Output:   
!   name_indexx      -- char_indexx_struct: updated if new name is added
!   output_name      -- Real(rp): output filename. 
!   field_scale      -- Real(rp): the scaling of the field grid
!
!-


subroutine get_opal_fieldgrid_name_and_scaling(&
             ele, param, name_indexx, output_name, field_scale)
                                          
implicit none

type (ele_struct) :: ele
type (lat_param_struct) :: param
type (char_indexx_struct) :: name_indexx
character(*)  :: output_name
real(rp)      :: field_scale

integer :: ix_match, iu_fieldgrid, ios

!

output_name = ''

! Check field map file. If file has not been written, create a new file. 
call find_indexx (ele%em_field%mode(1)%grid%file, name_indexx, ix_match)
! Check for match with existing grid
if (ix_match > 0) then
  ! File should exist  
  write(output_name, '(a, i0, a)') 'fieldgrid_', ix_match, '.t7'
  ! Call with iu=0 to get field_scale
  call write_opal_field_grid_file (0, ele, param, field_scale)
else
  ! File does not exist.
  ! Add name to list  
  call find_indexx (ele%em_field%mode(1)%grid%file, name_indexx, ix_match, add_to_list = .true.)
  ix_match = name_indexx%n_max
  write(output_name, '(a, i0, a)') 'fieldgrid_', ix_match, '.t7'
  ! Write new fieldgrid file
  iu_fieldgrid = lunget()
  open (iu_fieldgrid, file = output_name, iostat = ios)
    call write_opal_field_grid_file (iu_fieldgrid, ele, param, field_scale)
  close(iu_fieldgrid)
end if

end subroutine get_opal_fieldgrid_name_and_scaling

!------------------------------------------------------------------------
!------------------------------------------------------------------------
!------------------------------------------------------------------------
!+ 
! Subroutine write_opal_field_grid_file (opal_file_unit, ele, param, maxfield, err)
!
! Subroutine to write an OPAL lattice file using the information in
! a lat_struct. Optionally only part of the lattice can be generated.
!
!
! Input:
!   opal_file_unit -- Integer: unit number to write to, if > 0
!                        if < 0, nothing is written, and only maxfield is returned
!   ele            -- ele_struct: element to make map
!   param          -- lat_param_struct: Contains lattice information
!
! Output:          
!   maxfield       -- Real(rp): absolute maximum found for element field scaling
!   err            -- Logical, optional: Set True if, say a file could not be opened.
!-

subroutine write_opal_field_grid_file (opal_file_unit, ele, param, maxfield, err)

implicit none

integer      :: opal_file_unit
integer         :: dimensions
type (ele_struct) :: ele
type (lat_param_struct) :: param
real(rp)        :: maxfield
logical, optional :: err

character(40)  :: r_name = 'write_opal_field_grid_file'
character(10)   ::  rfmt 


type (coord_struct) :: orb
type(em_field_struct) :: field_re, field_im
type (em_field_grid_pt_struct), allocatable :: pt(:,:,:)
type (em_field_grid_pt_struct) :: ref_field
real(rp) :: x_step, z_step, x_min, x_max, z_min, z_max
real(rp) :: freq, x, z, phase_ref
real(rp) :: gap, edge_range
complex ::  phasor_rotation

integer :: nx, nz, iz, ix

real(rp) :: Ex_factor, Ez_factor, Bx_factor, By_factor, Bz_factor

logical loc_ref_frame

!
if (present(err)) err = .true.


loc_ref_frame = .true. 

! Format for numbers
  rfmt = 'es13.5'


! TODO: pass these parameters in somehow
x_step = 0.001_rp
z_step = 0.001_rp

x_min = 0.0_rp
x_max = 0.02_rp

z_min = 0.0_rp
z_max = ele%value(L$)

nx = ceiling(x_max/x_step)  
nz = ceiling(z_max/z_step)

  
select case (ele%key)

!-----------
! LCavity, RFCavity, E_GUN
!-----------
case (lcavity$, rfcavity$, e_gun$) 

  freq = ele%value(rf_frequency$) * ele%em_field%mode(1)%harmonic
  ! if (freq .eq. 0) freq = 1e-30_rp ! To prevent divide by zero

  ! Example:
  !2DDynamic XZ
  !0.  100.955  743   #zmin(cm),  zmax(cm).   nz - 1
  !1300.              #freq (MHz)
  !-0.10158700000000001  4.793651666666666  11    # rmin(cm),  rmax(cm),   nr-1
  !
  !-547.601  -9.64135  0  -20287.798905810083   ! Ez(t0), Er(t0), dummy->0.0, -10^6 / mu_0 * B_phi (t + 1/4 1/f) 

  ! Allocate temporary pt array
  allocate ( pt(0:nx, 0:nz, 1:1) )
  ! Write data points
  
  ! initialize maximum found field
  maxfield = 0
  
  do ix = 0, nx
    do iz = 0, nz
      x = x_step * ix
      z = z_step * iz 
      orb%vec(1) = x
      orb%vec(3) = 0.0_rp
      
      ! Calculate field at \omegat*t=0 and \omega*t = \pi/2 to get real and imaginary parts
      call em_field_calc (ele, param, z, 0.0_rp,     orb, loc_ref_frame, field_re)
      ! if frequency is zero, zero out field_im
      if(freq == 0) then
        field_im%E=0
        field_im%B=0
      else 
        call em_field_calc (ele, param, z, 0.25/freq , orb, loc_ref_frame, field_im)
      endif

      pt(ix, iz, 1)%E(:) = cmplx(field_re%E(:), field_im%E(:), rp)
      pt(ix, iz, 1)%B(:) = cmplx(field_re%B(:), field_im%B(:), rp)
      
      ! Update ref_field if larger Ez is found
      ! TODO: Opal may use Ex as well for scaling. Check this. 
      if(abs(pt(ix, iz, 1)%E(3)) > maxfield) then
         ref_field = pt(ix, iz, 1)
         maxfield = abs(ref_field%E(3))
      end if 
    end do
  end do
  
  ! Write to file
  if (opal_file_unit > 0 )  then

    ! Write header
    write (opal_file_unit, '(3a)') ' 2DDynamic XZ', '  # Created from ele: ', trim(ele%name)
    write (opal_file_unit, '(2'//rfmt//', i8, a)') 100*z_min, 100*nz*z_step, nz, '  # z_min (cm), z_max (cm), n_z_points -1'
    write (opal_file_unit, '('//rfmt//', a)') 1d-6 * freq, '  # frequency (MHz)'
    write (opal_file_unit, '(2'//rfmt//', i8, a)') 100*x_min, 100*nx*x_step, nx, '  # x_min (cm), x_max (cm), n_x_points -1'

    ! Scaling for T7 format
    Ex_factor = (1/maxfield)
    Ez_factor = (1/maxfield)
    By_factor = -(1/maxfield)*1e6_rp / ( fourpi * 1e-7)

  
    ! Calculate complex rotation number to rotate Ez onto the real axis
    phase_ref = atan2( aimag(ref_field%E(3) ), real(ref_field%E(3) ) )
    phasor_rotation = cmplx(cos(phase_ref), -sin(phase_ref), rp)
  
    do ix = 0, nx
      do iz = 0, nz
      
        write (opal_file_unit, '(4'//rfmt//')') Ez_factor * real ( pt(ix, iz, 1)%E(3) * phasor_rotation ), &
                                                Ex_factor * real ( pt(ix, iz, 1)%E(1) * phasor_rotation ), &
                                                0.0_rp, &
                                                By_factor * aimag (  pt(ix, iz, 1)%B(2)*phasor_rotation )
      enddo
    enddo
  
  end if
   
   
   deallocate(pt)

  !-----------
  ! Solenoid
  !-----------
  ! Note: This is similar to code for lcavity/rfcavity
  case (solenoid$) 
                                         
  ! Example:
  !2DMagnetoStatic ZX
  !0.0 2.0 199  # rmin(cm),  rmax(cm),   nr-1
  !-3.0 51.0 4999 #zmin(cm),  zmax(cm).   nz - 1
  !0.00000d+00 0.00000d+00    ! B_r, B_z 

  ! Allocate temporary pt array
  allocate ( pt(0:nx, 0:nz, 1:1) )
  ! Write data points
  
  ! initialize maximum found field
  maxfield = 0
  
  do ix = 0, nx
    do iz = 0, nz
      x = x_step * ix
      z = z_step * iz 
      orb%vec(1) = x
      orb%vec(3) = 0.0_rp

      call em_field_calc (ele, param, z, 0.0_rp, orb, loc_ref_frame, field_re)
      field_im%E = 0
      field_im%B = 0

      pt(ix, iz, 1)%E(:) = cmplx(field_re%E(:), field_im%E(:), rp)
      pt(ix, iz, 1)%B(:) = cmplx(field_re%B(:), field_im%B(:), rp)
      
      ! Update ref_field if larger Bz is found
      ! OPAL normalizes the map to the maximum Bz
      if(abs(pt(ix, iz, 1)%B(3)) > maxfield) then
         ref_field = pt(ix, iz, 1)
         maxfield = abs(ref_field%B(3))
      end if 


    end do
  end do
  
  ! Restore the sign
  maxfield = ref_field%B(3)
  
  ! Write to file
  if (opal_file_unit > 0 )  then

    ! Write header
    write (opal_file_unit, '(3a)') ' 2DMagnetoStatic XZ', '  # Created from ele: ', trim(ele%name)
    write (opal_file_unit, '(2'//rfmt//', i8, a)') 100*z_min, 100*nz*z_step, nz, '  # z_min (cm), z_max (cm), n_z_points -1'
    write (opal_file_unit, '(2'//rfmt//', i8, a)') 100*x_min, 100*nx*x_step, nx, '  # x_min (cm), x_max (cm), n_x_points -1'

    ! Scaling for T7 format
   Bx_factor = 1
   Bz_factor = 1
    
    ! XZ ordering: ix changes fastest (inner loop)
    do ix = 0, nx
      do iz = 0, nz
        write (opal_file_unit, '(2'//rfmt//')') , &
          Bz_factor * real (  pt(ix, iz, 1)%B(3) ), &
          Bx_factor * real (  pt(ix, iz, 1)%B(1) )            
      enddo
    enddo
  
  end if

  ! cleanup 
   deallocate(pt)


  !-----------
  ! SBend
  !-----------
  case (sbend$)
  
  ! Example:
  !1DProfile1 1 2 3.0   #Enge coefficient type map, entrance order, exit order, full gap (cm)
  ! -6.0  2.0  2.0 1000 #entrance positions, relative to elemedge: enge start(cm), enge origin (cm), enge end (cm), unused number
  ! 24.0 28.0 32.0 0    #exit     positions, relative to elemedge: enge start(cm), enge origin (cm), enge end (cm), unused number
  ! 0.0   #coefficient 1 for entrance
  ! 1d-6  #coefficient 1 for exit
  ! 2d-6  #coefficient 2 for exit

  ! We will use just one Enge coefficent, equivalent using a field integral FINT and half gap HGAP (see the Bmad manual)
  ! F_bmad(z) = (1 + exp (c0 + c1 z + ...) )^-1
  ! F_opal(z) = (1 + exp(d0 + d1 z/(2H) + ... ) )^-1
  ! c0 and d0 just shift the map, use c0=0, d0=0
  ! c1(bmad) = 1/(2*HGAP*FINT)
  ! => d1(opal) = 1/FINT

  gap = 2*ele%value(HGAP$)
  edge_range = 10*gap*ele%value(FINT$)
  ! maxfield isn't used for this type of map
  maxfield = -1.0_rp

  ! Write to file
  if (opal_file_unit > 0 )  then
    ! Write header
    write (opal_file_unit, '(a,'//rfmt//', 2a )' ) '1DProfile1 1 1 ', 100*gap, '  # Created from ele: ', trim(ele%name)
    write (opal_file_unit, '(3'//rfmt//', i8, a)') -100*edge_range, 0.0_rp, 100*edge_range, 666,  &
          ' #entrance: edge start(cm), edge center(cm), edge end(cm), unusued'
    write (opal_file_unit, '(3'//rfmt//', i8, a)') 100*(ele%value(L_CHORD$) - edge_range) , 100*ele%value(L_CHORD$), 100*(ele%value(L_CHORD$) + edge_range), 666,  &
          ' #exit:     edge start(cm), edge center(cm), edge end(cm), unusued'
    ! Entrance coefficients
    write (opal_file_unit, '('//rfmt//')')  0.0_rp   
    write (opal_file_unit, '('//rfmt//')') 1/ele%value(FINT$)
    ! Exit coefficients
    write (opal_file_unit, '('//rfmt//')')  0.0_rp
    write (opal_file_unit, '('//rfmt//')')  1/ele%value(FINT$)
  end if


  !-----------
  ! Default (gives an error)
  !-----------
  case default
  call out_io (s_error$, r_name, 'MISSING OPAL FIELD GRID CODE FOR: ' // key_name(ele%key), &
             '----')
  if (global_com%exit_on_error) call err_exit
  
  
  
end select 

if (maxfield == 0) then
  call out_io (s_error$, r_name, 'ZERO MAXIMUM FIELD IN ELEMENT: ' // key_name(ele%key), &
             '----')
  if (global_com%exit_on_error) call err_exit
end if



end subroutine write_opal_field_grid_file


!------------------------------------------------------------------------
!------------------------------------------------------------------------
!------------------------------------------------------------------------
!+ 
! Subroutine write_opal_particle_distribution  (opal_file_unit, bunch,  mc2, err)
!
! Subroutine to write an OPAL bunch from a standard Bmad bunch
! 
! Note: The OPAL file format is
!       n_particles
!       x  \beta_x*\gamma  y \beta_y*\gamma z \beta_z*\gamma
!       . . .
!       all at the same time. All particles represent the same amount of charge
!   
!
! Input:
!   opal_file_unit -- Integer: unit number to write to, if > 0
!   bunch          -- bunch_struct: bunch to be written.
!                            Particles are drifted to bmad_bunch%t_center for output
!   mc2            -- real(rp): particle mass in eV
!
! Output:          
!   err            -- Logical, optional: Set True if, say a file could not be opened.
!-

subroutine write_opal_particle_distribution (opal_file_unit, bunch, mc2, err)

implicit none

integer          :: opal_file_unit
type (bunch_struct) :: bunch
real(rp)            :: mc2
logical, optional   :: err

type (coord_struct) :: orb
real(rp)       :: dt, pc, gmc, gammabeta(3)
character(40)  :: r_name = 'write_opal_particle_distribution'
character(10)   ::  rfmt 
integer n_particle, i


!
if (present(err)) err = .true.

! TODO: Check that weights are all the same

n_particle = size(bunch%particle)

! Format for numbers
  rfmt = 'es13.5'

! Write number of particles to first line
write(opal_file_unit, '(i8)') n_particle

!\gamma m c

! Write out all particles to file
do i = 1, n_particle
  orb = bunch%particle(i)
  
  ! Get time to track backwards by
  dt = orb%t - bunch%t_center
  
  ! Get pc before conversion
  pc = (1+orb%vec(6))*orb%p0c

  ! convert to time coordinates
  call convert_particle_coordinates_s_to_t (orb)
  
  ! get \gamma m c
  gmc = sqrt(pc**2 + mc2**2) / c_light
  
  gammabeta =  orb%vec(2:6:2) / mc2
  
  ! OPAL has a problem with zero beta_z
  if ( gammabeta(3) == 0 ) gammabeta(3) = 1d-30
  
  !'track' particles backwards in time and write to file
  write(opal_file_unit, '(6'//rfmt//')') orb%vec(1) - dt*orb%vec(2)/gmc, &   ! x - dt mc2 \beta_x \gamma / \gamma m c
                                         gammabeta(1), &
                                         orb%vec(3) - dt*orb%vec(4)/gmc, &   ! y - dt mc2 \beta_y \gamma / \gamma m c
                                         gammabeta(2),  &
                                         orb%vec(5) - dt*orb%vec(6)/gmc, &   ! s - dt mc2 \beta_s \gamma / \gamma m c
                                         gammabeta(3) 
end do 

end subroutine  write_opal_particle_distribution

end module
