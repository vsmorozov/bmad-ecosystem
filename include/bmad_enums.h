
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
  const int BMAD_INC_VERSION = 214;
  const int N_POLE_MAXX = 21;
  const int OLD_CONTROL_VAR_OFFSET = 1000;
  const int VAR_OFFSET = 2000;
  const int TAYLOR_OFFSET = 1000000000;
  const int FUNCTION = 2, SPLINE = 3;
  const int BMAD_STANDARD = 1, SYMP_LIE_PTC = 2, RUNGE_KUTTA = 3;
  const int LINEAR = 4, TRACKING = 5, SYMP_MAP = 6;
  const int FIXED_STEP_RUNGE_KUTTA = 9, SYMP_LIE_BMAD = 10, STATIC = 11;
  const int BORIS = 12, FIXED_STEP_TIME_RUNGE_KUTTA = 13, MAD = 14;
  const int TIME_RUNGE_KUTTA = 15;
  const int N_METHODS = 15;
  const int DRIFT_KICK = 1, MATRIX_KICK = 2, RIPKEN_KICK = 3;
  const int MAP_TYPE = 1, PERIODIC_TYPE = 3;
  const int FIELDMAP = 2, REFER_TO_LORDS = 4, NO_FIELD = 5;
  const int BRAGG = 1, LAUE = 2;
  const int UNIFORM = 1, GAUSSIAN = 2, SPHERICAL = 3;
  const int MINOR_SLAVE = 1, SUPER_SLAVE = 2, FREE = 3;
  const int GROUP_LORD = 4, SUPER_LORD = 5, OVERLAY_LORD = 6;
  const int GIRDER_LORD = 7, MULTIPASS_LORD = 8, MULTIPASS_SLAVE = 9;
  const int NOT_A_LORD = 10, SLICE_SLAVE = 11, CONTROL_LORD = 12;
  const int GRIDED = 123;
  const int AUTO_APERTURE = 1, RECTANGULAR = 2, ELLIPTICAL = 3, WALL3D = 5, CUSTOM_APERTURE = 7;
  const int SOFT_EDGE_ONLY = 2, HARD_EDGE_ONLY = 3, FULL = 4;
  const int SAD_FULL = 5, LINEAR_EDGE = 6, BASIC_BEND = 7, TEST_EDGE = 8;
  const int N_NON_BEND_FRINGE_TYPE = 4;
  const int STANDING_WAVE = 1, TRAVELING_WAVE = 2, PTC_STANDARD = 3;
  const int X_INVARIANT = 1, MULTIPOLE_SYMMETRY = 2;
  const int CONTROL_VAR = 1, OLD_CONTROL_VAR = 2, ALL_CONTROL_VAR = 3, ELEC_MULTIPOLE = 4;
  const int OK = 1, IN_STOP_BAND = 2, NON_SYMPLECTIC = 3, UNSTABLE = 4;
  const int UNSTABLE_A = 5, UNSTABLE_B = 6;
  const int XFER_MAT_CALC_FAILURE = 7, TWISS_PROPAGATE_FAILURE = 8, NO_CLOSED_ORBIT = 9;
  const int ASCII = 1, BINARY = 2, HDF5 = 3;
  const int NUM_ELE_ATTRIB = 80;
  const int X_POLARIZATION = 2, Y_POLARIZATION = 3;
  const int OFF = 1, ON = 2;
  const int NONE = 1;
  const int HORIZONTALLY_PURE = 2, VERTICALLY_PURE = 3;
  const int MAGNETIC = 1, ELECTRIC = 2, MIXED = 3;
  const int BRAGG_DIFFRACTED = 1, FORWARD_DIFFRACTED = 2, UNDIFFRACTED = 3;
  const int REFLECTION = 1, TRANSMISSION = 2;
  const int ANCHOR_BEGINNING = 1, ANCHOR_CENTER = 2, ANCHOR_END = 3;
  const int ENTRANCE_END = 1, EXIT_END = 2, BOTH_ENDS = 3, NO_END = 4, NO_APERTURE = 4;
  const int CONTINUOUS = 5, SURFACE = 6, WALL_TRANSITION = 7;
  const int FIRST_TRACK_EDGE = 11, SECOND_TRACK_EDGE = 12, IN_BETWEEN = 13;
  const int UPSTREAM_END = 1, DOWNSTREAM_END = 2;
  const int INSIDE = 3, CENTER_PT = 3, START_END = 99;
  const int NORMAL = 1, CLEAR = 2, OPAQUE = 3, WALL_START = 9, WALL_END = 10;
  const int CHAMBER_WALL = 1, MASK_PLATE = 2;
  const int X_PLANE = 1, Y_PLANE = 2;
  const int Z_PLANE = 3, N_PLANE = 4, S_PLANE = 5;
  const int MOVING_FORWARD = -9;
  const int ALIVE = 1, LOST = 2;
  const int LOST_NEG_X_APERTURE = 3, LOST_POS_X_APERTURE = 4;
  const int LOST_NEG_Y_APERTURE = 5, LOST_POS_Y_APERTURE = 6;
  const int LOST_PZ_APERTURE = 7;
  const int LINEAR_LEADING = 2, LINEAR_TRAILING = 3;
  const int HYPER_Y_FAMILY_Y = 1, HYPER_XY_FAMILY_Y = 2, HYPER_X_FAMILY_Y = 3;
  const int HYPER_Y_FAMILY_X = 4, HYPER_XY_FAMILY_X = 5, HYPER_X_FAMILY_X = 6;
  const int HYPER_Y_FAMILY_QU = 7, HYPER_XY_FAMILY_QU = 8, HYPER_X_FAMILY_QU = 9;
  const int HYPER_Y_FAMILY_SQ = 10, HYPER_XY_FAMILY_SQ = 11, HYPER_X_FAMILY_SQ = 12;
  const int X_FAMILY = 1, Y_FAMILY = 2, QU_FAMILY = 3, SQ_FAMILY = 4;
  const int SUPER_OK = 0, STALE = 2;
  const int ATTRIBUTE_GROUP = 1, CONTROL_GROUP = 2, FLOOR_POSITION_GROUP = 3;
  const int S_POSITION_GROUP = 4, REF_ENERGY_GROUP = 5, MAT6_GROUP = 6;
  const int RAD_INT_GROUP = 7, ALL_GROUPS = 8, S_AND_FLOOR_POSITION_GROUP = 9;
  const int SEGMENTED = 2, H_MISALIGN = 3, DIFFRACT_TARGET = 4;
  const int INCOHERENT = 1, COHERENT = 2;
  const int OPAL = 1, IMPACTT = 2;
  const int DRIFT = 1, SBEND = 2, QUADRUPOLE = 3, GROUP = 4;
  const int SEXTUPOLE = 5, OVERLAY = 6, CUSTOM = 7, TAYLOR = 8;
  const int RFCAVITY = 9;
  const int ELSEPARATOR = 10, BEAMBEAM = 11, WIGGLER = 12;
  const int SOL_QUAD = 13, MARKER = 14, KICKER = 15;
  const int HYBRID = 16, OCTUPOLE = 17, RBEND = 18, MULTIPOLE = 19;
  const int DEF_BMAD_COM = 20, DEF_MAD_BEAM = 21, AB_MULTIPOLE = 22, SOLENOID = 23;
  const int PATCH = 24, LCAVITY = 25, DEF_PARAMETER = 26;
  const int NULL_ELE = 27, BEGINNING_ELE = 28, LINE_ELE = 29;
  const int MATCH = 30, MONITOR = 31, INSTRUMENT = 32;
  const int HKICKER = 33, VKICKER = 34, RCOLLIMATOR = 35;
  const int ECOLLIMATOR = 36, GIRDER = 37, BEND_SOL_QUAD = 38;
  const int DEF_BEAM_START = 39, PHOTON_FORK = 40;
  const int FORK = 41, MIRROR = 42, CRYSTAL = 43;
  const int PIPE = 44, CAPILLARY = 45, MULTILAYER_MIRROR = 46;
  const int E_GUN = 47, EM_FIELD = 48, FLOOR_SHIFT = 49, FIDUCIAL = 50;
  const int UNDULATOR = 51, DIFFRACTION_PLATE = 52, PHOTON_INIT = 53;
  const int SAMPLE = 54, DETECTOR = 55, SAD_MULT = 56, MASK = 57, AC_KICKER = 58;
  const int N_KEY = 58;
  const int N_PART = 2, TAYLOR_ORDER = 3;
  const int VAL1=11, VAL2=12, VAL3=13, VAL4=14, VAL5=15,
            VAL6=16, VAL7=17, VAL8=18, VAL9=19, VAL10=20, VAL11=21,
            VAL12=22;
  const int BETA_A0 = 2, ALPHA_A0 = 3, BETA_B0 = 4, ALPHA_B0 = 5;
  const int BETA_A1 = 6, ALPHA_A1 = 7, BETA_B1 = 8, ALPHA_B1 = 9;
  const int DPHI_A = 10, DPHI_B = 11;
  const int ETA_X0 = 12, ETAP_X0 = 13, ETA_Y0 = 14, ETAP_Y0 = 15;
  const int ETA_X1 = 16, ETAP_X1 = 17, ETA_Y1 = 18, ETAP_Y1 = 19;
  const int MATCH_END_INPUT = 20;
  const int MATCH_END = 21;
  const int DELTA_TIME = 22;
  const int X0 = 24, PX0 = 25, Y0 = 26, PY0 = 27, Z0 = 28, PZ0 = 29;
  const int X1 = 30, PX1 = 31, Y1 = 32, PY1 = 33, Z1 = 34, PZ1 = 35;
  const int MATCH_END_ORBIT_INPUT = 36, MATCH_END_ORBIT = 37;
  const int C11_MAT0 = 40, C12_MAT0 = 41, C21_MAT0 = 42, C22_MAT0 = 43;
  const int C11_MAT1 = 44, C12_MAT1 = 45, C21_MAT1 = 46, C22_MAT1 = 47;
  const int X = 1, PX = 2, Y = 3, PY = 4, Z = 5, PZ = 6;
  const int T = 8;
  const int FIELD_X = 10, FIELD_Y = 11, PHASE_X = 12, PHASE_Y = 13;
  const int E_PHOTON = 9;
  const int E1 = 19, E2 = 20;
  const int FINT = 21, FINTX = 22, HGAP = 23, HGAPX = 24, H1 = 25, H2 = 26;
  const int L = 1;
  const int TILT = 2, ROLL = 2;
  const int REF_TILT = 3, RF_FREQUENCY = 3, DIRECTION = 3;
  const int KICK = 3, X_GAIN_ERR = 3;
  const int RF_FREQUENCY_ERR = 4, K1 = 4, HARMON = 4, H_DISPLACE = 4, Y_GAIN_ERR = 4;
  const int CRITICAL_ANGLE_FACTOR = 4, TILT_CORR = 4, REF_COORDINATES = 4;
  const int GRAZE_ANGLE = 5, K2 = 5, B_MAX = 5, V_DISPLACE = 5, DRIFT_ID = 5;
  const int KS = 5, FLEXIBLE = 5, CRUNCH = 5, REF_ORBIT_FOLLOWS = 5;
  const int GRADIENT = 6, K3 = 6, NOISE = 6, NEW_BRANCH = 6;
  const int G = 6, BRAGG_ANGLE_IN = 6, SYMMETRY = 6, FIELD_SCALE_FACTOR = 6;
  const int G_ERR = 7, N_POLE = 7, BBI_CONST = 7, OSC_AMPLITUDE = 7;
  const int GRADIENT_ERR = 7, CRITICAL_ANGLE = 7, SAD_FLAG = 7;
  const int BRAGG_ANGLE_OUT = 7, IX_TO_BRANCH = 7;
  const int RHO = 8, DELTA_E_REF = 8, DIFFRACTION_LIMITED = 8;
  const int CHARGE = 8, X_GAIN_CALIB = 8, IX_TO_ELEMENT = 8, VOLTAGE = 8;
  const int EPS_STEP_SCALE = 9, VOLTAGE_ERR = 9;
  const int FRINGE_TYPE = 10;
  const int FRINGE_AT = 11, GANG = 11;
  const int HIGHER_ORDER_FRINGE_TYPE = 12;
  const int SPIN_FRINGE_ON = 13;
  const int FB1 = 14, SIG_X = 14, EXACT_MULTIPOLES = 14;
  const int FB2 = 15, SIG_Y = 15, GRAZE_ANGLE_IN = 15;
  const int FQ1 = 16, SIG_Z = 16, GRAZE_ANGLE_OUT = 16;
  const int FQ2 = 17, SIG_VX = 17;
  const int SIG_VY = 18, AUTOSCALE_AMPLITUDE = 18;
  const int SIG_E = 19, AUTOSCALE_PHASE = 19;
  const int D1_THICKNESS = 20, DEFAULT_TRACKING_SPECIES = 20, DIRECTION_BEAM_START = 20;
  const int N_SLICE = 20, Y_GAIN_CALIB = 20, BRAGG_ANGLE = 20, E_CENTER = 20, CONSTANT_REF_ENERGY = 20;
  const int POLARITY = 21, CRUNCH_CALIB = 21, ALPHA_ANGLE = 21, D2_THICKNESS = 21;
  const int E_LOSS = 21, DKS_DS = 21, GAP = 21, E_CENTER_RELATIVE_TO_REF = 21, SPIN_X = 21;
  const int X_OFFSET_CALIB = 22, V1_UNITCELL = 22, PSI_ANGLE = 22, SPATIAL_DISTRIBUTION = 22;
  const int SPIN_Y = 22;
  const int Y_OFFSET_CALIB = 23, V_UNITCELL = 23, V2_UNITCELL = 23, SPIN_Z = 23;
  const int CAVITY_TYPE = 23, BETA_A = 23, VELOCITY_DISTRIBUTION = 23;
  const int PHI0 = 24, TILT_CALIB = 24, BETA_B = 24, ENERGY_DISTRIBUTION = 24, LIVE_BRANCH = 24;
  const int PHI0_ERR = 25, CURRENT = 25, L_POLE = 25, PARTICLE = 25;
  const int QUAD_TILT = 25, DE_ETA_MEAS = 25, ALPHA_A = 25, E_FIELD_X = 25;
  const int GEOMETRY = 26, BEND_TILT = 26, MODE = 26, ALPHA_B = 26, E_FIELD_Y = 26;
  const int PHI0_MULTIPASS = 26, N_SAMPLE = 26, ORIGIN_ELE_REF_PT = 26;
  const int PHI0_AUTOSCALE = 27, DX_ORIGIN =  27, CMAT_11 = 27, SCALE_FIELD_TO_ONE = 27;
  const int LATTICE_TYPE = 27, X_QUAD = 27, DS_PHOTON_SLICE = 27;
  const int PHI0_MAX = 28, DY_ORIGIN = 28, Y_QUAD = 28, PHOTON_TYPE = 28;
  const int CMAT_12 = 28;
  const int FLOOR_SET = 29, UPSTREAM_ELE_DIR = 29, DZ_ORIGIN = 29;
  const int CMAT_21 = 29, L_SAGITTA = 29;
  const int DTHETA_ORIGIN = 30, B_PARAM = 30, TRANSVERSE_SIGMA_CUT = 30, L_CHORD = 30;
  const int DOWNSTREAM_ELE_DIR = 30, CMAT_22 = 30, SPINOR_THETA = 30;
  const int L_HARD_EDGE = 31, DPHI_ORIGIN = 31, REF_CAP_GAMMA = 31, DS_SLICE = 31, SPINOR_PHI = 31;
  const int FIELD_AUTOSCALE = 32, DPSI_ORIGIN = 32, T_OFFSET = 32, SPINOR_XI = 32;
  const int ANGLE = 33, N_CELL = 33, X_RAY_LINE_LEN = 33, SPINOR_POLARIZATION = 33;
  const int X_PITCH = 34;
  const int Y_PITCH = 35;
  const int X_OFFSET = 36;
  const int Y_OFFSET = 37;
  const int Z_OFFSET = 38;
  const int HKICK = 39, D_SPACING = 39, X_OFFSET_MULT = 39, EMITTANCE_A = 39;
  const int VKICK = 40, Y_OFFSET_MULT = 40, P0C_REF_INIT = 40, EMITTANCE_B = 40;
  const int BL_HKICK = 41, X_PITCH_MULT = 41, E_TOT_REF_INIT = 41, EMITTANCE_Z = 41;
  const int BL_VKICK = 42, Y_PITCH_MULT = 42, DARWIN_WIDTH_SIGMA = 42;
  const int PENDELLOSUNG_PERIOD_SIGMA = 43, BL_KICK = 43, B_FIELD = 43, E_FIELD = 43;
  const int COUPLER_PHASE = 44, DARWIN_WIDTH_PI = 44, B_FIELD_ERR = 44;
  const int B1_GRADIENT = 45, E1_GRADIENT = 45, COUPLER_ANGLE = 45, PENDELLOSUNG_PERIOD_PI = 45;
  const int B2_GRADIENT = 46, E2_GRADIENT = 46, COUPLER_STRENGTH = 46, DBRAGG_ANGLE_DE = 46;
  const int COUPLER_AT = 47, E_TOT_SET = 47, PTC_CANONICAL_COORDS = 47;
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
  const int N_REF_PASS = 62;
  const int R0_MAG = 63;
  const int REF_TIME_START = 64;
  const int THICKNESS = 65, INTEGRATOR_ORDER = 65;
  const int NUM_STEPS = 66;
  const int DS_STEP = 67;
  const int LORD_PAD1 = 68;
  const int LORD_PAD2 = 69, REF_WAVELENGTH = 69;
  const int R0_ELEC = 70;
  const int SCRATCH1 = 71;
  const int SCRATCH2 = 72;
  const int SCRATCH3 = 73;
  const int SCRATCH4 = 74;
  const int SCRATCH5 = 75;
  const int X1_LIMIT = 76;
  const int X2_LIMIT = 77;
  const int Y1_LIMIT = 78;
  const int Y2_LIMIT = 79;
  const int CHECK_SUM = 80;
  const int MAX_APERTURE_LIMIT = 81;
  const int DEFAULT_DS_STEP = 82;
  const int SIGNIFICANT_LENGTH = 83;
  const int REL_TOL_TRACKING = 84;
  const int ABS_TOL_TRACKING = 85;
  const int REL_TOL_ADAPTIVE_TRACKING = 86;
  const int ABS_TOL_ADAPTIVE_TRACKING = 87;
  const int INIT_DS_ADAPTIVE_TRACKING = 88;
  const int MIN_DS_ADAPTIVE_TRACKING = 89;
  const int FATAL_DS_ADAPTIVE_TRACKING = 90;
  const int MAX_NUM_RUNGE_KUTTA_STEP = 91;
  const int SPHERICAL_CURVATURE = 81;
  const int ALPHA_B_BEGIN = 81, USE_HARD_EDGE_DRIFTS = 81, TT = 81, LR_WAKE_SPLINE = 81;
  const int ALIAS  = 82, ETA_X = 82, PTC_MAX_FRINGE_ORDER = 82;
  const int ETA_Y = 83, ELECTRIC_DIPOLE_MOMENT = 83, LR_SELF_WAKE_ON = 83, X_REF = 83;
  const int ETAP_X = 84, LR_WAKE_FILE = 84, PX_REF = 84;
  const int ETAP_Y = 85, LR_FREQ_SPREAD = 85, Y_REF = 85;
  const int LATTICE = 86, PHI_A = 86, MULTIPOLES_ON = 86, PY_REF = 86;
  const int APERTURE_TYPE = 87, ETA_Z = 87;
  const int TAYLOR_MAP_INCLUDES_OFFSETS = 88, CMAT_11_BEGIN = 88, SURFACE_ATTRIB = 88;
  const int CSR_CALC_ON = 89, CMAT_12_BEGIN = 89, VAR = 89, Z_REF = 89;
  const int CMAT_21_BEGIN = 90, PZ_REF = 90;
  const int MAT6_CALC_METHOD = 91, CMAT_22_BEGIN = 91;
  const int TRACKING_METHOD  = 92, S_LONG = 92;
  const int REF_TIME = 93, PTC_INTEGRATION_TYPE = 93;
  const int SPIN_TRACKING_METHOD = 94, ETA_A = 94;
  const int APERTURE = 95, ETAP_A = 95;
  const int X_LIMIT = 96, ABSOLUTE_TIME_TRACKING = 96, ETA_B = 96;
  const int Y_LIMIT = 97, ETAP_B = 97;
  const int OFFSET_MOVES_APERTURE = 98;
  const int APERTURE_LIMIT_ON = 99;
  const int PTC_EXACT_MISALIGN = 100, PHYSICAL_SOURCE = 100;
  const int SR_WAKE_FILE = 100, ALPHA_A_BEGIN = 100;
  const int TERM = 101, FREQUENCIES = 101;
  const int X_POSITION = 102, S_SPLINE = 102, PTC_EXACT_MODEL = 102;
  const int SYMPLECTIFY = 103, Y_POSITION = 103, N_SLICE_SPLINE = 103;
  const int Z_POSITION = 104, AMP_VS_TIME = 104;
  const int IS_ON = 105, THETA_POSITION = 105;
  const int FIELD_CALC = 106, PHI_POSITION = 106;
  const int PSI_POSITION = 107, WALL = 107;
  const int APERTURE_AT = 108, BETA_A_BEGIN = 108;
  const int RAN_SEED = 109, BETA_B_BEGIN = 109, ORIGIN_ELE = 109;
  const int TO_LINE = 110, FIELD_OVERLAPS = 110;
  const int FIELD_MASTER = 111, TO_ELEMENT = 111;
  const int DESCRIP = 112;
  const int SCALE_MULTIPOLES = 113;
  const int REF_ORBIT = 115;
  const int PHI_B = 116, CRYSTAL_TYPE = 116, MATERIAL_TYPE = 116;
  const int TYPE = 117;
  const int REF_ORIGIN = 118;
  const int ELE_ORIGIN = 119;
  const int SUPERIMPOSE     = 120;
  const int OFFSET          = 121;
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
  const int A0  = 140, A21  = 161;
  const int B0  = 162, B21  = 183;
  const int K0L = 140, K21L = 161;
  const int T0  = 162, T21  = 183;
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
  const int UNKNOWN = 0, IS_LOGICAL = 1, IS_INTEGER = 2, IS_REAL = 3, IS_SWITCH = 4, IS_STRING = 5;
  const int IS_STRUCT = 6;
  const int PATCH_PROBLEM = 2, OUTSIDE = 3, CANNOT_FIND = 4;
  const int SECTOR = 1, STRAIGHT = 2, TRUE_RBEND = 3;
  const double SMALL_REL_CHANGE = 1E-14;
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
  const double M_ELECTRON = 0.5109989461E6;
  const double M_PROTON   = 0.9382720813E9;
  const double M_MUON     = 105.6583715E6;
  const double E_MASS = 1E-9 * M_ELECTRON;
  const double P_MASS   = 1E-9 * M_PROTON;
  const double M_PION_0 = 134.9766E6;
  const double M_PION_CHARGED = 139.57018E6;
  const double M_DEUTERON   = 1.875612928E9;
  const double ATOMIC_MASS_UNIT = 931.494095E6;
  const double C_LIGHT = 2.99792458E8;
  const double R_E = 2.8179403227E-15;
  const double R_P = R_E * M_ELECTRON / M_PROTON;
  const double E_CHARGE = 1.6021766208E-19;
  const double H_PLANCK = 4.13566733E-15;
  const double H_BAR_PLANCK = 6.58211899E-16;
  const double MU_0_VAC = FOURPI * 1E-7;
  const double CLASSICAL_RADIUS_FACTOR = 1.439964416E-9;
  const double N_AVOGADRO = 6.02214129E23;
  const double FINE_STRUCTURE_CONSTANT =  7.29735257E-3;
  const double ANOMALOUS_MAG_MOMENT_ELECTRON = 1.159652193E-3;
  const double ANOMALOUS_MAG_MOMENT_PROTON   = 1.79284735E0;
  const double ANOMALOUS_MAG_MOMENT_MUON     = 1.1659208E-3;
  const double ANOMALOUS_MAG_MOMENT_DEUTERON = -0.14298727047E0;
  const int INVALID = -666;
  const int NOT_SET = -999;
  const int DEUTERON   = 8;
  const int REF_PARTICLE = 6, ANTI_REF_PARTICLE = 7;
  const int PION_0     = +5;
  const int PION_PLUS  = +4;
  const int ANTIMUON   = +3;
  const int PROTON     = +2;
  const int POSITRON   = +1;
  const int PHOTON     =  0;
  const int ELECTRON   = -1;
  const int ANTIPROTON = -2;
  const int MUON       = -3;
  const int PION_MINUS = -4;
  const int ANTI_DEUTERON = -5;
  const int INT_GARBAGE = -987654;
  const double REAL_GARBAGE = -987654.3;
  const int X_AXIS = 1, Y_AXIS = 2, Z_AXIS = 3;
  const double TRUE = 1, FALSE = 0;
  const int TRUE_INT = 1, FALSE_INT = 0;
  const int YES = 1, NO = 0, MAYBE = 2;
  const int WHITE = 0, BLACK = 1, RED = 2, GREEN = 3;
  const int BLUE = 4, CYAN = 5, MAGENTA = 6, YELLOW = 7;
  const int ORANGE = 8, YELLOW_GREEN = 9, LIGHT_GREEN = 10;
  const int NAVY_BLUE = 11, PURPLE = 12, REDISH_PURPLE = 13;
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
