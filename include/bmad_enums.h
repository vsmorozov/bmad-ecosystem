
//+
// C++ constants equivalent to Bmad parameters.
//
// This file is generated as part of the Bmad/C++ interface code generation.
// The code generation files can be found in cpp_bmad_interface.
//
// DO NOT EDIT THIS FILE DIRECTLY! 
//-

#ifndef BMAD_ENUMS

// The TRUE/FALSE stuff is to get around a problem with TRUE and FALSE being defined using #define

#ifdef TRUE
#undef TRUE
#define TRUE_DEF
#endif

#ifdef FALSE
#undef FALSE
#define FALSE_DEF
#endif

namespace Bmad {
  const int BMAD_INC_VERSION = 270;
  const int N_POLE_MAXX = 21;
  const int OLD_CONTROL_VAR_OFFSET = 1000;
  const int VAR_OFFSET = 2000;
  const int N_VAR_MAX = 999;
  const int TAYLOR_OFFSET = 1000000000;
  const int BMAD_STANDARD = 1, SYMP_LIE_PTC = 2, RUNGE_KUTTA = 3;
  const int LINEAR = 4, TRACKING = 5, TIME_RUNGE_KUTTA = 6;
  const int FIXED_STEP_RUNGE_KUTTA = 9, SYMP_LIE_BMAD = 10, STATIC = 11;
  const int SPRINT = 12, FIXED_STEP_TIME_RUNGE_KUTTA = 13, MAD = 14;
  const int N_METHODS = 14;
  const int DRIFT_KICK = 1, MATRIX_KICK = 2, RIPKEN_KICK = 3;
  const int SECTOR = 1, STRAIGHT = 2;
  const int FIELDMAP = 2, PLANAR_MODEL = 3, REFER_TO_LORDS = 4, NO_FIELD = 5;
  const int HELICAL_MODEL = 6, SOFT_EDGE = 8;
  const int UNIFORM = 1, GAUSSIAN = 2, SPHERICAL = 3;
  const int IX_SLICE_SLAVE = -2;
  const int MINOR_SLAVE = 1, SUPER_SLAVE = 2, FREE = 3;
  const int GROUP_LORD = 4, SUPER_LORD = 5, OVERLAY_LORD = 6;
  const int GIRDER_LORD = 7, MULTIPASS_LORD = 8, MULTIPASS_SLAVE = 9;
  const int NOT_A_LORD = 10, SLICE_SLAVE = 11, CONTROL_LORD = 12, RAMPER_LORD = 13;
  const int AUTO_APERTURE = 1, RECTANGULAR = 2, ELLIPTICAL = 3, WALL3D = 5, CUSTOM_APERTURE = 7;
  const int SOFT_EDGE_ONLY = 2, HARD_EDGE_ONLY = 3, FULL = 4;
  const int SAD_FULL = 5, LINEAR_EDGE = 6, BASIC_BEND = 7;
  const int STANDING_WAVE = 1, TRAVELING_WAVE = 2, PTC_STANDARD = 3;
  const int X_INVARIANT = 1, MULTIPOLE_SYMMETRY = 2;
  const int CONTROL_VAR = 1, OLD_CONTROL_VAR = 2, ALL_CONTROL_VAR = 3, ELEC_MULTIPOLE = 4;
  const int OK = 1, IN_STOP_BAND = 2, NON_SYMPLECTIC = 3, UNSTABLE = 4;
  const int UNSTABLE_A = 5, UNSTABLE_B = 6;
  const int XFER_MAT_CALC_FAILURE = 7, TWISS_PROPAGATE_FAILURE = 8, NO_CLOSED_ORBIT = 9;
  const int INCLUDE_KICKS = 1;
  const int USER_SET = 0, FIRST_PASS = 1;
  const int ASCII = 1, BINARY = 2, HDF5 = 3, ONE_FILE = 4;
  const int NUM_ELE_ATTRIB = 75;
  const int OFF = 1, ON = 2;
  const int NONE = 1;
  const int SAVE_STATE = 3, RESTORE_STATE = 4, OFF_AND_SAVE = 5;
  const int HORIZONTALLY_PURE = 2, VERTICALLY_PURE = 3;
  const int ONE_DIM = 2, STEADY_STATE_3D = 3;
  const int SLICE = 2, FFT_3D = 3;
  const int MAGNETIC = 1, ELECTRIC = 2, MIXED = 3;
  const int BRAGG_DIFFRACTED = 1, FORWARD_DIFFRACTED = 2, UNDIFFRACTED = 3;
  const int REFLECTION = 1, TRANSMISSION = 2;
  const int ANCHOR_BEGINNING = 1, ANCHOR_CENTER = 2, ANCHOR_END = 3;
  const int ENTRANCE_END = 1, EXIT_END = 2, BOTH_ENDS = 3, NO_END = 4, NO_APERTURE = 4, NOWHERE = 4;
  const int CONTINUOUS = 5, SURFACE = 6, WALL_TRANSITION = 7;
  const int FIRST_TRACK_EDGE = 11, SECOND_TRACK_EDGE = 12, IN_BETWEEN = 13;
  const int UPSTREAM_END = 1, DOWNSTREAM_END = 2;
  const int INSIDE = 3, CENTER_PT = 3, START_END = 99;
  const int NORMAL = 1, CLEAR = 2, OPAQUE = 3, WALL_START = 9, WALL_END = 10;
  const int ABSOLUTE = 1, RELATIVE = 2, SHIFTED_TO_RELATIVE = 3;
  const int CHAMBER_WALL = 1, MASK_PLATE = 2;
  const int X_PLANE = 1, Y_PLANE = 2;
  const int Z_PLANE = 3, N_PLANE = 4, S_PLANE = 5;
  const int MOVING_FORWARD = -9;
  const int ALIVE = 1, LOST = 2;
  const int LOST_NEG_X_APERTURE = 3, LOST_POS_X_APERTURE = 4;
  const int LOST_NEG_Y_APERTURE = 5, LOST_POS_Y_APERTURE = 6;
  const int LOST_PZ_APERTURE = 7;
  const int PRE_BORN = 8;
  const int LOST_Z_APERTURE = 9;
  const int X_POLARIZATION = 2, Y_POLARIZATION = 3;
  const int LEADING = 2, TRAILING = 3;
  const int X_LEADING = 2, Y_LEADING = 3, X_TRAILING = 4, Y_TRAILING = 5;
  const int FAMILY_Y = 1, FAMILY_X = 2, FAMILY_QU = 3, FAMILY_SQ = 4;
  const int HYPER_Y = 1, HYPER_XY = 2, HYPER_X = 3;
  const int SUPER_OK = 0, STALE = 2;
  const int ATTRIBUTE_GROUP = 1, CONTROL_GROUP = 2, FLOOR_POSITION_GROUP = 3;
  const int S_POSITION_GROUP = 4, REF_ENERGY_GROUP = 5, MAT6_GROUP = 6;
  const int RAD_INT_GROUP = 7, ALL_GROUPS = 8, S_AND_FLOOR_POSITION_GROUP = 9;
  const int SEGMENTED = 1, H_MISALIGN = 2, DISPLACEMENT = 3;
  const int EXPRESSION = 2, SPLINE = 3;
  const int INCOHERENT = 1, COHERENT = 2;
  const int OPAL = 1, IMPACTT = 2;
  const int DRIFT = 1, SBEND = 2, QUADRUPOLE = 3, GROUP = 4, SEXTUPOLE = 5;
  const int OVERLAY = 6, CUSTOM = 7, TAYLOR = 8, RFCAVITY = 9, ELSEPARATOR = 10;
  const int BEAMBEAM = 11, WIGGLER = 12, SOL_QUAD = 13, MARKER = 14, KICKER = 15;
  const int HYBRID = 16, OCTUPOLE = 17, RBEND = 18, MULTIPOLE = 19, DEF_BMAD_COM = 20;
  const int DEF_MAD_BEAM = 21, AB_MULTIPOLE = 22, SOLENOID = 23, PATCH = 24, LCAVITY = 25;
  const int DEF_PARAMETER = 26, NULL_ELE = 27, BEGINNING_ELE = 28, DEF_LINE = 29;
  const int MATCH = 30, MONITOR = 31, INSTRUMENT = 32, HKICKER = 33, VKICKER = 34;
  const int RCOLLIMATOR = 35, ECOLLIMATOR = 36, GIRDER = 37, CONVERTER = 38;
  const int DEF_PARTICLE_START = 39, PHOTON_FORK = 40, FORK = 41, MIRROR = 42, CRYSTAL = 43;
  const int PIPE = 44, CAPILLARY = 45, MULTILAYER_MIRROR = 46, E_GUN = 47, EM_FIELD = 48;
  const int FLOOR_SHIFT = 49, FIDUCIAL = 50, UNDULATOR = 51, DIFFRACTION_PLATE = 52;
  const int PHOTON_INIT = 53, SAMPLE = 54, DETECTOR = 55, SAD_MULT = 56, MASK = 57;
  const int AC_KICKER = 58, LENS = 59, BEAM_INIT = 60, CRAB_CAVITY = 61, RAMPER = 62;
  const int DEF_PTC_COM = 63;
  const int N_KEY = 63;
  const int VAL1=11, VAL2=12, VAL3=13, VAL4=14, VAL5=15, 
            VAL6=16, VAL7=17, VAL8=18, VAL9=19, VAL10=20, VAL11=21, 
            VAL12=22;
  const int BETA_A0 = 2, ALPHA_A0 = 3, BETA_B0 = 4, ALPHA_B0 = 5;
  const int BETA_A1 = 6, ALPHA_A1 = 7, BETA_B1 = 8, ALPHA_B1 = 9;
  const int DPHI_A = 10, DPHI_B = 11;
  const int ETA_X0 = 12, ETAP_X0 = 13, ETA_Y0 = 14, ETAP_Y0 = 15;
  const int ETA_X1 = 16, ETAP_X1 = 17, ETA_Y1 = 18, ETAP_Y1 = 19;
  const int C11_MAT0 = 20, C12_MAT0 = 21, C21_MAT0 = 22, C22_MAT0 = 23;
  const int C11_MAT1 = 24, C12_MAT1 = 25, C21_MAT1 = 26, C22_MAT1 = 27;
  const int X0 = 28, PX0 = 29, Y0 = 30, PY0 = 31, Z0 = 32, PZ0 = 33;
  const int X1 = 34, PX1 = 35, Y1 = 36, PY1 = 37, Z1 = 38, PZ1 = 39;
  const int PHASE_TROMBONE_INPUT = 40, PHASE_TROMBONE = 41;
  const int MATCH_END_INPUT = 42, MATCH_END = 43;
  const int MATCH_END_ORBIT_INPUT = 44, MATCH_END_ORBIT = 45;
  const int DELTA_TIME = 46;
  const int X = 1, PX = 2, Y = 3, PY = 4, Z = 5, PZ = 6;
  const int T = 8;
  const int FIELD_X = 10, FIELD_Y = 11, PHASE_X = 12, PHASE_Y = 13;
  const int E_PHOTON = 9;
  const int E1 = 19, E2 = 20;
  const int FINT = 21, FINTX = 22, HGAP = 23, HGAPX = 24, H1 = 25, H2 = 26;
  const int RADIUS = 3, FOCAL_STRENGTH = 5;
  const int L = 1;
  const int TILT = 2, ROLL = 2, N_PART = 2, INHERIT_FROM_FORK = 2;
  const int REF_TILT = 3, RF_FREQUENCY = 3, DIRECTION = 3, REF_TIME_OFFSET = 3;
  const int KICK = 3, X_GAIN_ERR = 3, TAYLOR_ORDER = 3, R_SOLENOID = 3;
  const int RF_FREQUENCY_ERR = 4, K1 = 4, KX = 4, HARMON = 4, H_DISPLACE = 4, Y_GAIN_ERR = 4;
  const int CRITICAL_ANGLE_FACTOR = 4, TILT_CORR = 4, REF_COORDS = 4, L_CATHODE_REGION = 4;
  const int GRAZE_ANGLE = 5, K2 = 5, B_MAX = 5, V_DISPLACE = 5, DRIFT_ID = 5, RF_WAVELENGTH = 5;
  const int KS = 5, FLEXIBLE = 5, CRUNCH = 5, REF_ORBIT_FOLLOWS = 5, PC_OUT_MIN = 5;
  const int GRADIENT = 6, K3 = 6, NOISE = 6, NEW_BRANCH = 6, IX_BRANCH = 6, G_MAX = 6;
  const int G = 6, SYMMETRY = 6, FIELD_SCALE_FACTOR = 6, PC_OUT_MAX = 6;
  const int DG = 7, BBI_CONST = 7, OSC_AMPLITUDE = 7, IX_TO_BRANCH = 7, ANGLE_OUT_MAX = 7;
  const int GRADIENT_ERR = 7, CRITICAL_ANGLE = 7, SAD_FLAG = 7, BRAGG_ANGLE_IN = 7;
  const int RHO = 8, DELTA_E_REF = 8, INTERPOLATION = 8, BRAGG_ANGLE_OUT = 8, K1X = 8;
  const int CHARGE = 8, X_GAIN_CALIB = 8, IX_TO_ELEMENT = 8, VOLTAGE = 8;
  const int EPS_STEP_SCALE = 9, VOLTAGE_ERR = 9, BRAGG_ANGLE = 9, K1Y = 9;
  const int FRINGE_TYPE = 10, DBRAGG_ANGLE_DE = 10;
  const int FRINGE_AT = 11, GANG = 11, DARWIN_WIDTH_SIGMA = 11;
  const int HIGHER_ORDER_FRINGE_TYPE = 12, DARWIN_WIDTH_PI = 12;
  const int SPIN_FRINGE_ON = 13, PENDELLOSUNG_PERIOD_SIGMA = 13;
  const int SIG_X = 14, EXACT_MULTIPOLES = 14, PENDELLOSUNG_PERIOD_PI = 14;
  const int SIG_Y = 15, GRAZE_ANGLE_IN = 15, R0_ELEC = 15;
  const int SIG_Z = 16, GRAZE_ANGLE_OUT = 16, R0_MAG = 16;
  const int SIG_VX = 17;
  const int SIG_VY = 18, AUTOSCALE_AMPLITUDE = 18;
  const int SIG_E = 19, AUTOSCALE_PHASE = 19, SIG_PZ = 19;
  const int D1_THICKNESS = 20, DEFAULT_TRACKING_SPECIES = 20, DIRECTION_PARTICLE_START = 20;
  const int N_SLICE = 20, Y_GAIN_CALIB = 20, CONSTANT_REF_ENERGY = 20;
  const int LONGITUDINAL_MODE = 20, SIG_E2 = 20;
  const int FB1 = 21, POLARITY = 21, CRUNCH_CALIB = 21, ALPHA_ANGLE = 21, D2_THICKNESS = 21;
  const int BETA_A_STRONG = 21, BETA_A_OUT = 21, E_LOSS = 21, GAP = 21, SPIN_X = 21, E_CENTER = 21;
  const int FB2 = 22, X_OFFSET_CALIB = 22, V1_UNITCELL = 22, PSI_ANGLE = 22, DT_MAX = 22;
  const int BETA_B_STRONG = 22, BETA_B_OUT = 22, SPIN_Y = 22, E2_CENTER = 22, N_PERIOD = 22;
  const int Y_OFFSET_CALIB = 23, V_UNITCELL = 23, V2_UNITCELL = 23, SPIN_Z = 23, L_PERIOD = 23;
  const int FQ1 = 23, ALPHA_A_STRONG = 23, ALPHA_A_OUT = 23, CAVITY_TYPE = 23, E2_PROBABILITY = 23;
  const int EMIT_FRACTION = 23;
  const int FQ2 = 24, PHI0 = 24, TILT_CALIB = 24, E_CENTER_RELATIVE_TO_REF = 24;
  const int ALPHA_B_STRONG = 24, ALPHA_B_OUT = 24, IS_MOSAIC = 24, PX_APERTURE_WIDTH2 = 24;
  const int PHI0_ERR = 25, CURRENT = 25, MOSAIC_THICKNESS = 25, PX_APERTURE_CENTER = 25;
  const int ETA_X_OUT = 25, QUAD_TILT = 25, DE_ETA_MEAS = 25, SPATIAL_DISTRIBUTION = 25;
  const int ETA_Y_OUT = 26, BEND_TILT = 26, MODE = 26, VELOCITY_DISTRIBUTION = 26, PY_APERTURE_WIDTH2 = 26;
  const int PHI0_MULTIPASS = 26, N_SAMPLE = 26, ORIGIN_ELE_REF_PT = 26, MOSAIC_ANGLE_RMS_IN_PLANE = 26;
  const int ETAP_X_OUT = 27, PHI0_AUTOSCALE = 27, DX_ORIGIN = 27, ENERGY_DISTRIBUTION = 27;
  const int X_QUAD = 27, DS_PHOTON_SLICE = 27, MOSAIC_ANGLE_RMS_OUT_PLANE = 27;
  const int PY_APERTURE_CENTER = 27, DPZ_RAD_DAMP_AVE = 27, X_DISPERSION_ERR = 27;
  const int ETAP_Y_OUT = 28, PHI0_MAX = 28, DY_ORIGIN = 28, Y_QUAD = 28, E_FIELD_X = 28;
  const int Y_DISPERSION_ERR = 28, Z_APERTURE_WIDTH2 = 28;
  const int UPSTREAM_COORD_DIR = 29, DZ_ORIGIN = 29, MOSAIC_DIFFRACTION_NUM = 29, Z_APERTURE_CENTER = 29;
  const int CMAT_11 = 29, FIELD_AUTOSCALE = 29, L_SAGITTA = 29, E_FIELD_Y = 29, X_DISPERSION_CALIB = 29;
  const int CMAT_12 = 30, DTHETA_ORIGIN = 30, B_PARAM = 30, L_CHORD = 30, SCALE_FIELD_TO_ONE = 30;
  const int DOWNSTREAM_COORD_DIR = 30, PZ_APERTURE_WIDTH2 = 30, Y_DISPERSION_CALIB = 30;
  const int CMAT_21 = 31, L_ACTIVE = 31, DPHI_ORIGIN = 31, REF_CAP_GAMMA = 31;
  const int L_SOFT_EDGE = 31, TRANSVERSE_SIGMA_CUT = 31, PZ_APERTURE_CENTER = 31;
  const int CMAT_22 = 32, DPSI_ORIGIN = 32, T_OFFSET = 32, DS_SLICE = 32;
  const int ANGLE = 33, N_CELL = 33;
  const int X_PITCH = 34;
  const int Y_PITCH = 35;
  const int X_OFFSET = 36;
  const int Y_OFFSET = 37;
  const int Z_OFFSET = 38;
  const int HKICK = 39, D_SPACING = 39, X_OFFSET_MULT = 39, EMITTANCE_A = 39, CRAB_X1 = 39;
  const int VKICK = 40, Y_OFFSET_MULT = 40, P0C_REF_INIT = 40, EMITTANCE_B = 40, CRAB_X2 = 40;
  const int BL_HKICK = 41, X_PITCH_MULT = 41, E_TOT_REF_INIT = 41, EMITTANCE_Z = 41, CRAB_X3 = 41;
  const int BL_VKICK = 42, Y_PITCH_MULT = 42, CRAB_TILT = 42;
  const int BL_KICK = 43, B_FIELD = 43, E_FIELD = 43, HIGH_ENERGY_SPACE_CHARGE_ON = 43;
  const int PHOTON_TYPE = 44, COUPLER_PHASE = 44, DB_FIELD = 44;
  const int LATTICE_TYPE = 45, B1_GRADIENT = 45, E1_GRADIENT = 45, COUPLER_ANGLE = 45;
  const int LIVE_BRANCH = 46, B2_GRADIENT = 46, E2_GRADIENT = 46, COUPLER_STRENGTH = 46;
  const int GEOMETRY = 47, COUPLER_AT = 47, E_TOT_SET = 47, PTC_CANONICAL_COORDS = 47;
  const int B3_GRADIENT = 48, E3_GRADIENT = 48, PTC_FRINGE_GEOMETRY = 48, P0C_SET = 48;
  const int BS_FIELD = 49, E_TOT_OFFSET = 49, PTC_FIELD_GEOMETRY = 49;
  const int DELTA_REF_TIME = 50;
  const int P0C_START = 51;
  const int E_TOT_START = 52;
  const int P0C = 53;
  const int E_TOT = 54;
  const int X_PITCH_TOT = 55, NO_END_MARKER = 55;
  const int Y_PITCH_TOT = 56;
  const int X_OFFSET_TOT = 57;
  const int Y_OFFSET_TOT = 58;
  const int Z_OFFSET_TOT = 59;
  const int TILT_TOT = 60, ROLL_TOT = 60;
  const int REF_TILT_TOT = 61;
  const int MULTIPASS_REF_ENERGY = 62;
  const int REF_TIME_START = 64;
  const int THICKNESS = 65, INTEGRATOR_ORDER = 65;
  const int NUM_STEPS = 66;
  const int DS_STEP = 67;
  const int CSR_DS_STEP = 68;
  const int LORD_PAD1 = 69;
  const int LORD_PAD2 = 70, REF_WAVELENGTH = 70;
  const int X1_LIMIT = 71;
  const int X2_LIMIT = 72;
  const int Y1_LIMIT = 73;
  const int Y2_LIMIT = 74;
  const int CHECK_SUM = 75;
  const int G_ERR = DG;
  const int B_FIELD_ERR = DB_FIELD;
  const int SPHERICAL_CURVATURE = 81, DISTRIBUTION = 81;
  const int TT = 81, X_KNOT = 81;
  const int ALIAS  = 82, MAX_FRINGE_ORDER = 82, ETA_X = 82;
  const int ELECTRIC_DIPOLE_MOMENT = 83, LR_SELF_WAKE_ON = 83, X_REF = 83, SPECIES_OUT = 83;
  const int Y_KNOT = 83, ETA_Y = 83;
  const int LR_WAKE_FILE = 84, PX_REF = 84, ELLIPTICAL_CURVATURE_X = 84, ETAP_X = 84, SLAVE = 84;
  const int LR_FREQ_SPREAD = 85, Y_REF = 85, ELLIPTICAL_CURVATURE_Y = 85, ETAP_Y = 85;
  const int LATTICE = 86, PHI_A = 86, MULTIPOLES_ON = 86, PY_REF = 86, ELLIPTICAL_CURVATURE_Z = 86;
  const int APERTURE_TYPE = 87, ETA_Z = 87, MACHINE = 87;
  const int TAYLOR_MAP_INCLUDES_OFFSETS = 88, PIXEL = 88, P88 = 88;
  const int CSR_METHOD = 89, VAR = 89, Z_REF = 89, P89 = 89;
  const int PZ_REF = 90, SPACE_CHARGE_METHOD = 90, P90 = 90;
  const int MAT6_CALC_METHOD = 91;
  const int TRACKING_METHOD  = 92, S_LONG = 92;
  const int REF_TIME = 93, PTC_INTEGRATION_TYPE = 93;
  const int SPIN_TRACKING_METHOD = 94, ETA_A = 94;
  const int APERTURE = 95, ETAP_A = 95;
  const int X_LIMIT = 96, ABSOLUTE_TIME_TRACKING = 96, ETA_B = 96;
  const int Y_LIMIT = 97, ETAP_B = 97;
  const int OFFSET_MOVES_APERTURE = 98;
  const int APERTURE_LIMIT_ON = 99, ALPHA_A = 99;
  const int EXACT_MISALIGN = 100, PHYSICAL_SOURCE = 100;
  const int SR_WAKE_FILE = 100, ALPHA_B = 100;
  const int TERM = 101, FREQUENCIES = 101, OLD_INTEGRATOR = 101, CURVATURE = 101;
  const int X_POSITION = 102, EXACT_MODEL = 102;
  const int SYMPLECTIFY = 103, Y_POSITION = 103, N_SLICE_SPLINE = 103;
  const int Z_POSITION = 104, AMP_VS_TIME = 104;
  const int IS_ON = 105, THETA_POSITION = 105;
  const int FIELD_CALC = 106, PHI_POSITION = 106;
  const int PSI_POSITION = 107, WALL = 107;
  const int APERTURE_AT = 108, BETA_A = 108;
  const int RAN_SEED = 109, ORIGIN_ELE = 109, BETA_B = 109;
  const int TO_LINE = 110, FIELD_OVERLAPS = 110;
  const int FIELD_MASTER = 111, TO_ELEMENT = 111;
  const int DESCRIP = 112;
  const int SCALE_MULTIPOLES = 113;
  const int SR_WAKE = 114;
  const int REF_ORBIT = 115, LR_WAKE = 115;
  const int PHI_B = 116, CRYSTAL_TYPE = 116, MATERIAL_TYPE = 116;
  const int TYPE = 117;
  const int REF_ORIGIN = 118;
  const int ELE_ORIGIN = 119;
  const int SUPERIMPOSE     = 120;
  const int SUPER_OFFSET    = 121;
  const int REFERENCE       = 122;
  const int CARTESIAN_MAP   = 123;
  const int CYLINDRICAL_MAP = 124;
  const int GRID_FIELD      = 125;
  const int TAYLOR_FIELD    = 126;
  const int CREATE_JUMBO_SLAVE = 127;
  const int ACCORDION_EDGE  = 128;
  const int START_EDGE  = 129;
  const int END_EDGE  = 130;
  const int S_POSITION = 131;
  const int REF_SPECIES = 132, PARTICLE = 132;
  const int WRAP_SUPERIMPOSE = 133;
  const int A0  = 140, A21  = 161;
  const int B0  = 162, B21  = 183;
  const int K0L = 140, K21L = 161;
  const int T0  = 162, T21  = 183;
  const int K0SL = 190, K21SL = 211;
  const int A0_ELEC = 190, A21_ELEC = 211;
  const int B0_ELEC = 212, B21_ELEC = 233;
  const int CUSTOM_ATTRIBUTE0 = B21_ELEC;
  const int CUSTOM_ATTRIBUTE_NUM = 40;
  const int NUM_ELE_ATTRIB_EXTENDED = CUSTOM_ATTRIBUTE0 + CUSTOM_ATTRIBUTE_NUM;
  const int OPEN = 1, CLOSED = 2;
  const int BENDS = 201;
  const int WIGGLERS = 202;
  const int ALL = 203;
  const int RADIANS = 1, DEGREES = 2, CYCLES = 3, RADIANS_OVER_2PI = 3;
  const int ROTATIONALLY_SYMMETRIC_RZ = 1, XYZ = 2;
  const int INVALID_NAME = 0, IS_LOGICAL = 1, IS_INTEGER = 2, IS_REAL = 3, IS_SWITCH = 4, IS_STRING = 5;
  const int IS_STRUCT = 6, UNKNOWN = 7;
  const int PATCH_PROBLEM = 2, OUTSIDE = 3, CANNOT_FIND = 4;
  const double SMALL_REL_CHANGE = 1E-14;
  const int S_NOOUTPUT  = -2;
  const int S_BLANK     = -1;
  const int S_INFO      = 0;
  const int S_DINFO     = 1;
  const int S_SUCCESS   = 2;
  const int S_WARN      = 3;
  const int S_DWARN     = 5;
  const int S_ERROR     = 7;
  const int S_FATAL     = 8;
  const int S_ABORT     = 9;
  const int S_IMPORTANT = 10;
  const double PI = 3.141592653589793238462643383279E0;
  const double TWOPI = 2 * PI;
  const double FOURPI = 4 * PI;
  const double SQRT_2 = 1.414213562373095048801688724209698;
  const double SQRT_3 = 1.732050807568877293527446341505872;
  const double M_ELECTRON = 0.51099895000E6;
  const double M_PROTON   = 0.93827208816E9;
  const double M_NEUTRON  = 0.93956542052E9;
  const double M_MUON     = 105.6583755E6;
  const double E_MASS = 1E-9 * M_ELECTRON;
  const double P_MASS   = 1E-9 * M_PROTON;
  const double M_PION_0 = 134.9766E6;
  const double M_PION_CHARGED = 139.57018E6;
  const double M_DEUTERON = 1.87561294257E9;
  const double ATOMIC_MASS_UNIT = 931.49410242E6;
  const double C_LIGHT = 2.99792458E8;
  const double R_E = 2.8179403262E-15;
  const double R_P = R_E * M_ELECTRON / M_PROTON;
  const double E_CHARGE = 1.602176634E-19;
  const double H_PLANCK = 4.135667696E-15;
  const double H_BAR_PLANCK = H_PLANCK / TWOPI;
  const double MU_0_VAC = 1.25663706212E-6;
  const double CLASSICAL_RADIUS_FACTOR = R_E * M_ELECTRON;
  const double N_AVOGADRO = 6.02214076E23;
  const double FINE_STRUCTURE_CONSTANT =  7.2973525693E-3;
  const double ANOMALOUS_MAG_MOMENT_ELECTRON = 1.15965218128E-3;
  const double ANOMALOUS_MAG_MOMENT_PROTON   = 1.79284734463E0;
  const double ANOMALOUS_MAG_MOMENT_MUON     = 1.16592089E-3;
  const double ANOMALOUS_MAG_MOMENT_DEUTERON = -0.14298726925E0;
  const double ANOMALOUS_MAG_MOMENT_NEUTRON  = -1.91304273E0;
  const double ANOMALOUS_MAG_MOMENT_HE3      = -4.184153686E0;
  const int PION_0            = +8;
  const int REF_PARTICLE      = +7;
  const int NEUTRON            = +6;
  const int DEUTERON          = +5;
  const int PION_PLUS         = +4;
  const int ANTIMUON          = +3;
  const int PROTON            = +2;
  const int POSITRON          = +1;
  const int PHOTON            =  0;
  const int ELECTRON          = -1;
  const int ANTIPROTON        = -2;
  const int MUON              = -3;
  const int PION_MINUS        = -4;
  const int ANTI_DEUTERON     = -5;
  const int ANTI_NEUTRON       = -6;
  const int ANTI_REF_PARTICLE = -7;
  const int LBOUND_SUBATOMIC = -7, UBOUND_SUBATOMIC = 8;
  const int INT_GARBAGE = -987654;
  const double REAL_GARBAGE = -987654.3;
  const int INVALID = -666;
  const int NOT_SET = -999;
  const int X_AXIS = 1, Y_AXIS = 2, Z_AXIS = 3;
  const double TRUE = 1, FALSE = 0;
  const int TRUE_INT = 1, FALSE_INT = 0;
  const int YES = 1, NO = 0, MAYBE = 2, PROVISIONAL = 3;
  const int WHITE = 0, BLACK = 1, RED = 2, GREEN = 3;
  const int BLUE = 4, CYAN = 5, MAGENTA = 6, YELLOW = 7;
  const int ORANGE = 8, YELLOW_GREEN = 9, LIGHT_GREEN = 10;
  const int NAVY_BLUE = 11, PURPLE = 12, REDDISH_PURPLE = 13;
  const int DARK_GREY = 14, LIGHT_GREY = 15, TRANSPARENT = 16;
  const int SOLID = 1, DASHED = 2, DASH_DOT = 3;
  const int DOTTED = 4, DASH_DOT3 = 5;
  const int SOLID_FILL = 1, NO_FILL = 2;
  const int HATCHED = 3, CROSS_HATCHED = 4;
  const int SQUARE_SYM = 0, DOT_SYM = 1, PLUS_SYM = 2, TIMES_SYM = 3;
  const int CIRCLE_SYM = 4, X_SYMBOL_SYM = 5, TRIANGLE_SYM = 7;
  const int CIRCLE_PLUS_SYM = 8, CIRCLE_DOT_SYM = 9;
  const int SQUARE_CONCAVE_SYM = 10, DIAMOND_SYM = 11;
  const int STAR5_SYM = 12, TRIANGLE_FILLED_SYM = 13, RED_CROSS_SYM = 14;
  const int STAR_OF_DAVID_SYM = 15, SQUARE_FILLED_SYM = 16;
  const int CIRCLE_FILLED_SYM = 17, STAR5_FILLED_SYM = 18;
  const int DFLT_DRAW = 1, DFLT_SET = 2;
  const double PRINT_PAGE_LONG_LEN = 10.5;
  const double PRINT_PAGE_SHORT_LEN = 7.8;
  const int FILLED_ARROW_HEAD = 1, OUTLINE_ARROW_HEAD = 2;

}

#ifdef TRUE_DEF
#define TRUE    1
#undef TRUE_DEF
#endif

#ifdef FALSE_DEF
#define FALSE   0
#undef FALSE_DEF
#endif

#define BMAD_ENUMS
#endif
