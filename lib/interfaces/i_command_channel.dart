import '../mapping/color_mapper.dart';

typedef CommandColorHandler = void Function(AppColor, bool enabled);
typedef CommandBrightnessHandler = void Function(double, bool enabled);
typedef CommandTextHandler = void Function(String, bool enabled);
typedef CommandVibrateHandler = void Function(double, bool enabled);
typedef CommandOscBroadcastHandler = void Function(double, bool enabled);
typedef CommandManagerOutPongHandler = void Function(
    ManagerPongCmd, bool enabled);
typedef CommandManagerOutSyncHandler = void Function(String, bool enabled);
typedef CommandManagerApplyDebugHandler = void Function(
    bool value, bool enabled);
typedef CommandManagerApplyStateHandler = void Function(ManagerApplyStateCmd,
    bool brightnessAndColorEnabled, bool vibrationEnabled);

class ManagerPongCmd {
  int id;
  BigInt receivedTime;
  String managerAddress;
  ManagerPongCmd(this.id, this.receivedTime, this.managerAddress);
}

class ManagerApplyStateCmd {
  AppColor color;
  double brightnessAmplitude;
  double vibrationAmplitude;
  ManagerApplyStateCmd(
      this.color, this.brightnessAmplitude, this.vibrationAmplitude);
  @override
  toString() {
    return 'color: $color, brightness: $brightnessAmplitude, vibration: $vibrationAmplitude';
  }
}

abstract interface class ICommandChannel {
  Future<void> init();

  void setColorHandler(CommandColorHandler f);
  void setBrightnessHandler(CommandBrightnessHandler f);
  void setTextHandler(CommandTextHandler f);
  void setVibrateHandler(CommandVibrateHandler f);

  void setManagerOutPongHandler(CommandManagerOutPongHandler f);
  void setManagerOutSyncHandler(CommandManagerOutSyncHandler f);
  void setManagerApplyDebugHandler(CommandManagerApplyDebugHandler f);
  void setManagerApplyStateHandler(CommandManagerApplyStateHandler f);
}
