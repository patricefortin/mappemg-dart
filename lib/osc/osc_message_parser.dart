import 'package:osc/osc.dart';

import '../interfaces/i_command_channel.dart';
import '../mapping/color_mapper.dart';
import '../mapping/in_out_mapper.dart';
import '../types/in_out_map.dart';

AppColor parseOscColor(OSCMessage msg) {
  String value = msg.arguments[1].toString();
  return AppColor.fromString(value);
}

double parseOscBrightness(OSCMessage msg) {
  String value = msg.arguments[1].toString();
  return commandChannelBrightnessToNormMap.getDoubleFromString(value);
}

double parseOscHaptics(OSCMessage msg) {
  String amplitudeStr = msg.arguments[1].toString();
  return commandChannelVibrateToNormMap.getDoubleFromString(amplitudeStr);
}

ManagerPongCmd parseOscPing(OSCMessage msg, String managerAddress) {
  int id = msg.arguments[0] as int;
  BigInt receivedTime = msg.arguments[2] as BigInt;
  return ManagerPongCmd(id, receivedTime, managerAddress);
}

String parseOscSync(OSCMessage msg, String managerAddress) {
  // The address is not set correctly in "msg" when the Manager runs on Linux. Use the UDP sender address instead
  return managerAddress;
}

bool parseOscDebug(OSCMessage msg) {
  bool value = msg.arguments[0] as bool;
  return value;
}

/*
  From 121_nodes/121_manager/src/Node.hpp
      auto send_state() {
        last_state_ = ofGetElapsedTimef();
        ofxOscMessage m;
        m.setAddress("/state");
        m.addFloatArg(color_->r);
        m.addFloatArg(color_->g);
        m.addFloatArg(color_->b);
        m.addBoolArg(muted_);
        m.addBoolArg(debug_);
        m.addFloatArg(brightness_);
        m.addFloatArg(volume_);
        m.addFloatArg(intensity_);
        m.addFloatArg(sharpness_);
        send_message(m);
    }
*/
ManagerApplyStateCmd parseOscState(OSCMessage msg, InOutMap inOutMap) {
  // String idStr = msg.arguments[0].toString();
  const int indexRgbR = 0;
  const int indexRgbG = 1;
  const int indexRgbB = 2;
  const int indexBrightness = 5;

  const int indexVibration = 7; // use "intensity"
  // const int indexVibration = 8; // use "sharpness"

  double r = inputOscManagerStateRGBMap
      .getDoubleFromString(msg.arguments[indexRgbR].toString());
  double g = inputOscManagerStateRGBMap
      .getDoubleFromString(msg.arguments[indexRgbG].toString());
  double b = inputOscManagerStateRGBMap
      .getDoubleFromString(msg.arguments[indexRgbB].toString());

  return ManagerApplyStateCmd(
    // AppColor.fromString(colorCode),
    AppColor.fromRGB((r * 255).round(), (g * 255).round(), (b * 255).round()),
    inputOscManagerStateBrightnessMap
        .getDoubleFromString(msg.arguments[indexBrightness].toString()),
    inputOscManagerStateVibrateMap
        .getDoubleFromString(msg.arguments[indexVibration].toString()),
  );
}
