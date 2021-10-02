program spin_test

use bmad
use pointer_lattice, only: c_linear_map, operator(*), assignment(=)

implicit none

type (lat_struct), target :: lat
type (ele_struct), pointer :: ele
type (ele_struct) t_ele
type (coord_struct) orb0, orb_start, orb_end, orb1, orb2
type (c_linear_map) q_map

real(rp) spin_a(3), spin_b(3), spin0(3), dr(6), a_quat(0:3), n_vec(3)
real(rp) mat6(6,6), smap(0:3,0:6), n0(3)
complex(rp) orb_eval(6), orb_evec(6,6), spin_evec(6,3)
integer i, nargs

character(40) :: lat_file = 'spin_test.bmad'
logical print_extra, err_flag

namelist / param / dr

!                  

global_com%exit_on_error = .false.

print_extra = .false.
nargs = command_argument_count() 
if (nargs > 1) then  
  print *, 'Only one command line arg permitted.'
  call err_exit                                  

elseif (nargs > 0)then
  call get_command_argument(1, lat_file)
  print *, 'Using ', trim(lat_file)
  print_extra = .true.             
endif                              

!

open (1, file = 'output.now')

!---------------------------------
! Eigen anal with and without RF.

mat6(1,:) = [-1.45026813625181_rp, 9.65474735831485_rp, -0.31309608791633_rp, -0.171199120220268_rp, 0.0_rp, 3.37037875356424_rp]
mat6(2,:) = [-0.328934364801585_rp, 1.500272137146_rp, -0.0503772356507922_rp, -0.0276056627287384_rp, 0.0_rp, 0.912803122319566_rp]
mat6(3,:) = [-0.114957344655893_rp, -0.0631990019710067_rp, 1.21287214837796_rp, 4.50079805390412_rp, 0.0_rp, 0.000321081798152189_rp]
mat6(4,:) = [0.00316047124266308_rp, 0.00157494979268561_rp, -0.293681197933547_rp, -0.265335840335757_rp, 0.0_rp, -8.76011184832822e-06_rp]
mat6(5,:) = [0.215175896257439_rp, -3.75639824621782_rp, 0.115921051143903_rp, 0.063183785322055_rp, 1.0_rp, -0.929978144660634_rp]
mat6(6,:) = [0.0_rp, 0.0_rp, 0.0_rp, 0.0_rp, 0.0_rp, 1.0_rp]

smap(0,:) = [0.629042006322742_rp, -0.418211907218498_rp, 0.635632897145065_rp, -0.0567487273391509_rp, -0.0114013118658281_rp, 0.0_rp, 0.466973604342706_rp]
smap(1,:) = [-0.00685250940958695_rp, -0.0220406297379937_rp, -0.0269930570480571_rp, 0.667012158147191_rp, 2.17195796294257_rp, 0.0_rp, -0.00293561427302652_rp]
smap(2,:) = [-0.777294845209733_rp, -0.338517412818692_rp, 0.5143587138526_rp, -0.0476276423794947_rp, -0.0307172897350696_rp, 0.0_rp, 0.377861514185347_rp]
smap(3,:) = [-0.00848062536777657_rp, 0.0242925995028888_rp, 0.0255153607860429_rp, -0.382910379812211_rp, 0.214739411520287_rp, 0.0_rp, 0.00664126972595546_rp]

call spin_mat_to_eigen(mat6, smap, orb_eval, orb_evec, n0, spin_evec)
write (1, '(a, 3f14.10)') '"n0 noRF" ABS 1E-9', n0
do i = 1, 3
  write (1, '(a, 6f14.10)') '"spin_evec' // int_str(i) // ' RE noRF" ABS 1E-7', real(spin_evec(:,i), rp)
  write (1, '(a, 6f14.10)') '"spin_evec' // int_str(i) // ' IM noRF" ABS 1E-7', aimag(spin_evec(:,i))
enddo

mat6(1,:) = [-1.86188861871179_rp, 11.6415650949441_rp, -0.379398600528061_rp, -0.207432122016991_rp, 0.00304692758210734_rp, 4.04419952113488_rp]
mat6(2,:) = [-0.315028290447258_rp, 1.42969286047843_rp, -0.0480313327017454_rp, -0.0263103137420259_rp, 0.00203307819643807_rp, 0.889365901699835_rp]
mat6(3,:) = [-0.113800985432133_rp, -0.0627208591970316_rp, 0.90520668432316_rp, 4.29461375890543_rp, 0.0_rp, 0.000220836368260771_rp]
mat6(4,:) = [0.0031371439833448_rp, 0.00156512517121112_rp, -0.287935721862071_rp, -0.261367231459817_rp, 0.0_rp, 3.62949397953724e-05_rp]
mat6(5,:) = [0.383008304690509_rp, -4.56790453302225_rp, 0.142987043987865_rp, 0.0778167332865311_rp, 0.999599101473338_rp, -1.20504653880018_rp]
mat6(6,:) = [-0.000819009327739449_rp, -0.00462386992979728_rp, 0.000124247737021488_rp, 6.61961003550175e-05_rp, 0.00523961427182708_rp, 0.999599099135173_rp]

smap(0,:) = [0.627585943823847_rp, -0.400652158344974_rp, 0.548132807366073_rp, -0.0552283272173976_rp, -0.0136685745371593_rp, 0.000769662570518589_rp, 0.43832877203216_rp]
smap(1,:) = [-0.00577912096536385_rp, -0.022433622147659_rp, -0.023934389475195_rp, 0.643992369281101_rp, 2.15609605612843_rp, -7.07063211731558e-06_rp, -0.00228775603796164_rp]
smap(2,:) = [-0.778492991161124_rp, -0.323048089979131_rp, 0.441845517473186_rp, -0.0458892036514809_rp, -0.0290461360214925_rp, 0.000620467256904083_rp, 0.353328140106095_rp]
smap(3,:) = [-0.00715175423263742_rp, 0.0247012868571641_rp, 0.0230889442582705_rp, -0.371630255499699_rp, 0.220039460098232_rp, 5.71356858448481e-06_rp, 0.00541359028621752_rp]

call spin_mat_to_eigen(mat6, smap, orb_eval, orb_evec, n0, spin_evec)
write (1, '(a, 3f14.10)') '"n0 wRF" ABS 1E-9', n0
do i = 1, 3
  write (1, '(a, 6f14.10)') '"spin_evec' // int_str(i) // ' RE wRF" ABS 2E-7', real(spin_evec(:,i), rp)
  write (1, '(a, 6f14.10)') '"spin_evec' // int_str(i) // ' IM wRF" ABS 2E-7', aimag(spin_evec(:,i))
enddo

!---------------------------------

call bmad_parser ('small_line.bmad', lat)

call spin_concat_linear_maps (q_map, lat%branch(0), 0, 0)

do i = 0, 3
  write (1, '(a, 7es16.8)') '"q_map' // int_str(i) // '" ABS 1E-8', real(q_map%q(i,:), rp)
enddo

!---------------------------------

call bmad_parser (lat_file, lat)

open (2, file = lat_file)
read (2, nml = param)
close (2)

call init_coord (orb0, lat%particle_start, lat%ele(0), downstream_end$)
call ptc_transfer_map_with_spin (lat%branch(0), t_ele%taylor, t_ele%spin_taylor, orb0, err_flag, 0, 1)

orb_start = orb0
orb_start%vec = orb_start%vec + dr

a_quat = track_taylor(orb_start%vec, t_ele%spin_taylor, t_ele%taylor%ref)
spin_a = quat_rotate (a_quat, orb0%spin)

bmad_com%spin_tracking_on = .true.
call track1 (orb_start, lat%ele(1), lat%param, orb_end)
spin_b = orb_end%spin

!

write (1, '(a, 3f14.9)') '"dPTC-Quad"   ABS 0   ', spin_a - orb0%spin
write (1, '(a, 3f14.9)') '"dBmad-Quad"  ABS 0   ', spin_b - orb0%spin


if (print_extra) then
  call type_taylors (t_ele%taylor)
  print *, '--------------------------------'
  call type_taylors (t_ele%spin_taylor)

  print '(a, 3f12.6)', 'Init:      ', orb0%spin
  print '(a, 3f12.6)', 'dPTC_Quad: ', spin_a - orb0%spin
  print '(a, 3f12.6)', 'dBmad-Quad:', spin_b - orb0%spin
endif

!

n_vec = [1.0_rp, 2.0_rp, 3.0_rp] / sqrt(14.0_rp)
orb2 = orb0
call rotate_spin (n_vec * 0.12_rp, orb2%spin)

write (1, '(a, 4es10.2)') '"dRot"   ABS 1e-10   ', orb2%spin
if (print_extra) then
  write (*, '(a, 4es10.2)') '"dRot" ABS 1e-10   ', orb2%spin
endif

!

ele => lat%ele(2)
bmad_com%spin_tracking_on = .true.

orb_start = orb0
ele%spin_tracking_method = taylor$
call track1 (orb_start, lat%ele(2), lat%param, orb_end)
write (1, '(a, 3f12.8)') '"Taylor-Taylor" ABS 1e-10  ', orb_end%spin

orb_start = orb0
ele%spin_tracking_method = symp_lie_ptc$
call track1 (orb_start, lat%ele(2), lat%param, orb_end)
write (1, '(a, 3f12.8)') '"PTC-Taylor" ABS 1e-10  ', orb_end%spin

close (1)

end program
