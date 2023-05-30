import '../constants.dart';

class InOutMap {
  InOutMap({required this.notifyListeners});

  bool _oscToBrightness = kActuateOscToBrightnessEnabled;
  bool _oscToVibration = kActuateOscToVibrationEnabled;
  bool _oscToManagerIn = kActuateOscToManagerInEnabled;

  bool _sensorToBrightness = kActuateSensorToBrightnessEnabled;
  bool _sensorToVibration = kActuateSensorToVibrationEnabled;

  bool _sensorToOsc = kActuateSensorToOscEnabled;
  bool _physicalVibration = kActuatePhysicalVibrationEnabled;

  void Function() notifyListeners;

  bool get oscToBrightnessEnabled => _oscToBrightness;
  set oscToBrightnessEnabled(bool value) {
    _oscToBrightness = value;
    notifyListeners();
  }

  bool get oscToVibrationEnabled => _oscToVibration;
  set oscToVibrationEnabled(bool value) {
    _oscToVibration = value;
    notifyListeners();
  }

  bool get oscToManagerInEnabled => _oscToManagerIn;
  set oscToManagerInEnabled(bool value) {
    _oscToManagerIn = value;
    notifyListeners();
  }

  bool get sensorToBrightnessEnabled => _sensorToBrightness;
  set sensorToBrightnessEnabled(bool value) {
    _sensorToBrightness = value;
    notifyListeners();
  }

  bool get sensorToVibrationEnabled => _sensorToVibration;
  set sensorToVibrationEnabled(bool value) {
    _sensorToVibration = value;
    notifyListeners();
  }

  bool get sensorToOscBroadcastEnabled => _sensorToOsc;
  set sensorToOscBroadcastEnabled(bool value) {
    _sensorToOsc = value;
    notifyListeners();
  }

  bool get physicalVibrationEnabled => _physicalVibration;
  set physicalVibrationEnabled(bool value) {
    _physicalVibration = value;
    notifyListeners();
  }
}
