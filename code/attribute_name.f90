!+
! Function attribute_name (ele, ix_att)
!
! Function to return the name of an attribute for a particular type of 
! BMAD element. 
!
! Modules Needed:
!   use bmad
!
! Input:
!   ele    -- Ele_struct: Integer: Key name of element type (e.g. SBEND$, etc.)
!   ix_att -- Integer: Index of attribute (e.g. k1$)
!
! Output:
!   attribute_name -- Character*16: Name of attribute.
!
! Example:
!   ele%key = sbend$
!   name = attribute_name (ele, K1$)
! Result:
!   name -> 'k1'
!-

!$Id$
!$Log$
!Revision 1.5  2002/06/13 14:54:21  dcs
!Interfaced with FPP/PTC
!
!Revision 1.4  2002/02/23 20:32:10  dcs
!Double/Single Real toggle added
!
!Revision 1.3  2002/01/08 21:44:36  dcs
!Aligned with VMS version  -- DCS
!
!Revision 1.2  2001/09/27 18:31:47  rwh24
!UNIX compatibility updates
!

#include "CESR_platform.inc"

character*16 function attribute_name (ele, ix_att) result (at_name)

  use bmad

  implicit none

  type (ele_struct) ele

  integer i, j, key, ix_att

  character*16 attrib_array(n_key, n_attrib_special_maxx)

  logical init_needed / .true. /

!---------------------------------------------------------------------
! Init

  if (init_needed) then

    attrib_array = null_name

    do i = 1, n_key
                                    
      if (i == def_beam$) cycle

      attrib_array(i, type$)     = 'TYPE'
      attrib_array(i, alias$)    = 'ALIAS'
      attrib_array(i, descrip$)  = 'DESCRIP'

      if (i == group$)         cycle
      if (i == overlay$)       cycle

      attrib_array(i, x_limit$)  = 'X_LIMIT'
      attrib_array(i, y_limit$)  = 'Y_LIMIT'
      attrib_array(i, aperture$) = 'APERTURE'

      attrib_array(i, hkick$)  = 'HKICK'
      attrib_array(i, vkick$)  = 'VKICK'

      if (i == marker$) cycle

      attrib_array(i, x_offset$) = 'X_OFFSET'
      attrib_array(i, y_offset$) = 'Y_OFFSET'
      attrib_array(i, s_offset$) = 'S_OFFSET'
      attrib_array(i, energy$) = 'ENERGY'

      attrib_array(i, mat6_calc_method$)  = 'MAT6_CALC_METHOD'
      attrib_array(i, tracking_method$)   = 'TRACKING_METHOD'
      attrib_array(i, integration_order$) = 'INTEGRATION_ORDER'
      attrib_array(i, num_steps$)         = 'NUM_STEPS'
      attrib_array(i, symplectify$)       = 'SYMPLECTIFY'
      attrib_array(i, ptc_kind$)          = 'PTC_KIND'
      
      if (i == multipole$ .or. i == ab_multipole$) cycle

      attrib_array(i, x_pitch$)   = 'X_PITCH'
      attrib_array(i, y_pitch$)   = 'Y_PITCH'

      attrib_array(i, rel_tol$) = 'REL_TOL'
      attrib_array(i, abs_tol$) = 'ABS_TOL'

    enddo

!

    do i = 1, n_key
      select case (i)
      case (elseparator$, kicker$, octupole$, quadrupole$, sbend$, rbend$, &
             sextupole$, solenoid$, sol_quad$, ab_multipole$, wiggler$)
        attrib_array(i, a$)      = 'A'
        attrib_array(i, b$)      = 'B'
        attrib_array(i, radius$) = 'RADIUS'
      end select

    enddo


    attrib_array(group$, command$)        = 'COMMAND'
    attrib_array(group$, old_command$)    = 'OLD_COMMAND'
    attrib_array(group$, coef$)           = 'COEF'
    attrib_array(group$, start_edge$)     = 'START_EDGE'
    attrib_array(group$, end_edge$)       = 'END_EDGE'
    attrib_array(group$, accordion_edge$) = 'ACCORDION_EDGE'

    attrib_array(drift$, l$) = 'L'

    attrib_array(sbend$, l$)          = 'L'
    attrib_array(sbend$, angle$)      = 'ANGLE'
    attrib_array(sbend$, e1$)         = 'E1'
    attrib_array(sbend$, e2$)         = 'E2'
    attrib_array(sbend$, k1$)         = 'K1'
    attrib_array(sbend$, g$)          = 'G'
    attrib_array(sbend$, g_design$)   = 'G_DESIGN'
    attrib_array(sbend$, tilt$)       = 'TILT'
    attrib_array(sbend$, roll$)       = 'ROLL'
    attrib_array(sbend$, hgap$)       = 'HGAP'
    attrib_array(sbend$, hgapx$)      = 'HGAPX'
    attrib_array(sbend$, fint$)       = 'FINT'
    attrib_array(sbend$, fintx$)      = 'FINTX'
    attrib_array(sbend$, rho_bend$)   = 'RHO_BEND'

    attrib_array(rbend$, l$)          = 'L'
    attrib_array(rbend$, angle$)      = 'ANGLE'
    attrib_array(rbend$, e1$)         = 'E1'
    attrib_array(rbend$, e2$)         = 'E2'
    attrib_array(rbend$, k1$)         = 'K1'
    attrib_array(rbend$, g$)          = 'G'
    attrib_array(rbend$, g_design$)   = 'G_DESIGN'
    attrib_array(rbend$, tilt$)       = 'TILT'
    attrib_array(rbend$, roll$)       = 'ROLL'
    attrib_array(rbend$, hgap$)       = 'HGAP'
    attrib_array(rbend$, hgapx$)      = 'HGAPX'
    attrib_array(rbend$, fint$)       = 'FINT'
    attrib_array(rbend$, fintx$)      = 'FINTX'
    attrib_array(rbend$, rho_bend$)   = 'RHO_BEND'

    attrib_array(quadrupole$, l$)    = 'L'
    attrib_array(quadrupole$, tilt$) = 'TILT'
    attrib_array(quadrupole$, k1$)   = 'K1'

    attrib_array(sextupole$, l$)     = 'L'
    attrib_array(sextupole$, tilt$)  = 'TILT'
    attrib_array(sextupole$, k2$)    = 'K2'

    attrib_array(octupole$, l$)      = 'L'
    attrib_array(octupole$, tilt$)   = 'TILT'
    attrib_array(octupole$, k3$)     = 'K3'

    attrib_array(solenoid$, l$)      = 'L'
    attrib_array(solenoid$, ks$)     = 'KS'

    attrib_array(rfcavity$, l$)             = 'L'
    attrib_array(rfcavity$, volt$)          = 'VOLT'
    attrib_array(rfcavity$, rf_wavelength$) = 'RF_WAVELENGTH'
    attrib_array(rfcavity$, lag$)           = 'LAG'
    attrib_array(rfcavity$, harmon$)        = 'HARMON'

    attrib_array(elseparator$, l$)      = 'L'
    attrib_array(elseparator$, gap$)    = 'GAP'

    attrib_array(beambeam$, sig_x$)      = 'SIG_X'
    attrib_array(beambeam$, sig_y$)      = 'SIG_Y'
    attrib_array(beambeam$, sig_z$)      = 'SIG_Z'
    attrib_array(beambeam$, bbi_const$)  = 'BBI_CONSTANT'
    attrib_array(beambeam$, charge$)     = 'CHARGE'
    attrib_array(beambeam$, n_slice$)    = 'N_SLICE'

    attrib_array(wiggler$, l$)        = 'L'
    attrib_array(wiggler$, k1$)       = 'K1'
    attrib_array(wiggler$, b_max$)    = 'B_MAX'
    attrib_array(wiggler$, rho_bend$) = 'RHO_BEND'
    attrib_array(wiggler$, n_pole$)   = 'N_POLE'
    attrib_array(wiggler$, tilt$)     = 'TILT'
    attrib_array(wiggler$, radius$)   = 'RADIUS'
    attrib_array(wiggler$, term$)     = 'TERM'
    attrib_array(wiggler$, polarity$) = 'POLARITY'

    attrib_array(sol_quad$, l$)    = 'L'
    attrib_array(sol_quad$, k1$)   = 'K1'
    attrib_array(sol_quad$, ks$)   = 'KS'
    attrib_array(sol_quad$, tilt$) = 'TILT'

    attrib_array(kicker$, l$)           = 'L'
    attrib_array(kicker$, h_displace$)  = 'H_DISPLACE'
    attrib_array(kicker$, v_displace$)  = 'V_DISPLACE'

    attrib_array(def_beam$, particle$)  = 'PARTICLE'
    attrib_array(def_beam$, energy$)    = 'ENERGY'
    attrib_array(def_beam$, n_part$)    = 'N_PART'

    attrib_array(multipole$, tilt$)     = 'TILT'
    attrib_array(multipole$, kl$  )     = 'KL'
    attrib_array(multipole$, t$)        = 'T'
    attrib_array(multipole$, radius$)   = 'RADIUS'

    attrib_array(ab_multipole$, tilt$)  = 'TILT'

    attrib_array(accel_sol$, l$)             = 'L'
    attrib_array(accel_sol$, volt$)          = 'VOLT'
    attrib_array(accel_sol$, lag$)           = 'LAG'
    attrib_array(accel_sol$, rf_wavelength$) = 'RF_WAVELENGTH'
    attrib_array(accel_sol$, b_z$)           = 'B_Z'
    attrib_array(accel_sol$, b_x1$)          = 'B_X1'
    attrib_array(accel_sol$, b_y1$)          = 'B_Y1'
    attrib_array(accel_sol$, s_st1$)         = 'S_ST1'
    attrib_array(accel_sol$, l_st1$)         = 'L_ST1'
    attrib_array(accel_sol$, b_x2$)          = 'B_X2'
    attrib_array(accel_sol$, b_y2$)          = 'B_Y2'
    attrib_array(accel_sol$, s_st2$)         = 'S_ST2'
    attrib_array(accel_sol$, l_st2$)         = 'L_ST2'
    attrib_array(accel_sol$, x_beg_limit$)   = 'X_BEG_LIMIT'
    attrib_array(accel_sol$, y_beg_limit$)   = 'Y_BEG_LIMIT'

    attrib_array(custom$, l$)     = 'L'
    attrib_array(custom$,  val1$) =  'VAL1'
    attrib_array(custom$,  val2$) =  'VAL2'
    attrib_array(custom$,  val3$) =  'VAL3'
    attrib_array(custom$,  val4$) =  'VAL4'
    attrib_array(custom$,  val5$) =  'VAL5'
    attrib_array(custom$,  val6$) =  'VAL6'
    attrib_array(custom$,  val7$) =  'VAL7'
    attrib_array(custom$,  val8$) =  'VAL8'
    attrib_array(custom$,  val9$) =  'VAL9'
    attrib_array(custom$, val10$) = 'VAL10'
    attrib_array(custom$, val11$) = 'VAL11'
    attrib_array(custom$, val12$) = 'VAL12'

    init_needed = .false.

  endif

!--------------------------------------------------------------------
! Main part of subroutine

  key = ele%key

  if (key <= 0 .or. key > n_key .or.  &
            ix_att <= 0 .or. ix_att > n_attrib_special_maxx) then
    at_name = '?? BAD KEY/INDEX'
  else
    at_name = attrib_array(key, ix_att)
  endif                       

  if (key == wiggler$ .and. ele%sub_key == map_type$) then
    if (any (ix_att == (/ k1$, b_max$, rho_bend$, n_pole$, radius$ /) )) &
                                                    at_name = null_name
  endif

end function




