import 'dart:async';

import 'package:circular_buffer/circular_buffer.dart';
import 'package:flutter/scheduler.dart';
import 'package:vibration/vibration.dart';

import '../../configuration.dart';
import '../../constants.dart';
import '../../mapping/in_out_mapper.dart';
import '../../models/core_model.dart';
import '../../types/time_series_types.dart';
import 'amplitude_actuator_base.dart';

class AmplitudeActuatorVibrator extends AmplitudeActuatorBase {
  AmplitudeActuatorVibrator({required this.coreModel});
  CoreModel coreModel;
  bool physicalVibrationEnabled = false;
  bool amplitudeControlEnabled = false;
  bool hasValues = false;

  // This `createTicker` must be set by a UI widget (probably in main.dart), so that we can use the ticker
  late Function(TickerCallback) createTicker;
  late Ticker _ticker;

  // Set our duration for vibration as the SensorStepSize
  // This means that we will vibrate every value for SensorStepSize milliseconds
  // It works only for 1000Hz, where the sampling period is 1ms
  // Ex: [25, 25, 25, 25, 25]
  late List<int> actuatorPatternsMilliseconds =
      List.filled(kActuatorVibrationBufferSize, kSensorStepSize);

  int periodicDurationMs = kActuatorVibrationBufferSize * kSensorStepSize;

  late CircularBuffer<int> actuatorAmplitudesCircularBuffer =
      CircularBuffer(kActuatorVibrationBufferSize);

  int bufferIndex = 0;

  // Ticker for periodically sending the vibration
  int _sumElapsedTicker = 0;
  int _lastNowTicker = 0;

  @override
  Future<void> init() async {
    lastValues = List<double>.filled(windowSize, 0);
    try {
      bool hasVibrator = await Vibration.hasVibrator() ?? false;
      bool hasAmplitudeControl = await Vibration.hasAmplitudeControl() ?? false;
      if (hasVibrator != false) {
        physicalVibrationEnabled = true;
      }
      if (hasAmplitudeControl != false) {
        amplitudeControlEnabled = true;
      }
    } catch (e) {
      getLogger().d('Exception while checking for vibration');
    }
    getLogger()
        .d('Vibration is ${physicalVibrationEnabled ? 'ENABLED' : 'DISABLED'}');

    _ticker = createTicker((elapsed) {
      int nowTicker = elapsed.inMilliseconds;
      int elapsedMs = nowTicker - _lastNowTicker;
      _lastNowTicker = nowTicker;
      _sumElapsedTicker += elapsedMs;
      if (_sumElapsedTicker >= periodicDurationMs) {
        _periodicVibrate();
        _sumElapsedTicker = 0;
      }
    });
    _ticker.start();
  }

  void _periodicVibrate() {
    // var now = DateTime.now().millisecondsSinceEpoch;
    // var diff = now - _lastMs;
    // getLogger().d(
    //     'now: ${now} (delta: ${now - _lastMs}) (should be ${periodicDurationMs}ms), pattern: $actuatorPatternsMilliseconds');
    // _lastMs = now;

    if (hasValues) {
      if (!physicalVibrationEnabled) {
        return;
      }

      if (!amplitudeControlEnabled) {
        getLogger().w('NO AMPLITUDE CONTROL FOR VIBRATION');
        return;
      }

      // Don't use repeat here, it makes the whole device get stuck
      if (actuatorAmplitudesCircularBuffer.indexWhere((a) => a > 1) != -1) {
        if (coreModel.inOutMap.physicalVibrationEnabled) {
          Vibration.vibrate(
              pattern: actuatorPatternsMilliseconds.sublist(
                  0, actuatorAmplitudesCircularBuffer.length),
              intensities: actuatorAmplitudesCircularBuffer,
              repeat: -1);
        }
      } else {
        if (coreModel.inOutMap.physicalVibrationEnabled) {
          Vibration.cancel();
        }
      }
      hasValues = false;
    }
  }

  @override
  Future<void> actuate(double normalizedAmplitude) async {
    super.actuate(normalizedAmplitude);

    double actuatorAmplitude =
        normalizedAmplitude >= kActuatorVibrationZeroThreshold
            ? outputAmplitudeActuatorVibrationMap.getDouble(normalizedAmplitude)
            : 1;

    actuatorAmplitudesCircularBuffer.add(actuatorAmplitude.toInt());
    hasValues = true;

    coreModel.addToVibrationTimeSeries(
        TimeSeriesItem<double>(DateTime.now(), normalizedAmplitude));
  }
}
