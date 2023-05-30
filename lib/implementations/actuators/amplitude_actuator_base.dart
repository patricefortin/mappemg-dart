import 'package:scoped_model/scoped_model.dart';

import '../../configuration.dart';
import '../../constants.dart';
import '../../interfaces/i_amplitude_actuator.dart';
import '../../interfaces/i_with_window_step.dart';
import '../../types/time_series_types.dart';

abstract class AmplitudeActuatorBase extends Model
    implements IAmplitudeActuator, IWithWindowStep {
  double _amplitudeAvg = 0;
  int _lastTimestamp = 0;

  // TODO unhardcode this value
  // final _expectedPeriodMs = 100000; // TODO remove this value
  final _dropOldAfterMS = 1000;
  int _stepSize =
      kActuatorVibrationDefaultStepSize; // how many to accumulate before sending
  int _windowSize = kActuatorVibrationDefaultWindowSize; // sliding window size

  // iterators
  int _step = 0;
  int _windowCursor = 0;

  List<double>? lastValues;
  double lastActuatedValue = 0; // TODO: should we remove the default?

  @override
  Future<void> debounceActuate(double amplitude) async {
    int currentIndex = _windowCursor % _windowSize;
    lastValues![currentIndex] = amplitude;
    _windowCursor++;
    _step++;

    _windowCursor %= _windowSize; // make sure we never overflow

    int now = DateTime.now().millisecondsSinceEpoch;
    int delta = now - _lastTimestamp;
    // int deltaMax = _expectedPeriodMs * (_stepSize + 1);

    // TODO refine this logic and find better names
    bool isOnStep = _step >= _stepSize;
    // bool isDeltaBig = (delta >= deltaMax);
    bool isDeltaTooBig = delta >= _dropOldAfterMS;
    bool shouldActuateNow = isOnStep /* || isDeltaBig */ || isDeltaTooBig;

    if (shouldActuateNow) {
      _amplitudeAvg = 0;

      if (isDeltaTooBig) {
        // Clear the last values
        getLogger().d(
            'ActuatorBase: time delta is too big, probably we did not receive values for some time. Clearing the lastValues and using only last one');
        for (int i = 0; i < _windowSize; i++) {
          if (i != currentIndex) {
            lastValues![i] = 0;
          }
        }
        _amplitudeAvg = lastValues![currentIndex];
      } else {
        for (int i = 0; i < _windowSize; i++) {
          _amplitudeAvg += lastValues![i];
        }
        _amplitudeAvg = _amplitudeAvg / _windowSize;
      }

      // logger.d('ActuatorBase: Sending, delta: $delta, acc: $_step, ptr: $_windowCursor, avg: $_amplitudeAvg');

      actuate(_amplitudeAvg);
      _step = 0;
    } else {
      // logger.d('Not sending');
    }

    _lastTimestamp = now;
    // we might lose the last few received values
  }

  // Specific to this implementation
  @override
  int get stepSize => _stepSize;

  @override
  set stepSize(int size) {
    _stepSize = size;
    getLogger().i(
        'ActuatorBase: Setting new step size to $size. New windowCursor: $_windowCursor');
    notifyListeners();
  }

  @override
  void decrementStepSize() {
    if (stepSize <= 1) {
      return;
    }
    stepSize = stepSize - 1;
  }

  @override
  void incrementStepSize() {
    stepSize = stepSize + 1;
  }

  @override
  int get windowSize => _windowSize;

  @override
  set windowSize(int size) {
    _windowSize = size;
    List<double> nextLastValues = List<double>.filled(size, _amplitudeAvg);
    for (int i = 0; i < nextLastValues.length && i < lastValues!.length; i++) {
      nextLastValues[i] = lastValues![i];
    }
    _windowCursor %= nextLastValues.length;
    lastValues = nextLastValues; // swap the lists
    getLogger().i(
        'ActuatorBase: Setting new step size to $size. New windowCursor: $_windowCursor. Content: ${lastValues.toString()}');
    notifyListeners();
  }

  @override
  void decrementWindowSize() {
    if (windowSize <= 1) {
      return;
    }
    windowSize = windowSize - 1;
  }

  @override
  void incrementWindowSize() {
    windowSize = windowSize + 1;
  }

  @override
  Future<void> actuate(double amplitude) async {
    lastActuatedValue = amplitude;
  }

  @override
  double get lastAmplitudeValue {
    return lastActuatedValue;
  }
}
