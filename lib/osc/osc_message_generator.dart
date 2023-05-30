import 'package:osc/osc.dart';

import '../constants.dart';
import '../interfaces/i_manager_out_actuator.dart';
import '../types/state.dart';

// TODO do we really need this CHANNEL thing? It's not in messages from the manager
const CHANNEL_NUM = 1;

OSCMessage createOscMessageBrightness(double amplitude) {
  return OSCMessage(kCommandChannelOscAddressBrightness,
      arguments: [CHANNEL_NUM, amplitude]);
}

OSCMessage createOscMessageColor(String colorCode) {
  return OSCMessage(kCommandChannelOscAddressColor,
      arguments: [CHANNEL_NUM, colorCode]);
}

OSCMessage createOscMessageHaptics(double amplitude) {
  // TODO: split arguments
  return OSCMessage(kCommandChannelOscAddressVibrate,
      arguments: [CHANNEL_NUM, amplitude, amplitude]);
}

OSCMessage createOscMessageManagerInSync(String address) {
  return OSCMessage(kCommandChannelOscAddressManagerInSync,
      arguments: [CHANNEL_NUM, address]);
}

OSCMessage createOscMessageManagerInPing(int id) {
  return OSCMessage(kCommandChannelOscAddressManagerInPing, arguments: [
    id,
    CHANNEL_NUM,
    BigInt.from(DateTime.now().microsecondsSinceEpoch)
  ]);
}

OSCMessage createOscMessageManagerOutPong(ManagerOutPong pong) {
  return OSCMessage(kCommandChannelOscAddressManagerOutPong, arguments: [
    pong.uuid,
    pong.id, // id from /ping
    0, // ignored
    pong.receivedTime, // int64
    pong.deviceName,
  ]);
}

OSCMessage createOscMessageManagerOutSync(ManagerOutSync sync) {
  return OSCMessage(kCommandChannelOscAddressManagerOutSync, arguments: [
    CHANNEL_NUM,
    sync.uuid,
    // need to have color component as float in the [0,1] range
    sync.actuatorState.color.r / 255,
    sync.actuatorState.color.g / 255,
    sync.actuatorState.color.b / 255,
    false, // ignored, muted
    false, // ignored, debug flag
    sync.managementState.isFirst,
    sync.phoneState.batteryLevel,
    sync.actuatorState.brightness,
    0, // ignore, volume
    sync.phoneState.buildNumber,
    sync.phoneState.deviceName,
  ]);
}

OSCMessage createOscMessageManagerApplyState(ActuatorState actuatorState) {
  return OSCMessage(kCommandChannelOscAddressManagerInState, arguments: [
    // need to have color component as float in the [0,1] range
    actuatorState.color.r / 255,
    actuatorState.color.g / 255,
    actuatorState.color.b / 255,
    false, // ignored, muted
    false, // debug flag
    actuatorState.brightness,
    0.0, // volume
    actuatorState.vibrationIntensity, // intensity
    actuatorState.vibrationSharpness, // sharpness
  ]);
}
