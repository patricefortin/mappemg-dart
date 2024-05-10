import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../constants.dart';
import '../../models/sensor_model.dart';

class SensorReplayFileModel extends SensorModel {
  bool isInitialized = true;
  bool isFileReady = false;
  bool isReplaying = false;
  File? file;

  String _filepath = kSensorDefaultReplayFile;

  @override
  String get address => _filepath;

  @override
  set address(value) {
    _filepath = value;
  }

  @override
  String get status {
    if (isCalibrating) {
      return 'calibrating (${kSensorCalibrationDurationSeconds}s)';
    }
    if (isReplaying) {
      return 'replaying ($_filepath)';
    }
    if (isFileReady) {
      return 'replay ready ($_filepath)';
    }
    if (isInitialized) {
      return 'replay initialized';
    }
    return 'uninitialized';
  }

  @override
  bool get canConnect => isInitialized;

  @override
  bool get canDisconnect => isFileReady;

  @override
  bool get canSaveMVC => isFileReady && isReplaying && !isCalibrating;

  @override
  bool get canStart => isFileReady;

  @override
  bool get canStop => isFileReady && isReplaying;

  @override
  Future<void> initPlatformState(String address) async {
    savePrefsLastAddress(address);
    isInitialized = true;
    _filepath = address;
    notifyListenersAndUI('initialized');
  }

  @override
  actionConnect() async {
    file = File(_filepath);
    isFileReady = true;
    notifyListenersAndUI('connected');
  }

  @override
  actionDisconnect() async {
    file = null;
    isFileReady = false;
    notifyListenersAndUI('disconnected');
  }

  @override
  actionStart() async {
    if (file == null) {
      notifyListenersAndUI('File is not initialized');
      return;
    }
    notifyListenersAndUI('start replay');

    isReplaying = true;
    int sequenceCounter = 0;
    channelSeries.resetTime();

    // Update the channels to display, in case it changed in the UI
    channelsRecording = [...channels];

    // Call onDataAvailable (multiple times) only after a certain time, to avoid having periodic of 1ms
    // We wait 1ms*stepSize then call onDataAvailable multiple times with all our data.
    // If we don't have enough data, we loop over the same data
    int stepSize =
        kSensorStepSize; // use the default step size as our chunk size

    // Load the data
    List<List<int>> analogs = [];
    Stream<String> lines = file!
        .openRead()
        .transform(utf8.decoder) // Decode bytes to UTF-8.
        .transform(const LineSplitter()); // Convert stream to individual lines.

    await for (var line in lines) {
      // Format is:
      //   1689621284579;[509, 0, 0, 0, 0, 0]
      //   ...
      var pieces = line.split(';');
      var analogJson = pieces[1].trim();
      var analog = List<int>.from(jsonDecode(analogJson));
      analogs.add(analog);
    }

    // Read the file in loop
    int j = 0;
    int iOffset = 0;
    int index = 0;
    late Timer timer;
    timer = Timer.periodic(Duration(milliseconds: stepSize), (Timer t) async {
      for (var i = 0; i < stepSize; i++) {
        if (!isReplaying) {
          timer.cancel();
          break;
        }

        index = j * stepSize + i - iOffset;

        if (index >= analogs.length) {
          j = 0;
          // offset for the next iteration, to start reading at zero
          iOffset = i;
          index = i - iOffset;
        }

        try {
          onDataAvailable(SensorFrame(
            identifier: '',
            sequence: sequenceCounter % 15,
            analog: analogs[index],
            digital: [],
          ));
          sequenceCounter += 1;
        } catch (e) {
          notifyListenersAndUI('Error: $e');
        }
      }
      j += 1;
    });
  }

  @override
  actionStop() async {
    isReplaying = false;
    notifyListenersAndUI('stop replay');
  }
  
}