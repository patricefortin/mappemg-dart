import '../mapping/color_mapper.dart';

class ActuatorState {
  ActuatorState(
      {required this.vibrationIntensity,
      required this.vibrationSharpness,
      required this.color,
      required this.brightness});
  double vibrationIntensity;
  double vibrationSharpness;
  AppColor color;
  double brightness;
  @override
  toString() {
    return 'color: $color, brightness: $brightness, vibrationIntensity: $vibrationIntensity, vibrationSharpness: $vibrationSharpness';
  }
}

class PhoneState {
  PhoneState(this.buildNumber, this.deviceName, this.batteryLevel);
  String buildNumber;
  String deviceName;
  double batteryLevel;
  @override
  toString() {
    return 'buildNumber: $buildNumber, deviceName: $deviceName, batteryLevel: $batteryLevel';
  }
}

class ManagementState {
  ManagementState(this.isFirst);
  bool isFirst;
}
