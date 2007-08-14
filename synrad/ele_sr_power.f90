!-------------------------------------------------------------------------
!-------------------------------------------------------------------------
!-------------------------------------------------------------------------
!+
! subroutine ele_sr_power (lat, ie, orb, direction, 
!                             power, negative_x_wall, positive_x_wall, gen)
!
! subroutine to calculate the synch radiation power from
!      one element of the lat
!
! Modules needed:
!   use sr_mod
!
! Input:
!   lat     -- lat_struct: with twiss propagated and mat6s made
!   ie      -- integer: index of the current element in lat
!   orb(0:) -- coord_struct: orbit of particles to use as 
!                             source of ray
!   direction -- integer: +1 for in direction of s
!                         -1 for against s
!   negative_x_wall -- wall_struct: negative-x wall side with outline ready
!   positive_x_wall -- wall_struct: positive-x wall side with outline ready
!   gen    -- synrad_param_struct: Contains lat name,
!                     vert emittance, and beam current
!
! Output:
!   power(:) -- ele_power_struct: power radiated from a lat ele
!   negative_x_wall -- wall_struct: negative_x wall side with power information
!   positive_x_wall -- wall_struct: positive_x wall side with power information
!-

subroutine ele_sr_power (lat, ie, orb, direction, power, &
                                          negative_x_wall, positive_x_wall, gen)

  use sr_struct
  use sr_interface

  implicit none

  type (lat_struct), target :: lat
  type (coord_struct) orb(0:)
  type (ele_struct), pointer :: ele
  type (wall_struct) negative_x_wall, positive_x_wall
  type (ray_struct), allocatable, save :: rays(:)
  type (ray_struct) ray, ray_temp
  type (synrad_param_struct) gen
  type (ele_power_struct) power(:)

  integer direction, ie, i_ray, n_slice, ns

  real(rp) l_off, del_l, l0, l1, l_try

! power calculation is only for bends, quads and wigglers.

  ele => lat%ele(ie)

  if (ele%key /= sbend$ .and. ele%key /= quadrupole$ .and. &
                     ele%key /= wiggler$ .and. ele%key /= sol_quad$) return

  ! check if periodic wiggler has non-zero b_field
  if (ele%key == wiggler$ .and. ele%sub_key == periodic_type$ &
       .and. ele%value(b_max$) == 0.) return


  ! check if ele is on
  if (ele%is_on == .false.) return


! partition the quad/bend/wiggler into sections and track the synch
! radiation comming from the ends of the sections to see where they hit
! the wall

! If different rays hit both negative_x_wall and positive_x_wall then we need to find the ray
! that just misses the negative_x_wall side and break up the fan accordingly into
! two pieces

!!      if (abs(ele%value(tilt$)) > 20*twopi/360) cycle   ! ignore skew quads

  i_ray = 0
  n_slice = 20 

  if (ele%key == wiggler$) then
    if (ele%sub_key == periodic_type$) then

      ! If periodic wiggler, do 10 slices per pole

      if (ele%value(n_pole$) == 0) then
        type *, 'WARNING IN ELE_SR_POWER: "N_POLE" FOR WIGGLER = 0.'
        type *, '      CALCULATED RADIATION FROM THIS WIGGLER WILL BE 0!'
      endif
      n_slice = max(1, nint(10 * ele%value(n_pole$)))
    else
      n_slice = max(100, ele%num_steps)
    endif      
  endif

  if (.not. allocated (rays)) allocate(rays(n_slice+1))
  if (n_slice+1 > size(rays)) then
    deallocate(rays)
    allocate(rays(n_slice+1))
  endif

  ! each change in position is the element length / n_slice

  del_l = ele%value(l$) / n_slice

  do ns = 0, n_slice

    l_off = ns * del_l
    i_ray = i_ray + 1

    ! start a ray from each slice location
    call init_ray (rays(i_ray), lat, ie, l_off, orb, direction)
    ! track the ray until it hits something
    call track_ray_to_wall (rays(i_ray), lat, negative_x_wall, positive_x_wall)


    ! check if this ray hit a different wall than the previous ray
    if (i_ray > 1) then
      if (rays(i_ray)%wall%side /= rays(i_ray-1)%wall%side) then
        ray_temp = rays(i_ray)
        rays(i_ray) = rays(i_ray-1)
        l0 = l_off - del_l
        l1 = l_off

        ! binary search for transition point
        do
          l_try = (l0 + l1) / 2
          call init_ray (ray, lat, ie, l_try, orb, direction)
          call track_ray_to_wall (ray, lat, negative_x_wall, positive_x_wall)
          if (ray%wall%side == rays(i_ray)%wall%side) then
            rays(i_ray) = ray
            l0 = l_try
          else
            ray_temp = ray
            l1 = l_try
          endif

          ! if the transition point has been found to within .5 mm,
          ! calc the first wall's power then reset the ray array 
          ! for the second wall
          if ((l1 - l0) .le. 5e-4) then
            if (abs(rays(i_ray)%start%vec(5) - &
                 rays(i_ray-1)%start%vec(5)) < 5e-4) i_ray = i_ray - 1
            call seg_power_calc (rays, i_ray, negative_x_wall, positive_x_wall, &
                 lat, gen, power(ie))
            rays(1) = ray_temp
            i_ray = 1
            exit
          endif
        enddo
      endif
    endif
  enddo

! now compute the sr power hitting the wall using the tracking results
! and interpolating inbetween.

  call seg_power_calc (rays, i_ray, negative_x_wall, positive_x_wall, lat, gen, &
       power(ie))

end subroutine ele_sr_power
