set (EXENAME math_test)
set (SRC_FILES
  math_test/math_test.f90
)

set (INC_DIRS
)

set (LINK_LIBS
  bmad 
  sim_utils
  recipes_f-90_LEPP 
  forest 
)