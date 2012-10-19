module beam_def_struct

use bmad_struct

! Sigma matrix elements (21 total)
integer, parameter :: s11$ = 1, s12$ = 2, s13$ = 3, s14$ =  4, s15$ =  5
integer, parameter :: s16$ = 6, s22$ = 7, s23$ = 8, s24$ = 9
integer, parameter :: s25$ = 10, s26$ = 11, s33$ = 12, s34$ = 13, s35$ = 14
integer, parameter :: s36$ = 15, s44$ = 16, s45$ = 17, s46$ = 18
integer, parameter :: s55$ = 19, s56$ = 20, s66$ = 21

type beam_spin_struct
  real(rp) :: polarization = 1.0 ! 100% polarized is default.
  real(rp) :: theta = 0.0        ! polarization direction in polar coordinates
  real(rp) :: phi = 0.0          ! polarization direction in polar coordinates
end type

type bunch_struct
  type (coord_struct), allocatable :: particle(:)
  integer, allocatable :: ix_z(:)  ! bunch%ix_z(1) is index of head particle, etc.
  real(rp) charge   ! Total charge in a bunch (Coul).
  real(rp) z_center ! Longitudinal center of bunch (m). Note: Generally, z_center of 
                    !   bunch #1 is 0 and z_center of the other bunches is negative.
  real(rp) t_center ! Center of bunch creation time relative to head bunch.
  integer species   ! electron$, proton$, etc.
  integer ix_ele    ! Element this bunch is at.
  integer ix_bunch  ! Bunch index. Head bunch = 1, etc.
end type

type beam_struct
  type (bunch_struct), allocatable :: bunch(:)
end type

type ellipse_beam_init_struct
  integer :: part_per_ellipse = 0  ! number of particles per ellipse
  integer :: n_ellipse = 1         ! number of ellipses (>= 1)
  real(rp) :: sigma_cutoff = 0     ! sigma cutoff of the representation
end type

type kv_beam_init_struct
  integer :: part_per_phi(2) = 0    ! number of particles per angle variable.
  integer :: n_I2 = 0               ! number of I2
  real(rp) :: A = 0                 ! A = I1/e
end type

type grid_beam_init_struct
  integer :: n_x = 0         ! Number of columns.
  integer :: n_px = 0        ! Number of rows.
  real(rp) :: x_min = 0      ! Lower x limit.
  real(rp) :: x_max = 0      ! Upper x limit.
  real(rp) :: px_min = 0     ! Lower px limit.
  real(rp) :: px_max = 0     ! Upper px limit,
end type

type beam_init_struct
  character(16) :: distribution_type(3) = '' ! distribution type (in x-px, y-py, and z-pz planes)
                                             ! "ELLIPSE", "KV", "GRID", "", or "RAN_GAUSS" 
  type (ellipse_beam_init_struct) ellipse(3) ! Parameters for ellipse beam distribution
  type (kv_beam_init_struct) KV              ! Parameters for KV beam distribution
  type (grid_beam_init_struct) grid(3)       ! Parameters for grid beam distribution
  !!! The following are for Random distributions
  real(rp) :: center_jitter(6) = 0.0  ! Bunch center rms jitter
  real(rp) :: emit_jitter(2)   = 0.0  ! a and b bunch emittance rms jitter normalized to emittance
  real(rp) :: sig_z_jitter     = 0.0  ! bunch length RMS jitter 
  real(rp) :: sig_e_jitter     = 0.0  ! energy spread RMS jitter 
  integer :: n_particle = 0           ! Number of random particles per bunch.
  logical :: renorm_center = .true.   ! Renormalize centroid?
  logical :: renorm_sigma = .true.    ! Renormalize sigma?
  character(16) :: random_engine = 'pseudo' ! Or 'quasi'. Random number engine to use. 
  character(16) :: random_gauss_converter = 'exact'  
                                            ! Or 'quick'. Uniform to gauss conversion method.
  real(rp) :: random_sigma_cutoff = -1      ! Cut-off in sigmas.
  !!! The following are used  by all distribution types
  type(beam_spin_struct)  spin        ! Initialize the spin
  real(rp) :: a_norm_emit = 0         ! a-mode normalized emittance (emit * gamma)
  real(rp) :: b_norm_emit = 0         ! b-mode normalized emittance (emit * gamma)
  real(rp) :: a_emit = 0              ! a-mode emittance
  real(rp) :: b_emit = 0              ! b-mode emittance
  real(rp) :: dPz_dz = 0              ! Correlation of Pz with long position.
  real(rp) :: center(6) = 0           ! Bench center offset relative to reference.
  real(rp) dt_bunch                   ! Time between bunches.
  real(rp) sig_z                      ! Z sigma in m.
  real(rp) sig_e                      ! e_sigma in dE/E.
  real(rp) bunch_charge               ! charge in a bunch.
  integer :: n_bunch = 1              ! Number of bunches.
  logical :: init_spin     = .false.  ! initialize beam spinors
  logical :: full_6D_coupling_calc = .false. ! Use V from 6x6 1-turn mat to match distribution?  
                                             !   Else use 4x4 1-turn mat used.
  logical :: use_t_coords = .false.   ! If true, the distributions will be taken as in t-coordinates  
  logical :: use_z_as_t   = .false.   ! Only used if  use_t_coords = .true.
                                      !   If true,  z describes the t distribution 
                                      !   If false, z describes the s distribution
end type

type bunch_params_struct
  type (twiss_struct) :: x, y, z, a, b, c
  type (coord_struct) :: centroid  ! Lab frame
  type (beam_spin_struct) :: spin  ! polarization
  real(rp) sigma(21)               ! projected sigma matrix
  real(rp) s                       ! Longitudinal position.
  real(rp) charge_live             ! Charge of all non-lost particle
  integer n_particle_tot
  integer n_particle_live          ! all non-lost particles
  integer n_particle_lost_in_ele
end type

! This is to suppress the ranlib "has no symbols" message
integer, private :: private_dummy

end module
