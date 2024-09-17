import 'package:logger/logger.dart';

const String kAppName = 'MappEMG';
const String kVersion = '1.0.0+6';

const String kDefaultRemoteAddress = '127.0.0.1';
const bool kDefaultFullModeEnabled = true;

// Set to Level.verbose to have a lot of info in the logs
const Level kLogLevel = Level.info;

// SharedPreferences keys
// On Linux, these preferences are stored in ~/.local/share/ca.umontreal.s2mlab.mappemg/shared_preferences.json
const String kPrefsKeySensorAddress = 'sensorAddress';

/*
 * Display options
 */

// Screens
const int kScreenIndexSensor = 0;
const int kScreenIndexVibration = 1;
const int kScreenIndexMdnsMesh = 2;
const int kScreenIndexMapping = 3;
const int kScreenIndexAppInfo = 4;
const int kScreenIndexSettings = 5;
const int kDefaultScreenIndex = kScreenIndexSensor;

// Labels for menu
const String kScreenIndexSensorLabel = 'Sensors';
const String kScreenIndexVibrationLabel = 'Vibration';
const String kScreenIndexMdnsMeshLabel = 'Network (mDNS)';
const String kScreenIndexMappingLabel = 'Mappings';
const String kScreenIndexAppInfoLabel = 'App State';
const String kScreenKioskModeLabel = 'Kiosk Mode (color)';
const String kScreenIndexSettingsLabel = 'Settings';

// How long to keep data for display
const int kPlotTimeSeriesDurationSeconds = 5;

/*
 * Command channels
 */

// Receive OSC messages from either the Manager or simple OSC clients (ex: MaxMSP)
// OSC Command Channel
const int kCommandChannelOscListenInPort = 2222;
const String kCommandChannelOscAddressVibrate = '/haptics';
const String kCommandChannelOscAddressColor = '/color';
const String kCommandChannelOscAddressBrightness = '/brightness';
const String kCommandChannelOscAddressManagerInPing = '/ping';
const String kCommandChannelOscAddressManagerInSync = '/sync';
const String kCommandChannelOscAddressManagerInState = '/state';
const String kCommandChannelOscAddressManagerInDebug = '/debug';
const String kCommandChannelOscAddressManagerOutPong = '/node/pong';
const String kCommandChannelOscAddressManagerOutSync = '/node/sync';

// Reverse Command Channel
// Use this to have a TCP connect back where we can type commands
// To listen for connection, use netcat, with either:
//   ./scripts/run-listen-tcp-netcat-server.sh # OR
//   nc -l 2221 -v -k
const bool kCommandChannelReverseTcpEnabled = false;
const String kCommandChannelReverseTcpAddress = kDefaultRemoteAddress;
const int kCommandChannelReverseTcpOutPort = 2221;
const String kCommandChannelReverseTcpPrompt = 'happtiks> ';
const String kCommandChannelReverseTcpTokenHelp = 'help';
const String kCommandChannelReverseTcpTokenVibrate = 'vibrate';
const String kCommandChannelReverseTcpTokenColor = 'color';
const String kCommandChannelReverseTcpTokenBrightness = 'brightness';

// Send raw data by using UDP to the host running the manager
const bool kDebugChannelStreamOutUdpEnabled = false;
const String kDebugChannelStreamOutUdpAddress = kDefaultRemoteAddress;
const int kDebugChannelStreamOutUdpPort = 2223;

/*
 * Compatibility with the "Manager" by "Artificiel"
 */

// Send OSC messages to the "Manager"
const int kOscManagerOutPort = 1984;
const String kOscManagerOutAddress = kDefaultRemoteAddress;

/*
 * MDNS broadcaster
 */

// MDNS node (client-side)
const bool kMdnsNodeEnabled = true;
const String kMdnsNodeType = '_medianode._udp';
const int kMdnsNodePort = kCommandChannelOscListenInPort;

// MDNS mesh management (server-side)
const bool kMdnsMeshEnabled = true;
const bool kMdnsMeshExcludeSelf = true;
const int kMdnsMeshDiscoverIntervalSeconds = 5;

/*
 * Sensors (server-side)
 */

// Sensor
const String kSensorBitalinoDefaultAddress = '00:21:06:BE:16:49';
const String kSensorDefaultReplayFile = 'debug-stream-out.txt';

const int kSensorCalibrationDurationSeconds = 10;
const int kSensorOffsetRawForZero = -512;

// sampling rate 1000Hz
// at a refresh rate of 60Hz, it gives one update every 3 frames (1000/60*3=50)
const int kSensorSamplingRate = 1000;
const int kSensorStepSize = 25;
const int kSensorMovingAverageWindowSize = 200;
const int kSensorNotifyListenersEveryNStepSize = 4; // for display

const int kSensorBandPassOrder = 5;
const double kSensorBandPassCenterFreq = 217.5;
const double kSensorBandPassWidthFreq = 415;
const double kSensorLowPassAveragedCutoffFreq = 5;
const double kSensorDerivativesPlotRangeMax = 0.2;

// Default features enabled
const bool kSensorEnabled = true;
const bool kSensorSpectrumEnabled = false;
const bool kSensorDerivativesEnabled = false;
const bool kSensorLowPassAveragedEnabled = true;
const bool kSensorBandPassControlsEnabled = false;
const bool kSensorMovingAverageControlsEnabled = false;

/*
 * Actuators
 */

// Which actuation features to enable by default (client-side)
const bool kActuateOscToBrightnessEnabled = true;
const bool kActuateOscToVibrationEnabled = true;
const bool kActuateOscToManagerInEnabled = true;

// Which actuation features to enable by default (server-side)
const bool kActuateSensorToBrightnessEnabled = true;
const bool kActuateSensorToVibrationEnabled = true;
const bool kActuateSensorToOscEnabled = true;

// Main flag to disable vibration
const bool kActuatePhysicalVibrationEnabled = false;

/*
 * Vibration
 */

// Vibration
const double kActuatorVibrationZeroThreshold = 0.05;
const int kActuatorVibrationDefaultStepSize = 1;
const int kActuatorVibrationDefaultWindowSize = 5;
const int kActuatorVibrationAmplitudeMax = 200; // absolute maximum
// We don't send every values to the device vibration library, we buffer them
const int kActuatorVibrationBufferSize = 4; // stepSize * 4 = 100ms delay

/*
 * Color
 */

// Default red for local display actuator, and to send as OSC state messages
const String kActuatorColorBase = 'e62525';

/*
 * Mappings
 */

// Ranges
const double kRangeVibrationIntensityMin = 0;
const double kRangeVibrationIntensityMax = 0.75;
const double kRangeVibrationSharpnessMin = 0;
const double kRangeVibrationSharpnessMax = 0.9;
const double kRangeSigmoidAlpha = 10;
const double kRangeInvExpAlpha = 15;
const double kRangeInvExpLinear = 2;
