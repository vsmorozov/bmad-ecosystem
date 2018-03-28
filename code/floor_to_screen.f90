!--------------------------------------------------------------------------
!--------------------------------------------------------------------------
!--------------------------------------------------------------------------
!+
! Subroutine floor_to_screen (graph, floor, x_screen, y_screen)
!
! Routine to project a 3D floor coordinate onto a 2D projection plane.
!
! Input:
!   graph  -- tao_graph_struct: Graph defining the projection plane.
!   floor  -- floor_position_struct: 3D coordinate.
!
! Output:
!   x_screen -- real(rp): x-coordinate of projected point.
!   y_screen -- real(rp): y-coordinate of projected point.
!-

subroutine floor_to_screen (graph, r_floor, x_screen, y_screen)

use bmad_struct
use tao_struct

implicit none

type (tao_graph_struct) graph

real(rp) r_floor(3), x_screen, y_screen
real(rp) x, y
real(rp), save :: t, old_t = 0
real(rp), save :: cc, ss

! 

select case (graph%floor_plan_view(1:1))
case ('x')
  x = r_floor(1)
case ('y')
  x = r_floor(2)
case ('z')
  x = r_floor(3)
end select

select case (graph%floor_plan_view(2:2))
case ('x')
  y = r_floor(1)
case ('y')
  y = r_floor(2)
case ('z')
  y = r_floor(3)
end select

t = graph%floor_plan_rotation
if (t == 0) then
  x_screen = x
  y_screen = y
else
  if (t /= old_t) then
    cc = cos(twopi * t)
    ss = sin(twopi * t)
    old_t = t
  endif
  x_screen =  x * cc - y * ss
  y_screen =  x * ss + y * cc 
endif

end subroutine floor_to_screen
