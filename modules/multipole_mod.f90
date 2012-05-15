module multipole_mod

use bmad_struct
use matrix_mod
use bmad_utils_mod

contains

!------------------------------------------------------------------------
!------------------------------------------------------------------------
!------------------------------------------------------------------------
!+
! Subroutine multipole_init (ele, zero)
!
! Subroutine to allocate memory for the the ele%a_pole and ele%b_pole multipole 
! vectors.
!
! Modules needed:
!   use bmad
!
! Input:
!   zero -- Logical, optional: If present and True then zero the arrays
!             even if they already exist when this routine is called. 
!             Default is False which means that if the arrays already 
!             exist then this routine will do nothing.
!
! Output:
!   ele -- Ele_struct: Element holding the multipoles.
!     %a_pole(0:n_pole_maxx) -- Multipole An array 
!     %b_pole(0:n_pole_maxx) -- Multipole Bn array
!-

subroutine multipole_init (ele, zero)

implicit none

type (ele_struct) ele
logical, optional :: zero

! If %a_pole and %b_pole already exist then zero them if zero argument present 
! and True.

if (associated (ele%a_pole)) then
  if (logic_option(.false., zero)) then
    ele%a_pole = 0
    ele%b_pole = 0
  endif

! If memory not allocated then allocate and zero.

else
  allocate (ele%a_pole(0:n_pole_maxx), ele%b_pole(0:n_pole_maxx))
  ele%a_pole = 0
  ele%b_pole = 0
endif

end subroutine multipole_init

!------------------------------------------------------------------------
!------------------------------------------------------------------------
!------------------------------------------------------------------------
!+
! Subroutine multipole_ab_to_kt (an, bn, knl, tn)
!
! Subroutine to convert ab type multipoles to kt (MAD standard) multipoles.
!
! Modules needed:
!   use bmad
!
! Input:
!   an(0:n_pole_maxx) -- Real(rp): Skew multipole component.
!   bn(0:n_pole_maxx) -- Real(rp): Normal multipole component.
!
! Output:
!   knl(0:n_pole_maxx) -- Real(rp): Multitude magnatude.
!   tn(0:n_pole_maxx)  -- Real(rp): Multipole angle.
!-

subroutine multipole_ab_to_kt (an, bn, knl, tn)

implicit none

real(rp) an(0:), bn(0:)
real(rp) knl(0:), tn(0:)
real(rp) n_fact, a, b

integer n

! use a, b as temp values to avoid problems with a call like:
!   call multipole_ab_to_kt (vec1, vec2, vec1, vec2)

n_fact = 1

do n = 0, n_pole_maxx

  if (n /= 0) n_fact = n_fact * n

  a = an(n)
  b = bn(n)

  if (a == 0 .and. b == 0) then
    knl(n) = 0
    tn(n) = 0
  else
    knl(n)  = n_fact * sqrt(a**2 + b**2)
    tn(n) = -atan2(a, b) / (n + 1)
  endif

enddo

end subroutine multipole_ab_to_kt

!------------------------------------------------------------------------
!------------------------------------------------------------------------
!------------------------------------------------------------------------
!+
! Subroutine multipole_ele_to_kt (ele, particle, use_ele_tilt, has_nonzero_pole, knl, tilt)
!
! Subroutine to put the multipole components (strength and tilt)
! into 2 vectors along with the appropriate scaling.
! Note: tilt(:) does includes ele%value(tilt_tot$).
!
! Modules needed:
!   use bmad
!
! Input:
!   ele          -- Ele_struct: Multipole element.
!   particle     -- Integer: Particle species (+1 or -1).
!   use_ele_tilt -- Logical: If True then include ele%value(tilt_tot$) in calculations. 
!                     use_ele_tilt is ignored in the case of multipole$ elements.
!
! Output:
!   has_nonzero_pole    -- Logical: Set True if there is a nonzero pole. False otherwise.
!   knl(0:n_pole_maxx)  -- Real(rp): Vector of strengths, MAD units.
!   tilt(0:n_pole_maxx) -- Real(rp): Vector of tilts.
!-

subroutine multipole_ele_to_kt (ele, particle, use_ele_tilt, has_nonzero_pole, knl, tilt)

implicit none

type (ele_struct), target :: ele
type (ele_struct), pointer :: lord

real(rp) knl(0:), tilt(0:), a(0:n_pole_maxx), b(0:n_pole_maxx)
real(rp) this_a(0:n_pole_maxx), this_b(0:n_pole_maxx)
real(rp) tilt1

integer i, particle

logical use_ele_tilt, has_nonzero_pole
logical has_nonzero

! Init

has_nonzero_pole = .false.

! Multipole case. Note: use_ele_tilt arg is ignored here.
! Also multipoles cannot be slaves.

if (ele%key == multipole$) then
  knl  = ele%a_pole
  tilt = ele%b_pole + ele%value(tilt_tot$)
  if (any(knl /= 0)) has_nonzero_pole = .true.
  return
endif

! All other cases.
! Slice slaves and super slaves have their associated multipoles stored in the lord

if (ele%slave_status == slice_slave$ .or. ele%slave_status == super_slave$) then
  a = 0
  b = 0
  do i = 1, ele%n_lord
    lord => pointer_to_lord(ele, i)
    call multipole_ele_to_ab (lord, particle, use_ele_tilt, has_nonzero, this_a, this_b)
    if (.not. has_nonzero) cycle
    has_nonzero_pole = .true.
    a = a + this_a * (ele%value(l$) / lord%value(l$))
    b = b + this_b * (ele%value(l$) / lord%value(l$))
  enddo
else
  call multipole_ele_to_ab (ele, particle, use_ele_tilt, has_nonzero_pole, a, b)
endif

if (has_nonzero_pole) then
  call multipole_ab_to_kt (a, b, knl, tilt)
else
  knl = 0
  tilt = 0
endif

end subroutine multipole_ele_to_kt

!------------------------------------------------------------------------
!------------------------------------------------------------------------
!------------------------------------------------------------------------
!+
! Subroutine multipole_kt_to_ab (knl, tn, an, bn)
!
! Subroutine to convert kt (MAD standard) multipoles to ab type multipoles.
!
! Modules needed:
!   use bmad
!
! Input:
!   knl(0:) -- Real(rp): Multitude magnatude.
!   tn(0:)  -- Real(rp): Multipole angle.
!
! Output:
!   an(0:) -- Real(rp): Skew multipole component.
!   bn(0:) -- Real(rp): Normal multipole component.
!-

subroutine multipole_kt_to_ab (knl, tn, an, bn)

implicit none

real(rp) an(0:), bn(0:)
real(rp) knl(0:), tn(0:)
real(rp) n_fact, angle, kl

integer n

!

n_fact = 1

do n = lbound(an, 1), ubound(an, 1)

  if (n /= 0) n_fact = n_fact * n

  kl = knl(n) / n_fact

  if (kl == 0) then
    an(n) = 0
    bn(n) = 0
  else
    angle = -tn(n) * (n + 1)
    an(n) = kl * sin(angle)
    bn(n) = kl * cos(angle)
  endif

enddo

end subroutine multipole_kt_to_ab

!------------------------------------------------------------------------
!------------------------------------------------------------------------
!------------------------------------------------------------------------
!+
! Subroutine multipole_ele_to_ab (ele, particle, use_ele_tilt, has_nonzero_pole, a, b)
!                             
! Subroutine to extract the ab multipole values of an element.
! Note: The ab values will be scalled by the strength of the element.
!
! Modules needed:
!   use bmad
!
! Input:
!   ele          -- Ele_struct: Element.
!     %value()     -- ab_multipole values.
!   particle     -- Integer: Particle species (positron$, etc.).
!                     To be used with electrostatic elements.
!   use_ele_tilt -- Logical: If True then include ele%value(tilt_tot$) in calculations.
!                     use_ele_tilt is ignored in the case of multipole$ elements.
!
! Output:
!   has_nonzero_pole -- Logical: Set True if there is a nonzero pole. False otherwise.
!   a(0:n_pole_maxx) -- Real(rp): Array of scalled multipole values.
!   b(0:n_pole_maxx) -- Real(rp): Array of scalled multipole values.
!-

subroutine multipole_ele_to_ab (ele, particle, use_ele_tilt, has_nonzero_pole, a, b)

implicit none

type (ele_struct), target :: ele
type (ele_struct), pointer :: lord

real(rp) const, radius, factor, a(0:), b(0:)
real(rp) an, bn, cos_t, sin_t
real(rp) this_a(0:n_pole_maxx), this_b(0:n_pole_maxx)

integer i, ref_exp, n, particle

logical use_ele_tilt, has_nonzero_pole

character(24), parameter :: r_name = 'multipole_ele_to_ab'

! Init

a = 0
b = 0
has_nonzero_pole = .false.

! Multipole type element case. Note: use_ele_tilt is ignored in this case.

if (ele%key == multipole$) then
  if (any(ele%a_pole /= 0)) return
  has_nonzero_pole = .true.
  call multipole_kt_to_ab (ele%a_pole, ele%b_pole, a, b)
  return
endif

! All other cases
! Slice slaves and super slaves have their associated multipoles stored in the lord

if (ele%slave_status == slice_slave$ .or. ele%slave_status == super_slave$) then
  do i = 1, ele%n_lord
    lord => pointer_to_lord(ele, i)
    call convert_this_ab (lord, this_a, this_b)
    a = a + this_a * (ele%value(l$) / lord%value(l$))
    b = b + this_b * (ele%value(l$) / lord%value(l$))
  enddo
else
  call convert_this_ab (ele, a, b)
endif

!---------------------------------------------
contains

subroutine convert_this_ab (this_ele, this_a, this_b)

type (ele_struct) this_ele
real(rp) this_a(0:n_pole_maxx), this_b(0:n_pole_maxx)
logical has_nonzero
logical a, b ! protect symbols

!

if (.not. this_ele%multipoles_on .or. .not. this_ele%is_on .or. .not. associated(this_ele%a_pole)) return

this_a = this_ele%a_pole
this_b = this_ele%b_pole

! all zero then we do not need to scale.
! Also if scaling is turned off

if (all(this_a == 0) .and. all(this_b == 0)) return

has_nonzero_pole = .true.

if (.not. this_ele%scale_multipoles) return

! flip sign for electrons or antiprotons with a separator.

if (this_ele%key == elseparator$ .and. particle < 0) then
  this_a = -this_a
  this_b = -this_b
endif

! use tilt?

if (use_ele_tilt .and. this_ele%value(tilt_tot$) /= 0) then
  do n = 0, n_pole_maxx
    if (this_a(n) /= 0 .or. this_b(n) /= 0) then
      an = this_a(n); bn = this_b(n)
      cos_t = cos((n+1)*this_ele%value(tilt_tot$))
      sin_t = sin((n+1)*this_ele%value(tilt_tot$))
      this_b(n) =  bn * cos_t + an * sin_t
      this_a(n) = -bn * sin_t + an * cos_t
    endif
  enddo
endif

! radius = 0 defaults to radius = 1

radius = this_ele%value(radius$)
if (radius == 0) radius = 1

! normal case...

select case (this_ele%key)

case (sbend$, rbend$)
  const = this_ele%value(l$) * (this_ele%value(g$) + this_ele%value(g_err$))
  ref_exp = 0

case (elseparator$, kicker$)
  if (this_ele%value(hkick$) == 0) then
    const = this_ele%value(vkick$)
  elseif (this_ele%value(vkick$) == 0) then
    const = this_ele%value(hkick$)
  else
    const = sqrt(this_ele%value(hkick$)**2 + this_ele%value(vkick$)**2)
  endif
  ref_exp = 0

case (quadrupole$, sol_quad$)
  const = this_ele%value(k1$) * this_ele%value(l$)
  ref_exp = 1

case (wiggler$)
  const = 2 * this_ele%value(l$) / &
                  (pi * this_ele%value(rho$) * this_ele%value(n_pole$))
  ref_exp = 0

case (solenoid$)
  const = this_ele%value(ks$) * this_ele%value(l$)
  ref_exp = 1

case (sextupole$)
  const = this_ele%value(k2$) * this_ele%value(l$)
  ref_exp = 2
 
case (octupole$)
  const = this_ele%value(k3$) * this_ele%value(l$)
  ref_exp = 3
  
case (ab_multipole$, multipole$) ! multipoles do not scale
  return

case default
  call out_io (s_fatal$, r_name, 'ELEMENT NOT A AB_MULTIPOLE, QUAD, ETC. ' // this_ele%name)
  if (bmad_status%exit_on_error) call err_exit

end select

! scale multipole values

do n = 0, n_pole_maxx
  factor = const * radius ** (ref_exp - n)
  this_a(n) = factor * this_a(n)
  this_b(n) = factor * this_b(n)
enddo

end subroutine convert_this_ab

end subroutine multipole_ele_to_ab

!------------------------------------------------------------------------
!------------------------------------------------------------------------
!------------------------------------------------------------------------
!+
! Subroutine multipole_kicks (knl, tilt, coord, ref_orb_offset)
!
! Subroutine to put in the kick due to a multipole.
!
! Modules Needed:
!   use bmad
!                          
! Input:
!   knl(0:)        -- Real(rp): Multipole strengths (mad units).
!   tilt(0:)       -- Real(rp): Multipole tilts.
!   coord          -- Coord_struct:
!     %vec(1)          -- X position.
!     %vec(3)          -- Y position.
!   ref_orb_offset -- Logical, optional: If present and n = 0 then the
!                       multipole simulates a zero length bend with bending
!                       angle knl.
!
! Output:
!   coord -- Coord_struct: 
!     %vec(2) -- X kick.
!     %vec(4) -- Y kick.
!-

subroutine multipole_kicks (knl, tilt, coord, ref_orb_offset)

implicit none

type (coord_struct)  coord

real(rp) knl(0:), tilt(0:)

integer n

logical, optional :: ref_orb_offset

!

do n = 0, n_pole_maxx
  if (knl(n) == 0) cycle
  call multipole_kick (knl(n), tilt(n), n, coord, ref_orb_offset)
enddo

end subroutine multipole_kicks

!------------------------------------------------------------------------
!------------------------------------------------------------------------
!------------------------------------------------------------------------
!+
! Subroutine multipole_kick (knl, tilt, n, coord, ref_orb_offset)
!
! Subroutine to put in the kick due to a multipole.
!
! Modules Needed:
!   use bmad
!                          
! Input:
!   knl   -- Real(rp): Multipole strength (mad units).
!   tilt  -- Real(rp): Multipole tilt.
!   n     -- Real(rp): Multipole order.
!   coord -- Coord_struct:
!     %vec(1) -- X position.
!     %vec(3) -- Y position.
!   ref_orb_offset -- Logical, optional: If present and n = 0 then the
!                       multipole simulates a zero length bend with bending
!                       angle knl.
!
! Output:
!   coord -- Coord_struct: 
!     %vec(2) -- X kick.
!     %vec(4) -- Y kick.
!-

subroutine multipole_kick (knl, tilt, n, coord, ref_orb_offset)

implicit none

type (coord_struct)  coord

real(rp) knl, tilt, x, y, sin_ang, cos_ang
real(rp) x_vel, y_vel

integer n, m

logical, optional :: ref_orb_offset

! simple case

if (knl == 0) return

! normal case

if (tilt == 0) then
  sin_ang = 0
  cos_ang = 1
  x = coord%vec(1)
  y = coord%vec(3)
else
  sin_ang = sin(tilt)
  cos_ang = cos(tilt)
  x =  coord%vec(1) * cos_ang + coord%vec(3) * sin_ang
  y = -coord%vec(1) * sin_ang + coord%vec(3) * cos_ang
endif

! ref_orb_offset with n = 0 means that we are simulating a zero length dipole.

if (n == 0 .and. present(ref_orb_offset)) then
  coord%vec(2) = coord%vec(2) + knl * cos_ang * coord%vec(6)
  coord%vec(4) = coord%vec(4) + knl * sin_ang * coord%vec(6)
  coord%vec(5) = coord%vec(5) - knl * &
                  (cos_ang * coord%vec(1) + sin_ang * coord%vec(3))
  return
endif

! normal case

x_vel = 0
y_vel = 0

do m = 0, n, 2
  x_vel = x_vel + knl * c_multi(n, m) * mexp(x, n-m) * mexp(y, m)
enddo

do m = 1, n, 2
  y_vel = y_vel + knl * c_multi(n, m) * mexp(x, n-m) * mexp(y, m)
enddo

if (tilt == 0) then
  coord%vec(2) = coord%vec(2) + x_vel
  coord%vec(4) = coord%vec(4) + y_vel
else
  coord%vec(2) = coord%vec(2) + x_vel * cos_ang - y_vel * sin_ang
  coord%vec(4) = coord%vec(4) + x_vel * sin_ang + y_vel * cos_ang
endif

end subroutine multipole_kick

!------------------------------------------------------------------------
!------------------------------------------------------------------------
!------------------------------------------------------------------------
!+
! Subroutine ab_multipole_kick (a, b, n, coord, kx, ky, dk)
!
! Subroutine to put in the kick due to an ab_multipole.
!
! Modules Needed:
!   use bmad
!                          
! Input:
!   a     -- Real(rp): Multipole skew component.
!   b     -- Real(rp): Multipole normal component.
!   n     -- Real(rp): Multipole order.
!   coord -- Coord_struct:
!
! Output:
!   kx      -- Real(rp): X kick.
!   ky      -- Real(rp): Y kick.
!   dk(2,2) -- Real(rp), optional: Kick derivative: dkick(x,y)/d(x,y).
!-

subroutine ab_multipole_kick (a, b, n, coord, kx, ky, dk)

implicit none

type (coord_struct)  coord

real(rp) a, b, x, y
real(rp), optional :: dk(2,2)
real(rp) kx, ky, f


integer n, m, n1

! Init

kx = 0
ky = 0

if (present(dk)) dk = 0

! simple case

if (a == 0 .and. b == 0) return

! normal case
! Note that c_multi can be + or -

x = coord%vec(1)
y = coord%vec(3)

do m = 0, n, 2
  f = c_multi(n, m, .true.) * mexp(x, n-m) * mexp(y, m)
  kx = kx + b * f
  ky = ky - a * f
enddo

do m = 1, n, 2
  f = c_multi(n, m, .true.) * mexp(x, n-m) * mexp(y, m)
  kx = kx + a * f
  ky = ky + b * f
enddo

! dk calc

if (present(dk)) then

  n1 = n - 1
  
  do m = 0, n1, 2
    f = n * c_multi(n1, m, .true.) * mexp(x, n1-m) * mexp(y, m)
    dk(1,1) = dk(1,1) + b * f
    dk(2,1) = dk(2,1) - a * f

    dk(1,2) = dk(1,2) - a * f
    dk(2,2) = dk(2,2) - b * f
  enddo


  do m = 1, n1, 2
    f = n * c_multi(n1, m, .true.) * mexp(x, n1-m) * mexp(y, m)
    dk(1,2) = dk(1,2) + b * f
    dk(2,2) = dk(2,2) - a * f

    dk(1,1) = dk(1,1) + a * f
    dk(2,1) = dk(2,1) + b * f
  enddo

endif

end subroutine ab_multipole_kick

end module
