import 'package:logger/logger.dart';

import 'configuration.dart';
import 'device_name.dart';
import 'interfaces/i_advertiser.dart';
import 'interfaces/i_command_channel.dart';
import 'interfaces/i_configurable_host_port.dart';
import 'interfaces/i_display_actuator.dart';
import 'interfaces/i_amplitude_actuator.dart';
import 'interfaces/i_manager_out_actuator.dart';
import 'interfaces/i_debug_channel.dart';
import 'mapping/in_out_mapper.dart';
import 'models/core_model.dart';
import 'mapping/color_mapper.dart';
import 'models/sensor_model.dart';
import 'types/state.dart';

Logger logger = getLogger();

class CoreController {
  CoreController({
    required this.coreModel, // TODO must unregister stream for bitalino data on toggle
    required this.sensorModel,
    required this.displayActuator,
    required this.hapticActuator,
    required this.brightnessActuator,
    required this.managerOutActuator,
    required this.commandChannels,
    this.mdnsAdvertiser,
    this.oscBroadcastActuator,
    this.streamOut,
  });

  final IDisplayActuator displayActuator;
  final IAmplitudeActuator hapticActuator;
  final IAmplitudeActuator brightnessActuator;
  final IManagerOutActuator managerOutActuator;
  final CoreModel coreModel;
  final SensorModel sensorModel;

  final IAdvertiser? mdnsAdvertiser;
  final IAmplitudeActuator? oscBroadcastActuator;

  final Set<ICommandChannel> commandChannels;

  // Last actions
  ManagerOutPong? _lastManagerOutPong;
  ManagerOutSync? _lastManagerOutSync;
  String? managerOutAddress;

  // Unique identifier for this client application

  bool managementShouldSendFirstMessage = true;

  final IDebugChannel? streamOut; // For debugging
  String _deviceName = 'not-defined-yet';

  Future<void> init() async {
    logger.i('Initiating controller for UUID: ${coreModel.uuid}');
    _deviceName = await DeviceInfo().getDeviceName();

    // Register the callbacks for the command channels
    for (var commandChannel in commandChannels) {
      _registerCommandChannelCallbacks(commandChannel);
    }

    // Init all the actuators
    await Future.wait([
      displayActuator.init(),
      hapticActuator.init(),
      brightnessActuator.init(),
      managerOutActuator.init(),
      (oscBroadcastActuator != null)
          ? oscBroadcastActuator!.init()
          : Future.value(true),
    ]);

    // Init all the command channels
    await Future.wait(commandChannels.map((channel) => channel.init()));

    // Start advertising our node after all the other have succeeded
    mdnsAdvertiser?.init();

    // Init the internal stream listeners
    if (streamOut != null) {
      await streamOut!.init();
      streamOut!.listenOnStreamList(sensorModel.channelSeries.rawStream);
    }

    // Register sensor channels stream listening
    sensorModel.channelSeries.averagedStream
        .listen(_listenChannelSeriesAveragedStream);
  }

  Future<void> dispose() async {
    await mdnsAdvertiser?.stopAdvertising();
  }

  void _registerCommandChannelCallbacks(ICommandChannel commandChannel) {
    // Register all the handlers for the command channel
    commandChannel.setTextHandler(handleTextCommand);
    commandChannel.setVibrateHandler(handleVibrateCommand);
    commandChannel.setColorHandler(handleColorCommand);
    commandChannel.setBrightnessHandler(handleBrightnessCommand);

    commandChannel.setManagerOutPongHandler(handleManagerOutPongCommand);
    commandChannel.setManagerOutSyncHandler(handleManagerOutSyncCommand);
    commandChannel.setManagerApplyDebugHandler(handleManagerSetDebugCommand);
    commandChannel.setManagerApplyStateHandler(handleManagerSetStateCommand);
  }

  ActuatorState get actuatorState {
    // TODO don't ask the actuator for the last value
    return ActuatorState(
      vibrationIntensity: sensorToOscVibrationIntensityMap
          .getDouble(hapticActuator.lastAmplitudeValue),
      vibrationSharpness: sensorToOscVibrationSharpnessMap
          .getDouble(hapticActuator.lastAmplitudeValue),
      color: displayActuator.lastColor,
      brightness: sensorToOscBrightnessMap
          .getDouble(brightnessActuator.lastAmplitudeValue),
    );
  }

  PhoneState get phoneState {
    // TODO unhardcode
    return PhoneState('my-build-number', 'my-device-name', 0.5);
  }

  ManagementState get managementState {
    return ManagementState(managementShouldSendFirstMessage);
  }

  ManagerOutPong? get lastManagerOutPong {
    return _lastManagerOutPong;
  }

  ManagerOutSync? get lastManagerOutSync {
    return _lastManagerOutSync;
  }

  Future<void> _setManagerOutHost(String host) async {
    if (host != managerOutAddress) {
      logger.i('Changing manager host to: $host');
      managerOutAddress = host;
      await managerOutActuator.setHost(host);

      // TODO maybe we should not change the channels when we change manager host
      for (var channel in commandChannels) {
        if (channel is IConfigurableHostPort) {
          await (channel as IConfigurableHostPort).setHost(host);
        }
      }
    }
  }

  void handleColorCommand(AppColor color, bool enabled) {
    if (!enabled) return;
    displayActuator.setColor((color));
  }

  void handleBrightnessCommand(double value, bool enabled) {
    if (!enabled) return;
    brightnessActuator.debounceActuate(value);
  }

  void handleTextCommand(String msg, bool enabled) {
    if (!enabled) return;
    displayActuator.setText((msg));
  }

  void handleVibrateCommand(double amplitude, bool enabled) {
    hapticActuator.debounceActuate(amplitude);
  }

  void handleOscBroadcast(double amplitude, bool enabled) {
    // TODO do we need the ? here
    oscBroadcastActuator?.actuate(amplitude);
  }

  void handleManagerOutPongCommand(ManagerPongCmd cmd, bool enabled) {
    if (!enabled) return;
    ManagerOutPong pong = ManagerOutPong(coreModel.uuid, cmd.id,
        cmd.receivedTime, _deviceName ?? 'unknown-device-name');
    _lastManagerOutPong = pong;

    Future<void> p = cmd.managerAddress == managerOutAddress
        ? Future.value()
        : _setManagerOutHost(cmd.managerAddress);
    p.then((ignore) => managerOutActuator.pong(pong));
  }

  void handleManagerOutSyncCommand(String address, bool enabled) {
    if (!enabled) return;
    ManagerOutSync sync = ManagerOutSync(
        coreModel.uuid, actuatorState, phoneState, managementState);
    _lastManagerOutSync = sync;

    Future<void> p = address == managerOutAddress
        ? Future.value()
        : _setManagerOutHost(address);

    p.then((ignore) {
      managerOutActuator.sync(sync);
      managementShouldSendFirstMessage = false;
    });
  }

  void handleManagerSetDebugCommand(bool value, bool enabled) {
    if (!enabled) return;
    coreModel.setFullMode(value);
  }

  void handleManagerSetStateCommand(ManagerApplyStateCmd cmd,
      bool brightnessAndColorEnabled, bool vibrationEnabled) {
    // logger.d('Received manager state cmd: $cmd');

    // Reuse other handlers, since setting the "state" has multiple side effects
    handleColorCommand(cmd.color, brightnessAndColorEnabled);
    handleBrightnessCommand(cmd.brightnessAmplitude, brightnessAndColorEnabled);
    handleVibrateCommand(cmd.vibrationAmplitude, vibrationEnabled);
  }

  /*
   * Streams listening
   */
  void _listenChannelSeriesAveragedStream(List<List<double>> event) {
    double value =
        event[sensorModel.noDerivativeIndex][sensorModel.activeChannelIndex];

    handleBrightnessCommand(
        value, coreModel.inOutMap.sensorToBrightnessEnabled);

    handleVibrateCommand(sensorToSelfVibrationMap.getDouble(value),
        coreModel.inOutMap.sensorToVibrationEnabled);
    handleOscBroadcast(value, coreModel.inOutMap.sensorToOscBroadcastEnabled);
  }
}
