import 'dart:async';
import 'package:osc/osc.dart';

import '../../configuration.dart';
import '../../constants.dart';
import '../../models/core_model.dart';
import 'command_channel_base.dart';
import '../../osc/osc_message_parser.dart';

const int defaultOscListenPort = kCommandChannelOscListenInPort;

class CommandChannelOsc extends CommandChannelBase {
  CommandChannelOsc({required this.coreModel});
  CommandChannelOsc.testable(
      {this.networkEnabled = false, required this.coreModel});
  CoreModel coreModel;
  bool echoEnabled = true;
  bool networkEnabled = true;

  OSCSocket socket = OSCSocket(serverPort: defaultOscListenPort);

  bool isConnecting = false;

  @override
  Future<void> init() async {
    await super.init();
    getLogger().d('OSC listening on port $defaultOscListenPort');
    if (networkEnabled) {
      socket.listen(messageReceived);
    }
  }

  //receiving and sending back a custom message
  void messageReceived(OSCMessage msg) {
    if (networkEnabled && echoEnabled) {
      socket.reply(OSCMessage('/received', arguments: []));
    }

    switch (msg.address) {
      case kCommandChannelOscAddressColor:
        onColor(parseOscColor(msg), coreModel.inOutMap.oscToBrightnessEnabled);
        break;

      case kCommandChannelOscAddressBrightness:
        onBrightness(
            parseOscBrightness(msg), coreModel.inOutMap.oscToBrightnessEnabled);
        break;

      case kCommandChannelOscAddressVibrate:
        onVibrate(
            parseOscHaptics(msg), coreModel.inOutMap.oscToVibrationEnabled);
        break;

      case kCommandChannelOscAddressManagerInPing:
        String managerAddress =
            socket.lastMessageAddress?.address ?? 'unknown-manager-address';
        onManagerOutPong(parseOscPing(msg, managerAddress),
            coreModel.inOutMap.oscToManagerInEnabled);
        break;

      case kCommandChannelOscAddressManagerInSync:
        String managerAddress =
            socket.lastMessageAddress?.address ?? 'unknown-manager-address';
        onManagerOutSync(parseOscSync(msg, managerAddress),
            coreModel.inOutMap.oscToManagerInEnabled);
        break;

      case kCommandChannelOscAddressManagerInDebug:
        onManagerApplyDebug(
            parseOscDebug(msg), coreModel.inOutMap.oscToManagerInEnabled);
        break;

      case kCommandChannelOscAddressManagerInState:
        onManagerApplyState(
            parseOscState(msg, coreModel.inOutMap),
            coreModel.inOutMap.oscToBrightnessEnabled,
            coreModel.inOutMap.oscToVibrationEnabled);
        break;

      default:
      // No default
    }

    // Always update the text
    onText(msg.toString(), true);
  }
}
