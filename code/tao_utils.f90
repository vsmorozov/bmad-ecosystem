!+
! Module tao_utils
!
! helper subroutines available for communal usage.
!-

module tao_utils

use tao_struct
use tao_interface
use bmad
use output_mod

! used for parsing expressions
integer, parameter, private :: plus$ = 1, minus$ = 2, times$ = 3, divide$ = 4
integer, parameter, private :: l_parens$ = 5, r_parens$ = 6, power$ = 7
integer, parameter, private :: unary_minus$ = 8, unary_plus$ = 9, no_delim$ = 10
integer, parameter, private :: sin$ = 11, cos$ = 12, tan$ = 13
integer, parameter, private :: asin$ = 14, acos$ = 15, atan$ = 16, abs$ = 17, sqrt$ = 18
integer, parameter, private :: log$ = 19, exp$ = 20, ran$ = 21, ran_gauss$ = 22
integer, parameter, private :: numeric$ = 100

integer, parameter, private :: eval_level(22) = (/ 1, 1, 2, 2, 0, 0, 4, 3, 3, -1, &
                            9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9 /)

type eval_stack_struct
  integer type
  real(rp), allocatable :: value(:)
end type

contains

!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!+
! Subroutine tao_pick_universe (data_type_in, data_type_out, picked, err)
!
! Subroutine to pick what universe the data name is comming from.
! If data_type_in begins with "*@" choose all universes.
! If data_type_in begins with "n@" then choose universe n.
! If not then choose universe s%global%u_view.
! data_type_out is data_type_in without any "n@"
!
! Input:
!   data_type_in -- Character(*): data name.
!
! Output:
!   data_type_out -- Character(*): data_type_in without any "n@" beginning.
!   picked(:)     -- Logica: Array showing picked universes.
!   err           -- Logical: Set True if an error is detected.
!-

subroutine tao_pick_universe (data_type_in, data_type_out, picked, err)

implicit none

character(*) data_type_in, data_type_out
character(20) :: r_name = 'tao_pick_universe'
character(8) uni

integer ix, n, ios, iu

logical picked(:)
logical err

! Init

err = .false.
picked = .false.

! No "@" then simply choose s%global%u_view

ix = index (data_type_in, '@')
if (ix == 0) then
  picked (s%global%u_view) = .true.
  data_type_out = data_type_in
  return
endif

! Here whn "@" is found...

data_type_out = data_type_in(ix+1:)
uni = data_type_in(:ix-1)

if (uni == '*') then
  picked = .true.
  return
endif

read (uni, '(i)', iostat = ios) iu
if (ios /= 0) then
  call out_io (s_error$, r_name, "BAD UNIVERSE NUMBER: " // data_type_in)
  err = .true.
  return
endif
if (iu == 0) iu = s%global%u_view
if (iu < 1 .or. iu > size(s%u)) then
  call out_io (s_error$, r_name, "BAD UNIVERSE NUMBER: " // data_type_in)
  err = .true.
  return
endif

picked(iu) = .true.

end subroutine

!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!+
! Subroutine tao_point_v1_to_var (v1, var, n, n_var)
!
! used for arbitrary variable pointer indexing
!
! v1       -- tao_v1_var_struct: Contains the pointer
! var(n:)  -- tao_var_struct: the variable
! n        -- integer: starting index for the var array.
!-

subroutine tao_point_v1_to_var (v1, var, n, n_var)

implicit none

integer n, i, n_var

type (tao_v1_var_struct), target :: v1
type (tao_var_struct), target :: var(n:)

v1%v => var

do i = lbound(var, 1), ubound(var, 1)
  var(i)%ix_v1 = i
  var(i)%ix_var = n_var + i - n
  var(i)%v1 => v1
enddo

end subroutine 

!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!+
! Subroutine tao_point_d1_to_data (ip, ii, n, n_data)
!
! Routine used for arbitrary data pointer indexing
!
! ip     -- tao_data_struct: the pointer
! ii     -- tao_data_struct: the data
! n      -- integer: starting index for the pointer
! n_data -- integer: starting index for the next data point in the big data array
!-

subroutine tao_point_d1_to_data (ip, ii, n, n_data)

implicit none

integer n, i, n0, n_data

type (tao_data_struct), pointer :: ip(:)
type (tao_data_struct), target :: ii(n:)

ip => ii

forall (i = lbound(ii, 1):ubound(ii, 1)) 
  ii(i)%ix_d1 = i
  ii(i)%ix_data = n_data + i - n
end forall

end subroutine 

!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!+
! Subroutine tao_locate_element (string, ix_universe, ix_ele, ignore_blank) 
!
! Subroutine to find a lattice element.
!
! Input:
!   string       -- Character(*): String with element name or index locations
!   ix_universe  -- Integer: Universe to search. 0 => search s%global%u_view.
!   ignore_blank -- Logical, optional: If present and true then do nothing if
!     string is blank. otherwise treated as an error.
!
! Output:
!   ix_ele  -- Integer(:), allocatable: Index array of elements. 
!                         ix_ele(1) = -1 if element not found.
!-

subroutine tao_locate_element (string, ix_universe, ix_ele, ignore_blank)

implicit none

integer ios, ix, ix_universe, ix_ele_temp, num, i, i_ix_ele
integer, allocatable :: ix_ele(:)

character(*) string
character(40) ele_name
character(20) :: r_name = 'tao_locate_element'

logical, optional :: ignore_blank
logical, allocatable, save :: here(:)

! If it is a number translate it:

call str_upcase (ele_name, string)
call string_trim (ele_name, ele_name, ix)

if (ix == 0 .and. logic_option(.false., ignore_blank)) then
  call re_allocate (ix_ele, 1)
  ix_ele = -1
  return
endif

if (ix == 0) then
  call re_allocate (ix_ele, 1)
  ix_ele = -1
  call out_io (s_error$, r_name, 'ELEMENT NAME IS BLANK')
  return
endif

ix = ix_universe
if (ix == 0) ix = s%global%u_view

if (is_integer(ele_name)) then
  read (ele_name, *, iostat = ios) ix_ele_temp
  call re_allocate (ix_ele, 1)
  ix_ele(1) = ix_ele_temp
  if (ix_ele(1) < 0 .or. ix_ele(1) > s%u(ix)%model%lat%n_ele_max) then
    ix_ele(1) = -1
    call out_io (s_error$, r_name, 'ELEMENT INDEX OUT OF RANGE: ' // ele_name)
  endif
  return
endif

if (is_integer(ele_name(1:1))) then ! must be an array of numbers
  if (allocated (here)) deallocate(here)
  allocate(here(0:s%u(ix)%model%lat%n_ele_max))
  call location_decode(ele_name, here, 0, num) 
  call re_allocate (ix_ele, num)
  i_ix_ele = 1
  do i = 0, ubound(here,1)
    if (here(i)) then
      ix_ele(i_ix_ele) = i
      i_ix_ele = i_ix_ele + 1
    endif
  enddo
  return
endif

call re_allocate (ix_ele, 1)
call element_locator (ele_name, s%u(ix)%model%lat, ix_ele(1))

if (ix_ele(1) < 0) call out_io (s_error$, r_name, 'ELEMENT NOT FOUND: ' // string)

end subroutine

!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!+
! Subroutine tao_pointer_to_var_in_lattice (var, this, ix_uni, is_ele, err)
! 
! Routine to set a pointer to the appropriate variable in a lattice
!
! Input:
!   var    -- Tao_var_struct: Structure has the info of where to point.
!   this   -- Tao_this_var_struct: the variables pointers to point with
!   ix_uni -- Integer: the universe to use
!   ix_ele -- (Optional) Integer: Point to this element
!
! Output:
!   err   -- Logical: Set True if there is an error. False otherwise.
!-

subroutine tao_pointer_to_var_in_lattice (var, this, ix_uni, ix_ele, err)

implicit none

type (tao_var_struct) var
type (tao_universe_struct), pointer :: u
type (tao_this_var_struct) this

integer, optional :: ix_ele
integer ix, ie, ix_uni
logical, optional :: err
logical error
character(30) :: r_name = 'tao_pointer_to_var_in_lattice'

! locate element

  if (present(err)) err = .true.

  u => s%u(ix_uni)
  if (present(ix_ele)) then
    ie = ix_ele
  else
    call element_locator (var%ele_name, u%model%lat, ie)
  endif

  if (ie < 0) then
    call out_io (s_error$, r_name, 'ELEMENT NAME NOT FOUND: ' // var%ele_name)
    if (present(err)) return
    call err_exit
  endif

  ! locate attribute

  call pointer_to_attribute (u%model%lat%ele_(ie), var%attrib_name, .true., &
                                                                 this%model_ptr, error)
  if (error) then
    if (present(err)) return
    call err_exit
  endif

  call pointer_to_attribute (u%base%lat%ele_(ie),  var%attrib_name, .true., &
                                                                 this%base_ptr,  error)

  if (present(err)) err = .false.

  this%ix_ele = ie
  this%ix_uni = ix_uni

end subroutine tao_pointer_to_var_in_lattice

!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!+
! Subroutine tao_locate_elements (var, ix_u, n_ele)
!
! Routine to locate the elements with name s_var%ele_name.
!-

subroutine tao_locate_elements (var, ix_u, n_ele)

implicit none

type (tao_var_struct) var
type (ring_struct), pointer :: lat

integer ix_u, n_ele, iv

!

lat => s%u(ix_u)%model%lat

n_ele = 0
do iv = 0, lat%n_ele_max
  if (var%ele_name == lat%ele_(iv)%name) then
    n_ele = n_ele + 1
    lat%ele_(n_ele)%ixx = iv
  endif
enddo

end subroutine

!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!+
! Subroutine tao_find_plot_region (err, where, region, print_flag)
!
! Routine to find a region using the region name.
!
! Input:
!   where      -- Character(*): Region name.
!   print_flag -- Logical, optional: If present and False then surpress error
!                   messages. Default is True.
!
! Output:
!   err      -- logical: Set True on error. False otherwise.
!   region   -- Tao_plot_region_struct, pointer: Region found.
!-

subroutine tao_find_plot_region (err, where, region, print_flag)

implicit none

type (tao_plot_region_struct), pointer :: region

integer i, ix

character(*) where
character(40) plot_name, graph_name
character(28) :: r_name = 'tao_find_plot_region'

logical, optional :: print_flag
logical err

! Parse where argument

ix = index(where, '.')
if (ix == 0) then
  plot_name = where
else
  plot_name = where(1:ix-1)
endif

! Match plot name to region

err = .false.

do i = 1, size(s%plot_page%region)
  region => s%plot_page%region(i)
  if (plot_name == region%name) return
enddo

if (logic_option(.true., print_flag)) call out_io (s_error$, r_name, &
                                    'PLOT LOCATION NOT FOUND: ' // plot_name)
err = .true.

end subroutine

!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!+
! Subroutine tao_find_plots (err, name, where, plot, graph, curve, print_flag)
!
! Routine to find a plot using the region or plot name.
! A region or plot name is something like: name = "top"
! A graph name is something like: name  = "top.x"
! A curve name is something like: name  = "top.x.1"
!
! Input:
!   name       -- Character(*): Name of plot or region.
!   where      -- Character(*): Where to look: 'TEMPLATE', 'REGION', or 'BOTH'
!   print_flag -- Logical, optional: If present and False then surpress error
!                   messages. Default is True.
!
! Output:
!   err      -- logical: Set True on error. False otherwise.
!   plot(:)  -- Tao_plot_array_struct, allocatable, optional: Array of plots.
!   graph(:) -- Tao_graph_array_struct, allocatable, optional: Array of graphs.
!   curve(:) -- Tao_curve_array_struct, allocatable, optional: Array of curves.
!-

subroutine tao_find_plots (err, name, where, plot, graph, curve, print_flag)

implicit none

type (tao_plot_array_struct), allocatable, optional :: plot(:)
type (tao_graph_array_struct), allocatable, optional :: graph(:)
type (tao_curve_array_struct), allocatable, optional :: curve(:)
type (tao_plot_array_struct), allocatable, save :: p(:)
type (tao_graph_array_struct), allocatable, save :: g(:)
type (tao_curve_array_struct), allocatable, save :: c(:)

integer i, j, k, ix, np, ng, nc

character(*) name, where
character(40) plot_name, graph_name, curve_name
character(28) :: r_name = 'tao_find_plots'

logical, optional :: print_flag
logical err

! Init

if (present(plot)) then
  if (allocated(plot)) deallocate(plot)
endif

if (present(graph)) then
  if (allocated(graph)) deallocate(graph)
endif

if (present(curve)) then
  if (allocated(curve)) deallocate(curve)
endif

if (allocated(p)) deallocate(p)
if (allocated(g)) deallocate(g)
if (allocated(c)) deallocate(c)

! Error check

if (where /= 'REGION' .and. where /= 'BOTH' .and. where /= 'TEMPLATE') then
  if (logic_option(.true., print_flag)) call out_io (s_fatal$, r_name, &
                                             'BAD "WHERE" LOCATION: ' // where)
  call err_exit
endif

! Parse name argument

err = .false.

ix = index(name, '.')
if (ix == 0) then
  plot_name = name
  graph_name = ' '
else
  plot_name = name(1:ix-1)
  graph_name = name(ix+1:)
endif

! Match name to region or plot

np = 0

if (where == 'REGION' .or. where == 'BOTH') then
  do i = 1, size(s%plot_page%region)
    if (s%plot_page%region(i)%name == plot_name .or. plot_name == '*') np = np + 1
    if (s%plot_page%region(i)%plot%name == plot_name .or. plot_name == '*') np = np + 1
  enddo
endif

if (where == 'TEMPLATE' .or. where == 'BOTH') then
  do i = 1, size(s%template_plot)
    if (plot_name == s%template_plot(i)%name .or. plot_name == '*') np = np + 1
  enddo
endif

! Allocate space

if (np == 0) then
  if (logic_option(.true., print_flag)) call out_io (s_error$, r_name, &
                                             'PLOT NOT FOUND: ' // plot_name)
  err = .true.
  return
endif

allocate (p(np))
if (present(plot)) allocate(plot(np))

np = 0

if (where == 'REGION' .or. where == 'BOTH') then
  do i = 1, size(s%plot_page%region)
    if (s%plot_page%region(i)%name == plot_name .or. plot_name == '*') then
      np = np + 1
      p(np)%p => s%plot_page%region(i)%plot
    endif
    if (s%plot_page%region(i)%plot%name == plot_name .or. plot_name == '*') then
      np = np + 1
      p(np)%p => s%plot_page%region(i)%plot
    endif
  enddo
endif

if (where == 'TEMPLATE' .or. where == 'BOTH') then
  do i = 1, size(s%template_plot)
    if (plot_name == s%template_plot(i)%name .or. plot_name == '*') then
      np = np + 1
      p(np)%p => s%template_plot(i)
    endif
  enddo
endif

if (present(plot)) plot = p

! Find graphs

ix = index(graph_name, '.')
if (ix == 0) then
  curve_name = ' '
else
  curve_name = graph_name(ix+1:)
  graph_name = graph_name(1:ix-1)
endif

if (graph_name == ' ') return

ng = 0
do i = 1, np
  do j = 1, size(p(i)%p%graph)
    if (p(i)%p%graph(j)%name == graph_name .or. graph_name == '*') ng = ng + 1
  enddo
enddo

if (ng == 0) then
  if (logic_option(.true., print_flag)) call out_io (s_error$, r_name, &
                  'GRAPH NOT FOUND: ' // trim(plot_name) // '.' // graph_name)
  err = .true.
  return
endif

allocate (g(ng))
if (present(graph)) allocate (graph(ng))

ng = 0
do i = 1, np
  do j = 1, size(p(i)%p%graph)
    if (p(i)%p%graph(j)%name == graph_name .or. graph_name == '*') then
      ng = ng + 1
      g(ng)%g => p(i)%p%graph(j)
    endif
  enddo
enddo

if (present(graph)) graph = g

! Find curves

if (curve_name == ' ') return

nc = 0
do j = 1, ng
  do k = 1, size(g(j)%g%curve)
    if (g(j)%g%curve(k)%name == curve_name .or. curve_name == '*') nc = nc + 1
  enddo
enddo

if (nc == 0) then
  if (logic_option(.true., print_flag)) call out_io (s_error$, r_name, &
                  'CURVE NOT FOUND: ' // name)
  err = .true.
  return
endif

allocate (c(nc))
if (present(curve)) allocate (curve(nc))

nc = 0
do j = 1, np
  do k = 1, size(g(j)%g%curve)
    if (g(j)%g%curve(k)%name == curve_name .or. curve_name == '*') then
      nc = nc + 1
      c(nc)%c => g(j)%g%curve(k)
    endif
  enddo
enddo

if (present(curve)) curve = c

end subroutine

!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!+
! Subroutine tao_data_useit_plot_calc (graph, data)
!
! Subroutine to set the data for plotting.
!
! Input:
!
! Output:
!   data     -- Tao_data_struct:
!     %useit_plot -- True if good for plotting.
!                  = %exists & %good_plot (w/o measured & reference data)
!                  = %exists & %good_plot & %good_user & %good_meas (w/ meas data)
!                  = %exists & %good_plot & %good_user & %good_ref (w/ reference data)
!                  = %exists & %good_plot & %good_user & %good_meas & %good_ref 
!                                                        (w/ measured & reference data)
!-

subroutine tao_data_useit_plot_calc (graph, data)

implicit none

type (tao_graph_struct) graph
type (tao_data_struct) data(:)

!

data%useit_plot = data%exists .and. data%good_plot
if (any(graph%who%name == 'meas')) &
         data%useit_plot = data%useit_plot .and. data%good_user .and. data%good_meas
if (any(graph%who%name == 'ref'))  &
         data%useit_plot = data%useit_plot .and. data%good_user .and. data%good_ref

end subroutine

!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!+
! Subroutine tao_var_useit_plot_calc (graph, var)
!
! Subroutine to set the variables for plotting.
!
! Input:
!
! Output:
!   var     -- Tao_var_struct:
!     %useit_plot -- True if good for plotting.
!-

subroutine tao_var_useit_plot_calc (graph, var)

implicit none

type (tao_graph_struct) graph
type (tao_var_struct) var(:)

!

var%useit_plot = var%exists .and. var%good_user .and. var%good_plot &
                                                .and. var%good_var
if (any(graph%who%name == 'meas')) var%useit_plot = var%useit_plot
if (any(graph%who%name == 'ref'))  var%useit_plot = var%useit_plot

end subroutine

!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!+
! Subroutine tao_find_data (err, data_name, d2_ptr, d1_ptr, d_array, 
!        r_array, l_array, ix_uni, print_err, all_elements, blank_is_null, component)
!
! Routine to set data pointers to the correct data structures. 
!
! The r_array will be used if the component is one of:
!   model, base, design, meas, ref, old, fit, weight
! The l_array will be used if the component is one of:
!   exists, good_meas, good_ref, good_user, good_opt, good_plot
! 
! Setting all_elements = .true. forces something like:
!   data_name = 'orbit.x[3:10]'
! to behave like
!   data_name = 'orbit.x' (= 'orbit.x[*]')
! That is, all elements of orbit.x are selected
!
! Normally 'orbit.x[*]' is synonymous with 'orbit.x' and in both cases d_array
! will contain all the elements of the data array. If blank_is_null = .true.
! then 'orbit.x' will be treated as if no elements are specified and d_array
! will be nullified.
!
! Example:
!   data_name = '*@orbit.x'
! In this case d2_ptr and d1_ptr will be nullifed since the data can refer to
! more than one universe. 
! r_array & l_array will also be nullified since there is no data component specified.
!
! Example:
!   data_name = 'orbit'
! In this case the default universe will be used. The d1_ptr will be nullified 
! unless there is only one d1_data struct associated with 'orbit'. 
! r_array & l_array will also be nullified since there is no data component specified.
!
! Example:
!   data_name = '2@orbit.x[3,7:9]|meas'
! The measured values for the 3rd, 7th, 8th and 9th elements of orbit.x in universe #2.
! r_arrray will be allocated and l_array will be nullified.
!
! Input:
!   data_name    -- Character(*): The data name type. Eg: "3@orbit.x[2:5,10]|meas"
!   ix_uni       -- Integer, optional: Index of default universe to use.
!                     If ix_uni = 0 then "viewed" universe will be used.
!                     Also, if not present then the "viewed" universe will be used.
!   print_err    -- Logical, optional: Print error message if data is 
!                     not found? Default is True.
!   all_elements -- Logical, optional: If present and True then override element 
!                     selection and d_array will point to all elements.
!   blank_is_null -- Logical, optional: See above for sxpanation.
!
! Output:
!   err        -- Logical: Err condition
!   d2_ptr     -- Tao_d2_data_struct, optional, Pointer: to the d2 data
!   d1_ptr     -- Tao_d1_data_struct, optional: Pointer to the d1 data
!   d_array(:) -- Tao_data_array_struct, allocatable, optional: Pointers to all the matching
!                   tao_data_structs.
!   r_array(:) -- Tao_real_array_struct, allocatable, optional: Pointers to all the 
!                   corresponding values.
!   l_array(:) -- Tao_logical_array_struct, allocatable, optional: Pointers logical data
!   component  -- Character(*), optional: Name of the component. E.G: 'good_user'
!                   set to ' ' if no component present.
!-

subroutine tao_find_data (err, data_name, d2_ptr, d1_ptr, d_array, &
           r_array, l_array, ix_uni, print_err, all_elements, blank_is_null, component)

implicit none

type (tao_d2_data_struct), pointer, optional :: d2_ptr
type (tao_d1_data_struct), pointer, optional :: d1_ptr
type (tao_data_array_struct), allocatable, optional    :: d_array(:)
type (tao_real_array_struct), allocatable, optional    :: r_array(:)
type (tao_logical_array_struct), allocatable, optional    :: l_array(:)

character(*) :: data_name
character(*), optional :: component
character(20) :: r_name = 'tao_find_data'
character(80) dat_name, component_name
character(16), parameter :: real_components(8) = &
          (/ 'model ', 'base  ', 'design', 'meas  ', 'ref   ', &
             'old   ', 'fit   ', 'weight' /)
character(16), parameter :: logic_components(6) = &
          (/ 'exists   ', 'good_meas', 'good_ref ', 'good_user', 'good_opt ', &
             'good_plot' /)

integer, optional :: ix_uni
integer :: data_num, ios
integer i, ix, iu

logical err, component_here, this_err, print_error
logical, optional :: print_err, all_elements, blank_is_null

! Init

print_error = logic_option(.true., print_err)

if (present(d2_ptr)) nullify(d2_ptr)
if (present(d1_ptr)) nullify(d1_ptr)
if (present(d_array)) then
  if (allocated (d_array)) deallocate (d_array)
endif
if (present(r_array)) then
  if (allocated (r_array)) deallocate (r_array)
endif
if (present(l_array)) then
  if (allocated (l_array)) deallocate (l_array)
endif

err = .true.

! Check for data

if (all(s%u(:)%n_data_used == 0)) then
  if (print_error) call out_io (s_error$, r_name, &
                        "NO DATA HAVE BEEN DEFINED IN THE INPUT FILES!")
  return
endif


! Select meas, ref, etc.

ix = index(data_name, '|')
if (ix == 0) then  ! not present
  component_here = .false.
  component_name = ' '
  dat_name = data_name
else
  component_here = .true.
  component_name = data_name(ix+1:)
  dat_name = data_name(:ix-1)
endif
if (present(component)) component = component_name

call string_trim (dat_name, dat_name, ix)

if (component_here) then
  call string_trim (component_name, component_name, ix)
  if (.not. any(component_name == real_components) .and. &
      .not. any(component_name == logic_components)) then
    if (print_error) call out_io (s_error$, r_name, "BAD COMPONENT NAME: " // data_name)
    return            
  endif
endif

! Select universe

ix = index(dat_name, '@')

if (ix == 0) then ! No universe specified. Use default
  iu = integer_option (s%global%u_view, ix_uni)
  if (iu == 0) iu = s%global%u_view
  if (iu < 1 .or. iu > size(s%u)) then
    if (print_error) call out_io (s_error$, r_name, "BAD UNIVERSE NUMBER: " // data_name)
    return
  endif
  call find_this_d2 (s%u(iu), dat_name, this_err)

else ! read universe number

  if (dat_name(:ix-1) == '*') then
    do i = 1, size(s%u)
      call find_this_d2 (s%u(i), dat_name(ix+1:), this_err)
      if (this_err) return
    enddo
    if (present(d2_ptr)) nullify(d2_ptr)
    if (present(d1_ptr)) nullify(d1_ptr)

  else
    read (dat_name(:ix-1), '(i)', iostat = ios) iu
    if (ios /= 0) then
      if (print_error) call out_io (s_error$, r_name, "BAD UNIVERSE NUMBER: " // data_name)
      return
    endif
    if (iu == 0) iu = s%global%u_view
    if (iu < 1 .or. iu > size(s%u)) then
      if (print_error) call out_io (s_error$, r_name, "BAD UNIVERSE NUMBER: " // data_name)
      return
    endif
    call find_this_d2 (s%u(iu), dat_name(ix+1:), this_err)
  endif
endif

! error check

if (err) then
  if (print_error) call out_io (s_error$, r_name, "Couldn't find data: " // data_name)
  return
endif

!----------------------------------------------------------------------------
contains

subroutine find_this_d2 (uu, name, this_err)

type (tao_universe_struct) uu
integer i, ix
character(*) name
character(80) d1_name, d2_name
logical this_err

! Everything before a period is the d2 name.
! if no period then must be something like name = "orbit" and everything is the d2 name.

ix = index(name, '.')
if (ix == 0) then
  d2_name = name
  d1_name = '*'
else
  d2_name = name(1:ix-1)
  d1_name = name(ix+1:)
endif

! loop over matching d2 names

do i = 1, uu%n_d2_data_used
  if (d2_name == '*') then
    call find_this_d1 (uu%d2_data(i), d1_name, this_err)
    if (this_err) return
  elseif (d2_name == uu%d2_data(i)%name) then
    if (present(d2_ptr)) d2_ptr => uu%d2_data(i)
    call find_this_d1 (uu%d2_data(i), d1_name, this_err)
    exit
  endif
enddo

end subroutine

!----------------------------------------------------------------------------
! contains

subroutine find_this_d1 (d2, name, this_err)

type (tao_d2_data_struct) :: d2
integer i, ix
character(*) name
character(80) d1_name, d_name
logical this_err

! Everything before a '[' is the d1 name.

ix = index(name, '[')

if (ix == 0) then
  d1_name = name
  d_name = ' '
else
  d1_name = name(1:ix-1)
  d_name = name(ix+1:)
  ix = index(d_name, ']')
  if (ix == 0) then
    if (print_error) call out_io (s_error$, r_name, "NO MATCHING ']': " // data_name)
    this_err = .true.
    return
  endif
  if (d_name(ix+1:) /= ' ') then
    if (print_error) call out_io (s_error$, r_name, "GARBAGE AFTER ']': " // data_name)
    this_err = .true.
    return
  endif
  d_name = d_name(:ix-1)
endif

do i = 1, size(d2%d1)
  if (d1_name == '*') then
    call find_this_data (d2%d1(i), d_name, this_err)
    if (this_err) return
  elseif (d1_name == d2%d1(i)%name) then
    if (present(d1_ptr)) d1_ptr => d2%d1(i)
    call find_this_data (d2%d1(i), d_name, this_err)
    exit
  endif
enddo

end subroutine

!----------------------------------------------------------------------------
! contains

subroutine find_this_data (d1, name, this_err)

type (tao_d1_data_struct) :: d1
type (tao_data_array_struct), allocatable, save :: da(:)
type (tao_real_array_struct), allocatable, save :: ra(:)
type (tao_logical_array_struct), allocatable, save :: la(:)

integer i, j, nd, nl, i1, i2, num

character(*) name
character(80) d1_name, d_name

logical this_err
logical, allocatable, save :: list(:)

!

if (allocated(list)) deallocate(list)
i1 = lbound(d1%d, 1)
i2 = ubound(d1%d, 1)
allocate (list(i1:i2))
this_err = .false.

if (logic_option(.false., blank_is_null) .and. name == ' ') then
  err = .false. 
  return

elseif (logic_option(.false., all_elements) .or. name == '*' .or. name == ' ') then
  list = .true.

else
  call location_decode (name, list, i1, num)
  if (num <  1) then
    call out_io (s_error$, r_name, "BAD DATA NUMBER(S): " // name)
    this_err = .true.
    return  
  endif
endif

err = .false.
nl = count(list)

! data array

if (present(d_array)) then

  if (allocated(d_array)) then
    nd = size(d_array)
    allocate (da(nd))
    da = d_array
    deallocate(d_array)
    allocate (d_array(nl+nd))
    j = nd
    d_array(1:nd) = da
    deallocate(da)
  else
    allocate (d_array(nl))
    j = 0
  endif

  do i = i1, i2
    if (list(i)) then
      j = j + 1
      d_array(j)%d => d1%d(i)
    endif
  enddo

endif

! real component array

if (present(r_array) .and.  any(component_name == real_components)) then

  if (allocated(r_array)) then
    nd = size(r_array)
    allocate (ra(nd))
    ra = r_array
    deallocate(r_array)
    allocate (r_array(nl+nd))
    j = nd
    r_array(1:nd) = ra
    deallocate(ra)
  else
    allocate (r_array(nl))
    j = 0
  endif

  do i = i1, i2
    if (list(i)) then
      j = j + 1
      select case (component_name)
      case ('model')
        r_array(j)%r => d1%d(i)%model_value
      case ('base')
        r_array(j)%r => d1%d(i)%base_value
      case ('design')
        r_array(j)%r => d1%d(i)%design_value
      case ('meas')
        r_array(j)%r => d1%d(i)%meas_value
      case ('ref')
        r_array(j)%r => d1%d(i)%ref_value
      case ('old')
        r_array(j)%r => d1%d(i)%old_value
      case ('fit')
        r_array(j)%r => d1%d(i)%fit_value
      case ('weight')
        r_array(j)%r => d1%d(i)%weight
      case default
        call out_io (s_fatal$, r_name, "INTERNAL ERROR: REAL")
      end select
    endif
  enddo

endif

! logical component array

if (present(l_array) .and. any(component_name == logic_components)) then

  if (allocated(l_array) .and. component_here) then
    nd = size(l_array)
    allocate (la(nd))
    la = l_array
    deallocate(l_array)
    allocate (l_array(nl+nd))
    j = nd
    l_array(1:nd) = la
    deallocate(la)
  else
    allocate (l_array(nl))
    j = 0
  endif

  do i = i1, i2
    if (list(i)) then
      j = j + 1
      select case (component_name)
      case ('exists')
        l_array(j)%l => d1%d(i)%exists
      case ('good_meas')
        l_array(j)%l => d1%d(i)%good_meas
      case ('good_ref')
        l_array(j)%l => d1%d(i)%good_ref
      case ('good_user')
        l_array(j)%l => d1%d(i)%good_user
      case ('good_opt')
        l_array(j)%l => d1%d(i)%good_opt
      case ('good_plot')
        l_array(j)%l => d1%d(i)%good_plot
      case default
        call out_io (s_fatal$, r_name, "INTERNAL ERROR: LOGIC")
      end select
    endif
  enddo

endif

end subroutine

end subroutine tao_find_data

!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!+
! Subroutine: tao_find_var (err, var_name, v1_ptr, v_array, r_array, l_array,  
!                             print_err, all_elements, blank_is_null, component)
!
! Find a v1 variable type, and variable data then point to it.
!
! The r_array will be used if the component is one of:
!   model, base, design, meas, ref, old, step, weight, high_lim, low_lim 
! The l_array will be used if the component is one of:
!   exists, good_var, good_user, good_opt, good_plot
! 
! Setting all_elements = .true. forces something like:
!   var_name = 'quad_k1[3:10]'
! to behave like
!   var_name = 'quad_k1' (= 'quad_k1[*]')
! That is, all elements of quad_k1 are selected
!
! Normally 'quad_k1[*]' is synonymous with 'quad_k1' and in both cases v_array
! will contain all the elements of the data array. If blank_is_null = .true.
! then 'quad_k1' will be treated as if no elements are specified and v_array
! will be nullified.
!
! Example:
!   var_name = 'quad_k1[3]|design'
!
! Input:
!   var_name     -- Character(*): Name of the variable.
!   print_err    -- Logical, optional: Print error message if data is 
!                     not found? Default is True.
!   all_elements -- Logical, optional: If present and True then override element 
!                     selection and v_array will point to all elements.
!   blank_is_null -- Logical, optional: See above for sxpanation.
!
! Output:
!   err        -- Logical: err condition
!   v1_ptr     -- Tao_v1_var_struct: pointer to the v1 variable
!   v_array(:) -- Tao_var_array_struct, allocatable, optional: Pointers to the 
!                   variable data point
!   r_array(:) -- Tao_real_array_struct, allocatable, optional: Pointers to all the 
!                   corresponding values.
!   l_array(:) -- Tao_logical_array_struct, allocatable, optional: Pointers logical data.
!   component  -- Character(*), optional: Name of the component. E.G: 'good_user'
!                   set to ' ' if no component present.
!-

subroutine tao_find_var (err, var_name, v1_ptr, v_array, r_array, l_array, &
                               print_err, all_elements, blank_is_null, component)

implicit none

type (tao_v1_var_struct), pointer, optional :: v1_ptr
type (tao_var_array_struct), allocatable, optional    :: v_array(:)
type (tao_real_array_struct), allocatable, optional    :: r_array(:)
type (tao_logical_array_struct), allocatable, optional    :: l_array(:)

integer i, ix, n_var, ios

character(16), parameter :: real_components(10) = &
          (/ 'model   ', 'base    ', 'design  ', 'meas    ', 'ref     ', &
             'old     ', 'step    ', 'weight  ', 'high_lim', 'low_lim ' /)
character(16), parameter :: logic_components(5) = &
          (/ 'exists   ', 'good_var ', 'good_user', 'good_opt ', 'good_plot' /)

character(*) :: var_name
character(*), optional :: component
character(20) :: r_name = 'tao_find_var'
character(80) v1_name, v_name, component_name

logical, optional :: print_err, all_elements, blank_is_null
logical err, component_here, this_err, print_error

! Init

print_error = logic_option(.true., print_err)

if (present(v1_ptr)) nullify (v1_ptr)
if (present(v_array)) then
  if (allocated (v_array)) deallocate (v_array)
endif
if (present(r_array)) then
  if (allocated (r_array)) deallocate (r_array)
endif
if (present(l_array)) then
  if (allocated (l_array)) deallocate (l_array)
endif

err = .true.

! Error if no variables exist

if (s%n_var_used == 0) then
  if (print_error) call out_io (s_error$, r_name, &
                        "NO VARIABLES HAVE BEEN DEFINED IN THE INPUT FILES!")
  return
endif

! Select meas, ref, etc.

ix = index(var_name, '|')
if (ix == 0) then  ! not present
  component_here = .false.
  component_name = ' '   ! garbage
  v1_name = var_name
else
  component_here = .true.
  component_name = var_name(ix+1:)
  v1_name = var_name(:ix-1)
endif
if (present(component)) component = component_name

call string_trim (v1_name, v1_name, ix)
call string_trim (component_name, component_name, ix)

if (component_here) then
  if (.not. any(component_name == real_components) .and. &
      .not. any(component_name == logic_components)) then
    if (print_error) call out_io (s_error$, r_name, "BAD COMPONENT NAME: " // var_name)
    return            
  endif
endif

! split on '['

ix = index(var_name, '[')
if (ix == 0) then
  v_name = ' '
else
  v_name  = v1_name(ix+1:)
  v1_name = v1_name(1:ix-1)
  ix = index(v_name, ']')
  if (ix == 0) then
    if (print_error) call out_io (s_error$, r_name, "NO MATCHING ']': " // var_name)
    return
  endif
  if (v_name(ix+1:) /= ' ') then
    if (print_error) call out_io (s_error$, r_name, "GARBAGE AFTER ']': " // var_name)
    return
  endif
  v_name = v_name(:ix-1)
endif

call string_trim(v1_name, v1_name, ix)
if (ix == 0) then
  if (print_error) call out_io (s_error$, r_name, 'VARIABLE NAME IS BLANK')
  return
endif

! Point to the correct v1 var type 

do i = 1, s%n_v1_var_used
  if (v1_name == '*') then
    call find_this_var (s%v1_var(i), v_name, this_err)
    if (this_err) return
  elseif (v1_name == s%v1_var(i)%name) then
    if (present(v1_ptr)) v1_ptr => s%v1_var(i)
    call find_this_var (s%v1_var(i), v_name, this_err)
    exit
  endif
enddo

! error check

if (err) then
  if (print_error) call out_io (s_error$, r_name, "Couldn't find variable: " // var_name)
  return
endif

!----------------------------------------------------------------------------
contains

subroutine find_this_var (v1, name, this_err)

type (tao_v1_var_struct) :: v1
type (tao_var_array_struct), allocatable, save :: va(:)
type (tao_real_array_struct), allocatable, save :: ra(:)
type (tao_logical_array_struct), allocatable, save :: la(:)

integer i, j, nd, nl, i1, i2, num

character(*) name
character(80) v1_name, v_name

logical this_err
logical, allocatable, save :: list(:)

!

if (allocated(list)) deallocate(list)
i1 = lbound(v1%v, 1)
i2 = ubound(v1%v, 1)
allocate (list(i1:i2))
this_err = .false.

if (logic_option(.false., blank_is_null) .and. name == ' ') then
  err = .false. 
  return

elseif (logic_option(.false., all_elements) .or. name == '*' .or. name == ' ') then
  list = .true.

else
  call location_decode (name, list, i1, num)
  if (num <  1) then
    call out_io (s_error$, r_name, "BAD DATA NUMBER(S): " // var_name)
    this_err = .true.
    return  
  endif
endif

err = .false.
nl = count(list)

! real array

if (present(v_array)) then

  if (allocated(v_array)) then
    nd = size(v_array)
    allocate (va(nd))
    va = v_array
    deallocate(v_array)
    allocate (v_array(nl+nd))
    j = nd
    v_array(1:nd) = va
    deallocate(va)
  else
    allocate (v_array(nl))
    j = 0
  endif

  do i = i1, i2
    if (list(i)) then
      j = j + 1
      v_array(j)%v => v1%v(i)
    endif
  enddo

endif

! real component array

if (present(r_array) .and.  any(component_name == real_components)) then

  if (allocated(r_array)) then
    nd = size(r_array)
    allocate (ra(nd))
    ra = r_array
    deallocate(r_array)
    allocate (r_array(nl+nd))
    j = nd
    r_array(1:nd) = ra
    deallocate(ra)
  else
    allocate (r_array(nl))
    j = 0
  endif

  do i = i1, i2
    if (list(i)) then
      j = j + 1
      select case (component_name)
      case ('model')
        r_array(j)%r => v1%v(i)%model_value
      case ('base')
        r_array(j)%r => v1%v(i)%base_value
      case ('design')
        r_array(j)%r => v1%v(i)%design_value
      case ('meas')
        r_array(j)%r => v1%v(i)%meas_value
      case ('ref')
        r_array(j)%r => v1%v(i)%ref_value
      case ('old')
        r_array(j)%r => v1%v(i)%old_value
      case ('step')
        r_array(j)%r => v1%v(i)%step
      case ('weight')
        r_array(j)%r => v1%v(i)%weight
      case ('high_lim')
        r_array(j)%r => v1%v(i)%high_lim
      case ('low_lim')
        r_array(j)%r => v1%v(i)%low_lim
      case default
        call out_io (s_fatal$, r_name, "INTERNAL ERROR: REAL")
      end select
    endif
  enddo

endif

! logical component array

if (present(l_array) .and. any(component_name == logic_components)) then

  if (allocated(l_array) .and. component_here) then
    nd = size(l_array)
    allocate (la(nd))
    la = l_array
    deallocate(l_array)
    allocate (l_array(nl+nd))
    j = nd
    l_array(1:nd) = la
    deallocate(la)
  else
    allocate (l_array(nl))
    j = 0
  endif

  do i = i1, i2
    if (list(i)) then
      j = j + 1
      select case (component_name)
      case ('exists')
        l_array(j)%l => v1%v(i)%exists
      case ('good_var')
        l_array(j)%l => v1%v(i)%good_var
      case ('good_user')
        l_array(j)%l => v1%v(i)%good_user
      case ('good_opt')
        l_array(j)%l => v1%v(i)%good_opt
      case ('good_plot')
        l_array(j)%l => v1%v(i)%good_plot
      case default
        call out_io (s_fatal$, r_name, "INTERNAL ERROR: LOGIC")
      end select
    endif
  enddo

endif

end subroutine

end subroutine tao_find_var

!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!+
! Subroutine tao_var_target_calc ()
! 
! Subroutine to calculate the variable target values (the values that they need
! to be set to to do a correction of the orbit, phase, etc.
!
! Input:
!
! Output:
!-

subroutine tao_var_target_calc ()

implicit none

type (tao_var_struct), pointer :: var

integer i, j

!

do j = 1, size(s%var)
  var => s%var(j)
  var%correction_value = var%meas_value + (var%design_value - var%model_value)
enddo

end subroutine

!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!+
! Subroutine tao_set_var_model_value (var, value)
!
! Subroutine to set the value for a model variable and do the necessary bookkeeping.
!
! Input:
!   var   -- Tao_var_struct: Variable to set
!   value -- Real(rp): Value to set to
!-

subroutine tao_set_var_model_value (var, value)

implicit none

type (tao_var_struct) var

real(rp) value
integer i

!

if (.not. (var%exists .and. var%good_var)) return

! check if hit variable limit
if (s%global%var_limits_on) then
  if (value .lt. var%low_lim) then
    call out_io (s_blank$, ' ', "Hit lower limit of variable: " // tao_var1_name(var))
    value = var%low_lim
  elseif (value .gt. var%high_lim) then
    call out_io (s_blank$, ' ', "Hit upper limit of variable: " // tao_var1_name(var))
    value = var%high_lim
  endif
endif

var%model_value = value
do i = 1, size(var%this)
  var%this(i)%model_ptr = value
enddo

s%global%lattice_recalc = .true.

end subroutine

!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!+
! subroutine tao_count_strings (string, pattern, num)
! 
! Subroutine to count the number of a specific pattern in the string
!
! Input:    
!  string    -- character(*): the string to look at
!  pattern   -- character(*): the search pattern
!
! Output:
!  num       -- integer: number of occurances
!-

subroutine tao_count_strings (string, pattern, num)

implicit none

character(*) string, pattern

integer num, len_string, len_pattern, i

num = 0
len_pattern = len(pattern)
len_string  = len(string)

do i = 1, len(string)
  if (i+len_pattern-1 .gt. len_string) return
  if (string(i:i+len_pattern-1) .eq. pattern) num = num + 1
enddo

end subroutine tao_count_strings

!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!+
! Subroutine tao_lat_bookkeeper (u, tao_lat)
!
! This will make sure all bookkeeping is up to date
!
! Input:
!  u            -- tao_universe_struct
!  tao_lat      -- tao_lattice_struct
!
! Output:
!  tao_lat      -- ring_struct
!-

subroutine tao_lat_bookkeeper (u, tao_lat)

implicit none

type (tao_universe_struct) :: u
type (tao_lattice_struct) :: tao_lat

character(20) :: r_name = "tao_lat_bookkeeper"

  call lattice_bookkeeper (tao_lat%lat)

end subroutine tao_lat_bookkeeper

!-------------------------------------------------------------------------
!-------------------------------------------------------------------------
!-------------------------------------------------------------------------
!+
! Subroutine tao_to_real (expression, value, err_flag)
!
! Mathematically evaluates a character expression.
!
! Input:
!   expression   -- character(*): arithmetic expression
!  
! Output:
!   value        -- real(rp): Value of arithmetic expression.
!   err_flag     -- Logical: TRUE on error.
!-

subroutine tao_to_real (expression, value, err_flag)

character(*), intent(in) :: expression
real(rp) value
real(rp), allocatable :: vec(:)
logical err_flag

!

call tao_to_real_vector (expression, 'BOTH', vec, err_flag)
if (err_flag) return
value = vec(1)

end subroutine

!-------------------------------------------------------------------------
!-------------------------------------------------------------------------
!-------------------------------------------------------------------------
!+
! Subroutine tao_to_real_vector (expression, wild_type, value, err_flag)
!
! Mathematically evaluates a character expression.
!
! Input:
!   expression   -- Character(*): Arithmetic expression.
!   wild_type    -- Character(*): If something like "*|meas" is in the 
!                     expression does this refer to data or variables? 
!                     Possibilities are "DATA", "VAR", and "BOTH"
!  
! Output:
!   value(:)     -- Real(rp): Value of arithmetic expression.
!   err_flag     -- Logical: TRUE on error.
!-

subroutine tao_to_real_vector (expression, wild_type, value, err_flag)

use random_mod

implicit none

type (eval_stack_struct) stk(200)

integer i_lev, i_op, i, ios, n, n_size, p2, p2_1
integer ptr(-1:200)

integer op_(200), ix_word, i_delim, i2, ix, ix_word2, ixb

real(rp), allocatable :: value(:)

character(*), intent(in) :: expression, wild_type
character(100) phrase
character(1) delim
character(40) word, word2
character(16) :: r_name = "tao_to_real_vector"

logical delim_found, split, ran_function_pending
logical err_flag, err, wild

! Don't destroy the input expression

err_flag = .true.

if (len(expression) .gt. len(phrase)) then
  call out_io (s_warn$, r_name, &
    "Expression cannot be longer than /I3/ characters", len(phrase))
  return
endif
phrase = expression

! if phrase is blank then return 0.0

call string_trim (phrase, phrase, ios)
if (ios == 0) then
  call out_io (s_warn$, r_name, &
    "Expression is blank", len(phrase))
  value = 0.0
  return
endif
 
! General idea: Create a reverse polish stack that represents the expression.
! Reverse polish means that the operand goes last so that 2 * 3 is writen 
! on the stack as: [2, 3, *]

! The stack is called: stk
! Since operations move towards the end of the stack we need a separate
! stack called op_ which keeps track of what operations have not yet
! been put on stk.

! init

err_flag = .false.
i_lev = 0
i_op = 0
ran_function_pending = .false.

! parsing loop to build up the stack.

parsing_loop: do

! get a word

  call word_read (phrase, '+-*/()^,:}[ ', word, ix_word, delim, &
                    delim_found, phrase)

!  if (delim == '*' .and. word(1:1) == '*') then
!    call out_io (s_warn$, r_name, 'EXPONENTIATION SYMBOL IS "^" AS OPPOSED TO "**"')
!    err_flag = .true.
!    return
!  endif

  if (ran_function_pending .and. (ix_word /= 0 .or. delim /= ')')) then
        call out_io (s_warn$, r_name, &
                   'RAN AND RAN_GAUSS DO NOT TAKE AN ARGUMENT')
    err_flag = .true.
    return
  endif

!--------------------------
! Preliminary: If we have split up something that should have not been split
! then put it back together again...

! just make sure we are not chopping a number in two, e.g. "3.5e-7" should not
! get split at the "-" even though "-" is a delimiter

  split = .true.         ! assume initially that we have a split number
  if (ix_word == 0) then
    split = .false.
  elseif (word(ix_word:ix_word) /= 'E' .and. word(ix_word:ix_word) /= 'e' ) then
    split = .false.
  endif
  if (delim /= '-' .and. delim /= '+') split = .false.
  do i = 1, ix_word-1
    if (index('.0123456789', word(i:i)) == 0) split = .false.
  enddo

! If still SPLIT = .TRUE. then we need to unsplit

  if (split) then
    word = word(:ix_word) // delim
    call word_read (phrase, '+-*/()^,:}', word2, ix_word2, delim, &
                    delim_found, phrase)
    word = word(:ix_word+1) // word2
    ix_word = ix_word + ix_word2
  endif

! Something like "lcav[lr(2).freq]" will get split on the "["

  if (delim == '[') then
    call word_read (phrase, ']', word2, ix_word2, delim, &
                    delim_found, phrase)
    if (.not. delim_found) then
      call out_io (s_warn$, r_name, "NO MATCHING ']' FOR OPENING '[':" // expression)
      err_flag = .true.
      return
    endif
    word = word(:ix_word) // '[' // trim(word2) // ']'
    ix_word = ix_word + ix_word2 + 2
    if (phrase(1:1) /= ' ') then  ! even more...
      call word_read (phrase, '+-*/()^,:}', word2, ix_word2, delim, &
                                                  delim_found, phrase)
      word = word(:ix_word) // trim(word2)       
      ix_word = ix_word + ix_word2 
    endif
  endif

! If delim = "*" then see if this is being used as a wildcard

  if (delim == '*') then
    ixb = index(phrase, '|')
    if (ixb /= 0) then
      wild = .true.
      if (index(phrase(1:ixb), '+') /= 0) wild = .false.
      if (index(phrase(1:ixb), '-') /= 0) wild = .false.
      if (index(phrase(1:ixb), '/') /= 0) wild = .false.
      if (index(phrase(1:ixb), '^') /= 0) wild = .false.
      if (index(phrase(1:ixb), '(') /= 0) wild = .false.
      ix = index(phrase(1:ixb), '*')
      if (ix /= 0) then
        if (ix == 1) then
          wild = .false.
        elseif (phrase(ix-1:ix-1) /= '.' .and. phrase(ix-1:ix-1) /= '@') then
          wild = .false.
        endif
      endif
      if (wild) then
        word = word(:ix_word) // '*' // phrase(1:ixb)
        phrase = phrase(ixb+1:)
        call word_read (phrase, '+-*/()^,:}', word2, ix_word2, delim, &
                                                  delim_found, phrase)
        word = trim(word) // trim(word2)       
        ix_word = len_trim(word)
      endif
    endif
  endif

!---------------------------
! Now see what we got...

! For a "(" delim we must have a function

  if (delim == '(') then

    ran_function_pending = .false.
    if (ix_word /= 0) then
      call str_upcase (word2, word)
      select case (word2)
      case ('SIN') 
        call pushit (op_, i_op, sin$)
      case ('COS') 
        call pushit (op_, i_op, cos$)
      case ('TAN') 
        call pushit (op_, i_op, tan$)
      case ('ASIN') 
        call pushit (op_, i_op, asin$)
      case ('ACOS') 
        call pushit (op_, i_op, acos$)
      case ('ATAN') 
        call pushit (op_, i_op, atan$)
      case ('ABS') 
        call pushit (op_, i_op, abs$)
      case ('SQRT') 
        call pushit (op_, i_op, sqrt$)
      case ('LOG') 
        call pushit (op_, i_op, log$)
      case ('EXP') 
        call pushit (op_, i_op, exp$)
      case ('RAN') 
        call pushit (op_, i_op, ran$)
        ran_function_pending = .true.
      case ('RAN_GAUSS') 
        call pushit (op_, i_op, ran_gauss$)
        ran_function_pending = .true.
      case default
        call out_io (s_warn$, r_name, &
               'UNEXPECTED CHARACTERS ON RHS BEFORE "(": ')
        err_flag = .true.
        return
      end select
    endif

    call pushit (op_, i_op, l_parens$)
    cycle parsing_loop

! for a unary "-"

  elseif (delim == '-' .and. ix_word == 0) then
    call pushit (op_, i_op, unary_minus$)
    cycle parsing_loop

! for a unary "+"

    call pushit (op_, i_op, unary_plus$)
    cycle parsing_loop

! for a ")" delim

  elseif (delim == ')') then
    if (ix_word == 0) then
      if (.not. ran_function_pending) call out_io (s_warn$, r_name, &
              'CONSTANT OR VARIABLE MISSING BEFORE ")"')
      err_flag = .true.
      return
    else
      call pushit (stk%type, i_lev, numeric$)
      call read_this_value (word, stk(i_lev))
      if (err_flag) return
    endif

    do
      do i = i_op, 1, -1     ! release pending ops
        if (op_(i) == l_parens$) exit          ! break do loop
        call pushit (stk%type, i_lev, op_(i))
      enddo

      if (i == 0) then
        call out_io (s_warn$, r_name, 'UNMATCHED ")" ON RHS')
        err_flag = .true.
        return
      endif

      i_op = i - 1

      call word_read (phrase, '+-*/()^,:}', word, ix_word, delim, &
                    delim_found, phrase)
      if (ix_word /= 0) then
        call out_io (s_warn$, r_name, &
                   'UNEXPECTED CHARACTERS ON RHS AFTER ")"')
        err_flag = .true.
        return
      endif

      if (delim /= ')') exit  ! if no more ')' then no need to release more
    enddo


    if (delim == '(') then
      call out_io (s_warn$, r_name, '")(" CONSTRUCT DOES NOT MAKE SENSE')
      err_flag = .true.
      return
    endif

! For binary "+-/*^" delims

  else
    if (ix_word == 0) then
      call out_io (s_warn$, r_name, 'CONSTANT OR VARIABLE MISSING')
      err_flag = .true.
      return
    endif
    call pushit (stk%type, i_lev, numeric$)
    call read_this_value (word, stk(i_lev))
    if (err_flag) return
  endif

! If we are here then we have an operation that is waiting to be identified

  if (.not. delim_found) delim = ':'

  select case (delim)
  case ('+')
    i_delim = plus$
  case ('-')
    i_delim = minus$
  case ('*')
    i_delim = times$
  case ('/')
    i_delim = divide$
  case (')')
    i_delim = r_parens$
  case ('^')
    i_delim = power$
  case (',', '}', ':')
    i_delim = no_delim$
  case default
      call out_io (s_error$, r_name, 'INTERNAL ERROR')
      call err_exit
  end select

! now see if there are operations on the OP_ stack that need to be transferred
! to the STK_ stack

  do i = i_op, 1, -1
    if (eval_level(op_(i)) >= eval_level(i_delim)) then
      if (op_(i) == l_parens$) then
        call out_io (s_warn$, r_name, 'UNMATCHED "("')
        err_flag = .true.
        return
      endif
      call pushit (stk%type, i_lev, op_(i))
    else
      exit
    endif
  enddo

! put the pending operation on the OP_ stack

  i_op = i
  if (i_delim == no_delim$) then
    exit parsing_loop
  else
    call pushit (op_, i_op, i_delim)
  endif

enddo parsing_loop

!------------------------------------------------------------------
! Now go through the stack and perform the operations...
! First some error checks

if (i_op /= 0) then
  call out_io (s_warn$, r_name, 'UNMATCHED "("')
  err_flag = .true.
  return
endif

if (i_lev == 0) then
  call out_io (s_warn$, r_name, 'NO VALUE FOUND')
  err_flag = .true.
  return
endif

n_size = 1
do i = 1, i_lev
  if (stk(i)%type /= numeric$) cycle
  n = size(stk(i)%value)
  if (n == 1) cycle
  if (n_size == 1) n_size = n
  if (n /= n_size) then
    call out_io (s_warn$, r_name, 'ARRAY SIZE MISMATCH')
    err_flag = .true.
    return
  endif
enddo

!

i2 = 0  ! stack pointer
do i = 1, i_lev

  p2   = ptr(i2)
  p2_1 = ptr(i2-1)

  select case (stk(i)%type)
  case (numeric$) 
    i2 = i2 + 1
    ptr(i2) = i

  case (unary_minus$) 
    stk(i2)%value = -stk(i2)%value

  case (unary_plus$) 
    stk(i2)%value = stk(i2)%value

  case (plus$) 
    if (size(stk(p2)%value) < size(stk(p2_1)%value)) then
      stk(p2_1)%value = stk(p2_1)%value + stk(p2)%value(1)
    elseif (size(stk(p2)%value) > size(stk(p2_1)%value)) then
      stk(p2)%value = stk(p2_1)%value(1) + stk(p2)%value
      ptr(i2-1) = i2
    else
      stk(p2_1)%value = stk(p2_1)%value + stk(p2)%value
    endif
    i2 = i2 - 1

  case (minus$) 
    if (size(stk(p2)%value) < size(stk(p2_1)%value)) then
      stk(p2_1)%value = stk(p2_1)%value - stk(p2)%value(1)
    elseif (size(stk(p2)%value) > size(stk(p2_1)%value)) then
      stk(p2)%value = stk(p2_1)%value(1) - stk(p2)%value
      ptr(i2-1) = i2
    else
      stk(p2_1)%value = stk(p2_1)%value - stk(p2)%value
    endif
    i2 = i2 - 1

  case (times$) 
    if (size(stk(p2)%value) < size(stk(p2_1)%value)) then
      stk(p2_1)%value = stk(p2_1)%value * stk(p2)%value(1)
    elseif (size(stk(p2)%value) > size(stk(p2_1)%value)) then
      stk(p2)%value = stk(p2_1)%value(1) * stk(p2)%value
      ptr(i2-1) = i2
    else
      stk(p2_1)%value = stk(p2_1)%value * stk(p2)%value
    endif
    i2 = i2 - 1

  case (divide$) 
    if (any(stk(i2)%value == 0)) then
      call out_io  (s_warn$, r_name, 'DIVIDE BY 0 ON RHS')
      err_flag = .true.
      return
    endif
    if (size(stk(p2)%value) < size(stk(p2_1)%value)) then
      stk(p2_1)%value = stk(p2_1)%value / stk(p2)%value(1)
    elseif (size(stk(p2)%value) > size(stk(p2_1)%value)) then
      stk(p2)%value = stk(p2_1)%value(1) / stk(p2)%value
      ptr(i2-1) = i2
    else
      stk(p2_1)%value = stk(p2_1)%value / stk(p2)%value
    endif
    i2 = i2 - 1

  case (power$) 
    if (size(stk(p2)%value) < size(stk(p2_1)%value)) then
      stk(p2_1)%value = stk(p2_1)%value ** stk(p2)%value(1)
    elseif (size(stk(p2)%value) > size(stk(p2_1)%value)) then
      stk(p2)%value = stk(p2_1)%value(1) ** stk(p2)%value
      ptr(i2-1) = i2
    else
      stk(p2_1)%value = stk(p2_1)%value ** stk(p2)%value
    endif
    i2 = i2 - 1

  case (sin$) 
    stk(i2)%value = sin(stk(i2)%value)

  case (cos$) 
    stk(i2)%value = cos(stk(i2)%value)

  case (tan$) 
    stk(i2)%value = tan(stk(i2)%value)

  case (asin$) 
    stk(i2)%value = asin(stk(i2)%value)

  case (acos$) 
    stk(i2)%value = acos(stk(i2)%value)

  case (atan$) 
    stk(i2)%value = atan(stk(i2)%value)

  case (abs$) 
    stk(i2)%value = abs(stk(i2)%value)

  case (sqrt$) 
    stk(i2)%value = sqrt(stk(i2)%value)

  case (log$) 
    stk(i2)%value = log(stk(i2)%value)

  case (exp$) 
    stk(i2)%value = exp(stk(i2)%value)

  case (ran$) 
    i2 = i2 + 1
    call ran_uniform(stk(i2)%value)

  case (ran_gauss$) 
    i2 = i2 + 1
    call ran_gauss(stk(i2)%value)

  case default
    call out_io (s_warn$, r_name, 'INTERNAL ERROR')
    err_flag = .true.
    return
  end select
enddo


if (i2 /= 1) call out_io (s_warn$, r_name, 'INTERNAL ERROR')

if (allocated(value)) deallocate (value)
allocate (value(n_size))
value = stk(ptr(1))%value

contains

!-------------------------------------------------------------------------

subroutine pushit (stack, i_lev, value)

implicit none

integer stack(:), i_lev, value

character(6) :: r_name = "pushit"

!

i_lev = i_lev + 1

if (i_lev > size(stack)) then
  call out_io (s_warn$, r_name, 'STACK OVERFLOW.')
  call err_exit
endif

stack(i_lev) = value

end subroutine pushit
                       
!---------------------------------------------------------------------------
! contains

subroutine read_this_value (str, stack)

character(*) str
type (eval_stack_struct) stack
type (tao_real_array_struct), allocatable :: r_array(:)

!

if (allocated(stack%value)) deallocate (stack%value)

if (is_real(str)) then
  allocate (stack%value(1))
  read (str, *, iostat = ios) stack%value(1)
  if (ios /= 0) then
    call out_io (s_warn$, r_name, "This doesn't seem to be a number: " // str)
    err_flag = .true.
    return
  endif

else
  if (allocated(r_array)) deallocate(r_array)
  if (wild_type == 'DATA' .or. wild_type == 'BOTH') &
               call tao_find_data (err_flag, str, r_array = r_array, print_err = .false.)
  if (.not. allocated(r_array) .and. (wild_type == 'VAR' .or. wild_type == 'BOTH')) &
               call tao_find_var (err_flag, str, r_array = r_array, print_err = .false.)

  if (allocated(r_array)) then
    n = size(r_array)
    allocate (stack%value(n))
    do i = 1, n
      stack%value(i) = r_array(i)%r
    enddo
  else
    call out_io (s_warn$, r_name, "This doesn't seem to be datum or variable value: " // str)
    err_flag = .true.
    return
  endif

endif

end subroutine

end subroutine tao_to_real_vector

!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!+
! Subroutine tao_to_int (str, i_int, err)
! 
! Converts a string to an integer
!
! If the string str is blank then i_int = 0
!-

subroutine tao_to_int (str, i_int, err)

character(*) str
integer ios, i_int
logical err
character(12) :: r_name = "tao_to_int"

!

  call string_trim (str, str, ios)
  if (ios .eq. 0) then
    i_int = 0
    return
  endif
 
  err = .false.
  read (str, *, iostat = ios) i_int

  if (ios /= 0) then
    call out_io (s_error$, r_name, 'EXPECTING INTEGER: ' // str)
    err = .true.
    return
  endif

end subroutine

!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!+
! Function tao_read_this_index (name, ixc) result (ix)
!
! Returns the integer value in the array <name> at position <ixc>. This is used
! for finding a 6-dimensional index reference so any value at <ixc> greater than
! 6 returns an error.
!
! Input:
!  name     -- Character(*): character array holding the index
!  ixc      -- Integer: location within <name> to evaluate
!
! Output:
!  ix       -- Integer: Index at <name>(<ixc>:<ixc>)
!
! Example:
!      name = r:26
!      ixc  = 3
!
! Gives:
!      ix = 3
!
! Example:
!      name = mat_94
!      ixc  = 7
! Gives:
!      Error: "BAD INDEX CONSTRAINT: mat_94"
!-

function tao_read_this_index (name, ixc) result (ix)

  character(*) name
  integer ix, ixc
  character(20) :: r_name = 'tao_read_this_index'

  ix = index('123456', name(ixc:ixc))
  if (ix == 0) then
    call out_io (s_abort$, r_name, 'BAD INDEX CONSTRAINT: ' // name)
    call err_exit
  endif

end function


!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!+
! Function is_real (string, ignore) result (good)
!
! Function to test if a string represents a real number.
! If the ignore argument is present and True then only the first "word" 
! will be considered and the rest of the line will be ignored. 
! For example:
!   print *, is_real('12.3 45.7', .true)   ! Result: True
!   print *, is_real('12.3 45.7')          ! Result: False
!
! Input:
!   string -- Character(*): Character string to check
!   ignore -- Logical, optional: Ignore everything after the first word?
!               Default is False.
!
! Output:
!   good -- Logical: Set True if string represents a real number. 
!                    Set False otherwise.
!-

function is_real (string, ignore) result (good)

implicit none

character(*) string
logical good, digit_found, point_found, exponent_found
logical, optional :: ignore
integer i

! first skip beginning white space

good = .false.

i = 1
do
  if (string(i:i) /= ' ') exit
  i = i + 1
  if (i > len(string)) return
enddo

! look for beginning "+" or "-" sign

if (string(i:i) == '+' .or. string(i:i) == '-') then
  i = i + 1
  if (i > len(string)) return
endif

! look for a digit, '.', or 'e'

digit_found = .false.
point_found = .false.
exponent_found = .false.

do
  if (index ('1234567890', string(i:i)) /= 0) then
    digit_found = .true.
  elseif (string(i:i) == '.') then
    if (point_found) return  ! cannot have two of '.'
    point_found = .true.
  elseif (string(i:i) == 'e' .or. string(i:i) == 'E') then
    exponent_found = .true.
  elseif (string(i:i) == ' ') then
    exit
  else
    return
  endif

  i = i + 1
  if (i > len(string)) then
    good = digit_found .and. .not. exponent_found
    return
  endif

  if (exponent_found) exit

enddo

if (.not. digit_found) return

! Parse the rest of the exponent if needed

if (exponent_found) then

  digit_found = .false.

  if (string(i:i) == '+' .or. string(i:i) == '-') then
    i = i + 1
    if (i > len(string)) return
  endif

  do
    if (index ('1234567890', string(i:i)) /= 0) then
      digit_found = .true.
    elseif (string(i:i) == ' ') then
      exit
    else
      return
    endif

    i = i + 1
    if (i > len(string)) then
      good = digit_found
      return
    endif
  enddo

  if (.not. digit_found) return

endif

! look for something more

good = .true.

if (.not. logic_option(.false., ignore)) then ! if not ignore
  if (string(i:) /= ' ') then
    good = .false.
    return
  endif
endif

end function

!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
! Function tao_var1_name(var) result (var1_name)
!
! Function to return the variable name in the form:
!   var1_name[index]
! For example:
!   quad_k1[23]
!
! Input:
!   var -- Tao_var_struct: Variable
!
! Output:
!   var1_name -- Character(60): Appropriate name.
!-

function tao_var1_name(var) result (var1_name)

implicit none

type (tao_var_struct) var
character(60) var1_name

!

write (var1_name, '(2a, i0, a)') trim(var%v1%name), '[', var%ix_v1, ']'

end function

!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
! Function tao_datum_name (datum) result (datum_name)
!
! Function to return the datum name in the form:
!   d2_name.d1_name[index]
! For example:
!   orbit.x[23]
!
! Input:
!   datum -- Tao_data_struct: Datum
!
! Output:
!   datum_name -- Character(60): Appropriate name.
!-

function tao_datum_name(datum) result (datum_name)

implicit none

type (tao_data_struct) datum
character(60) datum_name

!

write (datum_name, '(4a, i0, a)') &
      trim(datum%d1%d2%name), '.', trim(datum%d1%name), '[', datum%ix_d1, ']'

end function

!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!+
! Function is_logical (string, ignore) result (good)
!
! Function to test if a string represents a logical.
! Accepted possibilities are (individual characters can be either case):
!   .TRUE.  .FALSE. 
!    TRUE    FALSE
!    T       F
! If the ignore argument is present and True then only the first "word" 
! will be considered and the rest of the line will be ignored. 
! For example:
!   print *, is_logical('F F', .true.)  ! Result: True
!   print *, is_logical('F F')          ! Result: False
!
! Input:
!   string -- Character(*): Character string to check
!   ignore -- Logical, optional: Ignore everything after the first word?
!               Default is False.
!
! Output:
!   good -- Logical: Set True if string represents a logical. 
!                    Set False otherwise.
!-

function is_logical (string, ignore) result (good)

implicit none

character(*) string
character(8) tf
logical good
logical, optional :: ignore
integer i

! first skip beginning white space

good = .false.

i = 1
do
  if (string(i:i) /= ' ') exit
  i = i + 1
  if (i > len(string)) return
enddo

! check first word

tf = string(i:)
call str_upcase (tf, tf)

if (tf == '.TRUE. ') then
  i = i + 6
elseif (tf == 'TRUE ') then
  i = i + 4
elseif (tf == 'T ') then
  i = i + 1
elseif (tf == '.FALSE. ') then
  i = i + 7
elseif (tf == 'FALSE ') then
  i = i + 5
elseif (tf == 'F ') then
  i = i + 1
else
  return
endif

good = .true.
if (i > len(string)) return

! check for garbage after the first word

if (.not. logic_option(.false., ignore)) then ! if not ignore
  if (string(i:) /= ' ') then
    good = .false.
    return
  endif
endif

end function

!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!+
! Subroutine tao_update_var_values ()
!
! This will update the s%var(*)%model_value and s%var(*)%base_value to 
! reflect the actual values in the lattice. This is needed for example if a
! element values is changed using the 'change ele' command where a tao variable
! also controls the element value. The variable must be updated to refelct the
! change.
!
! If the variables controls element in multiple universe as a 'clone' then the
! value in the currently displayed universe will be used.
!
! Input: 
!  none
!
! Ouput:
!  s%var(*)%model_value  -- Real(rp): value updated to reflect lattice
!  s%var(*)%base_value   -- Real(rp): value updated to reflect lattice
!-

Subroutine tao_update_var_values ()

implicit none

integer i_var, i_this, ix_this

  do i_var = 1, size(s%var)
    ix_this = -1
    if (.not. allocated(s%var(i_var)%this)) cycle
    do i_this = 1, size(s%var(i_var)%this)
      if (s%var(i_var)%this(i_this)%ix_uni .eq. s%global%u_view) &
              ix_this = i_this
    enddo
    if (ix_this .eq. -1) cycle
    s%var(i_var)%model_value = s%var(i_var)%this(ix_this)%model_ptr
    s%var(i_var)%base_value = s%var(i_var)%this(ix_this)%base_ptr
  enddo

end subroutine tao_update_var_values


end module tao_utils
