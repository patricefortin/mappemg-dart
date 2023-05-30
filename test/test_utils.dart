import 'package:flutter/scheduler.dart';
import 'package:mappemg/core_controller.dart';
import 'package:mappemg/implementations/actuators/amplitude_actuator_dummy.dart';
import 'package:mappemg/implementations/actuators/amplitude_actuator_vibrator.dart';
import 'package:mappemg/implementations/actuators/display_actuator_dummy.dart';
import 'package:mappemg/implementations/actuators/manager_out_actuator_dummy.dart';
import 'package:mappemg/implementations/mdns_advertisers/mdns_advertiser_dummy.dart';
import 'package:mappemg/implementations/commands/command_channel_osc.dart';
import 'package:mappemg/interfaces/i_command_channel.dart';
import 'package:mappemg/models/core_model.dart';
import 'package:mappemg/implementations/sensors/sensor_replay_file_model.dart';

Future<CoreController> getTestController(
    ICommandChannel? commandChannel) async {
  CoreModel coreModel = CoreModel();

  var vibratorActuator = AmplitudeActuatorVibrator(coreModel: coreModel);
  vibratorActuator.createTicker = (dynamic foo) => Ticker((dynamic bar) => {});

  CoreController controller = CoreController(
      coreModel: coreModel,
      sensorModel: SensorReplayFileModel(),
      hapticActuator: vibratorActuator,
      displayActuator: DisplayActuatorDummy(),
      brightnessActuator: AmplitudeActuatorDummy(),
      managerOutActuator: ManagerOutActuatorDummy(),
      mdnsAdvertiser: MdnsAdvertiserDummy(coreModel: coreModel),
      commandChannels: commandChannel != null ? {commandChannel} : {});

  await controller.init();

  return controller;
}

CommandChannelOsc getTestOscCommandChannel() {
  CommandChannelOsc commandChannel =
      CommandChannelOsc.testable(coreModel: CoreModel());
  return commandChannel;
}
