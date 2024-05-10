import 'package:bitalino/bitalino.dart';

import '../../constants.dart';
import '../../exceptions.dart';
import '../../models/sensor_model.dart';

class SensorBitalinoBluetoothModel extends SensorModel {
  BITalinoController controller =
      BITalinoController(kSensorBitalinoDefaultAddress, CommunicationType.BTH);

  String _address = kSensorBitalinoDefaultAddress;

  @override
  String get address => _address;

  @override
  set address(value) {
    _address = value;
  }

  @override
  Future<void> initPlatformState(String address) async {
    savePrefsLastAddress(address);
    // Create a new one for now, for debugging purpose
    controller = BITalinoController(address, CommunicationType.BTH);
    _address = address;
    try {
      await controller.initialize();
      notifyListenersAndUI("Initialized: BTH");
      notifyListeners();
    } catch (e) {
      notifyListenersAndUI("Initialization failed");
    }
  }

  @override
  String get status {
    if (isCalibrating) {
      return 'calibrating (${kSensorCalibrationDurationSeconds}s)';
    }
    if (controller.recording) {
      return 'recording (${channelsRecording.map((zeroChannel) => 'a${zeroChannel + 1}').toList().join(',')})';
    }
    if (controller.connected) {
      return 'connected';
    }
    if (controller.initialized) {
      return 'initialized';
    }
    return 'not initialized';
  }

  @override
  bool get canConnect => controller.initialized;

  @override
  bool get canDisconnect => controller.connected || controller.recording;

  @override
  bool get canSaveMVC => controller.recording && !isCalibrating;

  @override
  bool get canStart => controller.connected;

  @override
  bool get canStop => controller.recording;

  @override
  actionConnect() async {
    try {
      bool connected = await controller.connect(onConnectionLost: () {
        notifyListenersAndUI('Connection lost');
      });
      notifyListenersAndUI(
        "Connected: $connected",
      );
    } catch (e) {
      notifyListenersAndUI(e.toString());
    }
  }

  @override
  actionDisconnect() async {
    try {
      bool disconnected = await controller.disconnect();
      notifyListenersAndUI("Disconnected: $disconnected");
    } catch (e) {
      notifyListenersAndUI(e.toString());
    }
  }

  @override
  actionStart() async {
    late Frequency frequency;

    switch (kSensorSamplingRate) {
      case 1:
        frequency = Frequency.HZ1;
        break;
      case 10:
        frequency = Frequency.HZ10;
        break;
      case 100:
        frequency = Frequency.HZ100;
        break;
      case 1000:
        frequency = Frequency.HZ1000;
        break;
      default:
        throw const InitException(
            'Invalid frequency value for BITalino: $kSensorSamplingRate');
    }
    // TODO this is done in every implementation, should be in parent class
    channelSeries.resetTime();
    try {
      bool started = await controller.start(
        channels,
        frequency,
        numberOfSamples: 10,
        // classes for argument are compatible, but need to cast
        onDataAvailable: onDataAvailable,
      );
      channelsRecording = [...channels];
      notifyListenersAndUI("Started: $started");
    } catch (e) {
      notifyListenersAndUI(e.toString());
    }
  }

  @override
  actionStop() async {
    try {
      bool stopped = await controller.stop();
      notifyListenersAndUI("Stopped: $stopped");
    } catch (e) {
      notifyListenersAndUI(e.toString());
    }
  }
}
