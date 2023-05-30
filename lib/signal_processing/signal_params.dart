import 'dart:math';
import '../constants.dart';

class SignalParams {
  double? _minValue;
  double? _maxValue;
  double offset = 0;
  double factor = 1;
  bool isDetectingMinMax = false;
  int windowSize = kSensorMovingAverageWindowSize;
  int samplingRate;
  String channelName;
  SignalParams({required this.channelName, required this.samplingRate});

  double? get minValue => _minValue;
  set minValue(double? value) {
    _minValue = value;
    updateOffsetAnFactor();
  }

  double? get maxValue => _maxValue;
  set maxValue(double? value) {
    _maxValue = value;
    updateOffsetAnFactor();
  }

  bool get isInitialized =>
      !isCalibrating && _minValue != null && _maxValue != null;

  bool get isCalibrating => isDetectingMinMax;
  set isCalibrating(bool value) {
    isDetectingMinMax = value;
    if (value) {
      _minValue = null;
      _maxValue = null;
      offset = 0;
      factor = 1;
    }
  }

  void updateOffsetAnFactor() {
    if (_minValue != null && _maxValue != null) {
      offset = -_minValue!;
      double diff = (_maxValue! - _minValue!);
      if (diff != 0) {
        factor = 1 / diff;
      }
    }
  }

  double normalize(double value, {bool cutZeroOne = false}) {
    double ret = (value + offset) * factor;
    if (cutZeroOne) {
      return max(min(ret, 1), 0);
    }
    return ret;
  }
}
