#ifndef BMAD_PARAMETERS

namespace Bmad {
  const int BMAD_INC_VERSION = 74;
  const int N_ATTRIB_MAXX = 41;
  const int HYPER_Y = 1, HYPER_XY = 2, HYPER_X = 3;
  const int DRIFT = 1, SBEND = 2, QUADRUPOLE = 3, GROUP = 4;
  const int SEXTUPOLE = 5, OVERLAY = 6, CUSTOM = 7, TAYLOR = 8;
  const int RFCAVITY = 9;
  const int ELSEPARATOR = 10, BEAMBEAM = 11, WIGGLER = 12;
  const int SOL_QUAD = 13, MARKER = 14, KICKER = 15;
  const int HYBRID = 16, OCTUPOLE = 17, RBEND = 18;
  const int MULTIPOLE = 19, ACCEL_SOL = 20;
  const int DEF_BEAM = 21, AB_MULTIPOLE = 22, SOLENOID = 23;
  const int PATCH = 24, LCAVITY = 25, DEF_PARAMETER = 26;
  const int NULL_ELE = 27, INIT_ELE = 28, HOM = 29;
  const int MATCH = 30, MONITOR = 31, INSTRUMENT = 32;
  const int HKICKER = 33, VKICKER = 34, RCOLLIMATOR = 35;
  const int ECOLLIMATOR = 36, I_BEAM = 37, BEND_SOL_QUAD = 38;
  const int N_KEY = 38;
  const int LATTICE_TYPE = 1, SYMMETRY = 2, TAYLOR_ORDER = 3;
  const int ENERGY_GEV = 4;
  const int X_BEG_LIMIT=2, Y_BEG_LIMIT=3, B_X2=4,
          B_Y2=5, L_ST2=9, B_Z=10, L_ST1=11, S_ST2=12, S_ST1=13,
          B_X1=14, B_Y1=15;
  const int VAL1=3, VAL2=4, VAL3=5, VAL4=6, VAL5=7,
          VAL6=8, VAL7=9, VAL8=10, VAL9=11, VAL10=12, VAL11=13,
          VAL12=15;
  const int BETA_X0 = 2, ALPHA_X0 = 3, BETA_Y0 = 4,
          ALPHA_Y0 = 5, BETA_X1 = 6, ALPHA_X1 = 7, BETA_Y1 = 8,
          ALPHA_Y1 = 9, DPHI_X = 10, DPHI_Y = 11,
          ETA_X0 = 12, ETAP_X0 = 13, ETA_Y0 = 14, ETAP_Y0 = 15,
          ETA_X1 = 16, ETAP_X1 = 17, ETA_Y1 = 18, ETAP_Y1 = 19;
  const int L=1;
  const int TILT=2, COMMAND=2;
  const int OLD_COMMAND=3, ANGLE=3, KICK=3;
  const int K1=4, SIG_X=4, HARMON=4, H_DISPLACE=4, E_LOSS=4;
  const int K2=5, SIG_Y=5, B_MAX=5, V_DISPLACE=5, G=5;
  const int K3=6, SIG_Z=6, RF_WAVELENGTH=6, DELTA_G=6;
  const int DKS_DS=6, LRAD = 6;
  const int KS=7, VOLTAGE=7, N_POLE=7, BBI_CONST=7;
  const int E1=8, CHARGE=8, GAP=8;
  const int N_SLICE=9, E2=9, L_POLE=9, RF_FREQUENCY=9;
  const int FINT=10, POLARITY=10, GRADIENT=10;
  const int FINTX=11, Z_PATCH=11, PHI0=11;
  const int RHO=12, S_CENTER=12;
  const int HGAP=13, ENERGY_START=13;
  const int COEF=14, CURRENT=14, HGAPX=14, DELTA_E=14;
  const int ROLL=15, QUAD_TILT=15;
  const int L_ORIGINAL=16, L_CHORD=16, BEND_TILT=16;
  const int L_START=17, H1=17, X_QUAD=17;
  const int L_END=18, H2=18, Y_QUAD=18;
  const int X_PITCH=19;
  const int Y_PITCH=20;
  const int HKICK=21;
  const int VKICK=22;
  const int X_OFFSET=23;
  const int Y_OFFSET=24;
  const int S_OFFSET=25, Z_OFFSET=25;
  const int DE_OFFSET=26, CHECK_SUM=26;
  const int X_LIMIT=27;
  const int Y_LIMIT=28;
  const int APERTURE=29;
  const int RADIUS=30;
  const int BEAM_ENERGY=31;
  const int REL_TOL=32;
  const int ABS_TOL=33;
  const int B_FIELD=34, B_GRADIENT=34,
                             E_FIELD=34, E_GRADIENT=34;
  const int TILT_TOT=35;
  const int X_PITCH_TOT=36;
  const int Y_PITCH_TOT=37;
  const int X_OFFSET_TOT=38;
  const int Y_OFFSET_TOT=39;
  const int S_OFFSET_TOT=40;
  const int P0C = 41;
  const int ALIAS = 42;
  const int START_EDGE = 43;
  const int END_EDGE = 44;
  const int ACCORDION_EDGE = 45, SR_WAKE_FILE = 45;
  const int SYMMETRIC_EDGE = 46, LR_WAKE_FILE = 46;
  const int MAT6_CALC_METHOD = 47;
  const int TRACKING_METHOD  = 48;
  const int NUM_STEPS = 49;
  const int INTEGRATION_ORD = 50;
  const int TERM = 51;
  const int PTC_KIND = 52;
  const int SYMPLECTIFY = 53;
  const int DESCRIP = 54;
  const int IS_ON = 55;
  const int FIELD_CALC = 56;
  const int TYPE = 57;
  const int APERTURE_AT = 58;
  const int RAN_SEED = 59;
  const int A0  =  60, K0L  =  60;
  const int A20 =  80, K20L =  80;
  const int B0  =  90, T0  =  90;
  const int B20 = 110, T20 = 110;
  const int N_ATTRIB_SPECIAL_MAXX = 110;
  const int PARTICLE = 1;
  const int N_PART    = 3;
  const int PROTON     = +2;
  const int POSITRON   = +1;
  const int ELECTRON   = -1;
  const int ANTIPROTON = -2;
  const int LINEAR_LATTICE = 10;
  const int CIRCULAR_LATTICE = 12;
  const int FREE = 1, SUPER_SLAVE = 2, OVERLAY_SLAVE = 3;
  const int GROUP_LORD = 4, SUPER_LORD = 5, OVERLAY_LORD = 6;
  const int I_BEAM_LORD = 7, CLONE_LORD = 8, CLONE_SLAVE = 9;
  const int X_PLANE = 1, Y_PLANE = 2;
  const int Z_PLANE = 3, N_PLANE = 4, S_PLANE = 5;
  const int GARBAGE = -9876;
  const int BMAD_STANDARD = 1, SYMP_LIE_PTC = 2;
  const int RUNGE_KUTTA = 3;
  const int LINEAR = 4, TRACKING = 5, SYMP_MAP = 6;
  const int WIEDEMANN = 9, SYMP_LIE_BMAD = 10, NONE = 11;
  const int BORIS = 12, ADAPTIVE_BORIS = 13, MAD = 14;
  const int MAP_TYPE = 1, PERIODIC_TYPE = 3;
  const int ENTRANCE_END = 1, EXIT_END = 2, BOTH_ENDS = 3;
  const int NO_END = 4;
  const int BENDS = 201;
  const int WIGGLERS = 202;
  const int ALL = 203;
  const int RADIANS = 1, DEGREES = 2, CYCLES = 3, KHZ = 4;
  const int KICK_FIELD = 1, EM_FIELD = 2;
  const int N_POLE_MAXX = 20;
}

#define BMAD_PARAMETERS
#endif
