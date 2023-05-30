import '../../interfaces/i_command_channel.dart';

abstract class CommandChannelBase implements ICommandChannel {
  late CommandColorHandler onColor;
  late CommandBrightnessHandler onBrightness;
  late CommandTextHandler onText;
  late CommandVibrateHandler onVibrate;
  late CommandManagerOutPongHandler onManagerOutPong;
  late CommandManagerOutSyncHandler onManagerOutSync;
  late CommandManagerApplyDebugHandler onManagerApplyDebug;
  late CommandManagerApplyStateHandler onManagerApplyState;

  @override
  Future<void> init() async {}

  @override
  void setColorHandler(CommandColorHandler f) {
    onColor = f;
  }

  @override
  void setBrightnessHandler(CommandBrightnessHandler f) {
    onBrightness = f;
  }

  @override
  void setTextHandler(CommandTextHandler f) {
    onText = f;
  }

  @override
  void setVibrateHandler(CommandVibrateHandler f) {
    onVibrate = f;
  }

  @override
  void setManagerOutPongHandler(CommandManagerOutPongHandler f) {
    onManagerOutPong = f;
  }

  @override
  void setManagerOutSyncHandler(CommandManagerOutSyncHandler f) {
    onManagerOutSync = f;
  }

  @override
  void setManagerApplyDebugHandler(CommandManagerApplyDebugHandler f) {
    onManagerApplyDebug = f;
  }

  @override
  void setManagerApplyStateHandler(CommandManagerApplyStateHandler f) {
    onManagerApplyState = f;
  }
}
