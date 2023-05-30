import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../constants.dart';
import '../interfaces/i_amplitude_actuator.dart';
import '../mapping/color_mapper.dart';
import '../types/time_series_types.dart';

// Control the display color. The amplitude can control the "brightness" of the color
class DisplayActuatorModel extends Model implements IAmplitudeActuator {
  late Color _color;
  DisplayActuatorModel() {
    AppColor appColor = AppColor.fromString(kActuatorColorBase);
    _color = Color.fromRGBO(appColor.r, appColor.g, appColor.b, 1);
  }

  Color get color => withBrightness(_color);

  set color(Color value) {
    _color = value;
    notifyListeners();
  }

  double _brightness = 0;

  Color withBrightness(Color color) {
    // This could also be done using the apha channel with a black background
    return Color.fromARGB(
      255,
      (color.red * _brightness).toInt(),
      (color.green * _brightness).toInt(),
      (color.blue * _brightness).toInt(),
    );
  }

  @override
  Future<void> actuate(double amplitude) async {
    _brightness = amplitude;
    notifyListeners();
  }

  @override
  Future<void> debounceActuate(double amplitude) {
    // No need to debounce in this actuator
    return actuate(amplitude);
  }

  @override
  Future<void> init() async {
    // Nothing to init in this actuator
  }

  @override
  double get lastAmplitudeValue => _brightness;
}
