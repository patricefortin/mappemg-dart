import '../constants.dart';
import '../types/common.dart';
import 'range_mapper.dart';

final Range normalRange = Range(0, 1);
final Range unsigned8bitRange = Range(0, 255);

// Inputs
final normMap = NormRangeMap();

final commandChannelBrightnessToNormMap = ToNormRangeMap(unsigned8bitRange);

final commandChannelVibrateToNormMap = ToNormRangeMap(unsigned8bitRange);

final inputOscManagerStateBrightnessMap = NormRangeMap();
final inputOscManagerStateVibrateMap = NormRangeMap();
final inputOscManagerStateRGBMap = NormRangeMap();

final sensorToSelfBrightnessTransform = NormRangeMap();

// Outputs
final outputIdentityMap = FromNormRangeMap(normalRange);
final outputAmplitudeActuatorVibrationMap =
    FromNormRangeMap(Range(0, kActuatorVibrationAmplitudeMax.toDouble()));

// OSC messages range mappings
final sensorToOscVibrationIntensityMap = InvExpPlusLinearRangeMap(
    from: normalRange,
    to: Range(kRangeVibrationIntensityMin, kRangeVibrationIntensityMax));

final sensorToOscVibrationSharpnessMap = SigmoidRangeMap(
    from: normalRange,
    to: Range(kRangeVibrationSharpnessMin, kRangeVibrationSharpnessMax));

final sensorToOscBrightnessMap = NormRangeMap();

// We use "intensity" for our vibration
final sensorToSelfVibrationMap = sensorToOscVibrationIntensityMap;
