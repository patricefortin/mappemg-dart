import '../../interfaces/i_display_actuator.dart';
import '../../mapping/color_mapper.dart';

class DisplayActuatorDummy implements IDisplayActuator {
  AppColor? colorCode;
  String? text;
  bool debugEnabled = false;
  int counter = 0;

  @override
  Future<void> init() async {
    setColor(AppColor());
  }

  @override
  void setColor(AppColor color) {
    colorCode = color;
  }

  @override
  void setText(String text) {
    this.text = text;
  }

  void incrementCounter() {
    counter += 1;
  }

  @override
  AppColor get lastColor {
    return colorCode ?? AppColor();
  }
}
