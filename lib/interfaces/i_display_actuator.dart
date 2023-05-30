import '../mapping/color_mapper.dart';

abstract interface class IDisplayActuator {
  Future<void> init();
  void setColor(AppColor color);
  void setText(String msg);
  AppColor get lastColor;
}
