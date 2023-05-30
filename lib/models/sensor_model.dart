import 'dart:async';

import 'package:bitalino/bitalino.dart';
import 'package:scoped_model/scoped_model.dart';

import '../configuration.dart';
import '../constants.dart';
import '../interfaces/i_with_window_step.dart';
import '../signal_processing/channel_series.dart';
import '../types/common.dart';

// Need to use the BITalinoFrame type for efficiency (avoid creating new object)
// There should be a way to create a generic with a type that matches without depending on bitalino here
typedef SensorFrame = BITalinoFrame;

abstract class SensorModel extends Model implements IWithWindowStep {
  final List<int> availableChannels = [0, 1, 2, 3, 4, 5];
  // one more column for the average
  late int channelsAverageIndex = availableChannels.length;

  final int channelCount = 6;

  List<int> _channels = [0];
  List<int> _channelsRecording = [0];
  Notify? uiNotify;
  int activeChannelIndex = 0;
  int get noDerivativeIndex => channelSeries.noDerivativeIndex;
  int get firstDerivativeIndex => channelSeries.firstDerivativeIndex;
  int get secondDerivativeIndex => channelSeries.secondDerivativeIndex;
  int get thirdDerivativeIndex => channelSeries.thirdDerivativeIndex;
  bool isCalibrating = false;
  bool isBandPassControlsEnabled = kSensorBandPassControlsEnabled;
  bool isMovingAverageControlsEnabled = kSensorMovingAverageControlsEnabled;

  // Time series structures
  late ChannelSeries channelSeries = ChannelSeries(
    samplingRate: kSensorSamplingRate,
    keepTimeMs: kPlotTimeSeriesDurationSeconds * 1000,
    channelCount: channelCount,
    averagedStepSize: kSensorStepSize,
    channelsOfInterest: channelsRecording,
    isSpectrumEnabled: kSensorSpectrumEnabled,
    isDerivativesEnabled: kSensorDerivativesEnabled,
    isLowPassAveragedEnabled: kSensorLowPassAveragedEnabled,
    offsetRawForZero: kSensorOffsetRawForZero.toDouble(),
  );

  // Signal processing
  int _dataCounter = 0;

  // Millivolt conversion
  static int sensorSamplingResolution = kSensorSamplingRate;
  static double sensorVCC = 3.3;
  static int sensorGain = 1009;

  /// Formula from electromyography-emg-user-manual.pdf
  /// > In most applications, the original physical unit of the acquired EMG signal is preferred or required.
  /// > The raw digital sensor samples can be converted back into millivolt (mV) using the following formulas:
  ///   Value in volt = ((ADC/2^n - 1/2) * VCC) / gain
  ///   multiply by 1000 to get in mV
  static double toMillivolt(int adcValue) {
    return (adcValue / (2 ^ sensorSamplingResolution) - 0.5) *
        sensorVCC /
        sensorGain *
        1000;
  }

  void notifyListenersAndUI(dynamic msg) {
    notifyListeners();
    getLogger().d(msg);
    uiNotify!(msg);
  }

  void setActiveChannelIndex(int? value) {
    if (value == null) {
      return;
    }
    activeChannelIndex = value;
    notifyListeners();
  }

  List<int> get channels => _channels;
  set channels(List<int> value) {
    _channels = value;
    notifyListeners();
  }

  List<int> get channelsRecording => _channelsRecording;
  set channelsRecording(List<int> value) {
    _channelsRecording = value;
    channelSeries.channelsOfInterest = _channelsRecording;
  }

  // override this method
  String get address;

  Future<void> initPlatformState(String address);
  String get status;
  bool get canConnect;
  bool get canDisconnect;
  bool get canStart;
  bool get canStop;
  bool get canSaveMVC;

  bool isAnalogChannelEnabled(int channel) {
    return _channels.indexWhere((element) => element == channel) != -1;
  }

  bool isAnalogChannelRecording(int channel) {
    return _channelsRecording.indexWhere((element) => element == channel) != -1;
  }

  void setAnalogChannelEnabled(int channel, bool value) {
    _channels.removeWhere((element) => element == channel);
    if (value) {
      _channels.add(channel);
      _channels.sort((a, b) => a < b ? -1 : 1);
    }
    notifyListeners();
  }

  void toggleAnalogChannelEnabled(int channel) {
    bool nextValue = !isAnalogChannelEnabled(channel);
    setAnalogChannelEnabled(channel, nextValue);
  }

  void onDataAvailable(SensorFrame frame) {
    _dataCounter++;
    channelSeries.addNow(frame.analog);

    // TODO not sure if this is still useful
    if (_dataCounter % kSensorNotifyListenersEveryNStepSize == 0) {
      notifyListeners();
    }
  }

  bool getIsEnabledSpectrum() => channelSeries.isSpectrumEnabled;
  void setIsEnabledSpectrum(bool value) {
    channelSeries.isSpectrumEnabled = value;
    notifyListeners();
  }

  bool getIsEnabledDerivatives() => channelSeries.isDerivativesEnabled;
  void setIsEnabledDerivatives(bool value) {
    channelSeries.isDerivativesEnabled = value;
    notifyListeners();
  }

  bool getIsEnabledLowPassAveraged() => channelSeries.isLowPassAveragedEnabled;
  void setIsEnabledLowPassAveraged(bool value) {
    channelSeries.isLowPassAveragedEnabled = value;
    notifyListeners();
  }

  bool getIsEnabledBandPassControls() => isBandPassControlsEnabled;
  void setIsEnabledBandPassControls(bool value) {
    isBandPassControlsEnabled = value;
    notifyListeners();
  }

  bool getIsEnabledMovingAverageControls() => isMovingAverageControlsEnabled;
  void setIsEnabledMovingAverageControls(bool value) {
    isMovingAverageControlsEnabled = value;
    notifyListeners();
  }

  actionConnect();
  actionDisconnect();
  actionStart();
  actionStop();

  actionSaveMVC() async {
    isCalibrating = true;
    channelSeries.startParamsCalibration();
    notifyListenersAndUI('Start watching for MVC');

    int i = kSensorCalibrationDurationSeconds - 1;
    Timer timer =
        Timer.periodic(const Duration(seconds: 1), (Timer localTimer) {
      notifyListenersAndUI('Recording MVC: $i');
      i -= 1;
    });

    Future.delayed(const Duration(seconds: kSensorCalibrationDurationSeconds),
        () {
      timer.cancel();
      channelSeries.stopParamsCalibration();
      isCalibrating = false;
      notifyListenersAndUI('Stop watching for MVC');
    });
  }

  @override
  int get stepSize => channelSeries.averagedStepSize;

  @override
  set stepSize(int size) {
    channelSeries.changeAveragedStepSize(size);
    getLogger().i('Setting new step size for channelSeries to $size');
    notifyListeners();
  }

  @override
  int get windowSize => channelSeries.paramsVector[0].windowSize;

  @override
  set windowSize(int size) {
    channelSeries.changeAveragedWindowSize(size);
    getLogger().i('Setting new window size for channelSeries to $size');
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

  void decrementBandPassCenterFreq() {
    double inc = 20;
    if (channelSeries.bpCenterFreq <= inc) {
      return;
    }
    channelSeries.bpCenterFreq = channelSeries.bpCenterFreq - inc;
  }

  void incrementBandPassCenterFreq() {
    double inc = 20;
    channelSeries.bpCenterFreq = channelSeries.bpCenterFreq + inc;
  }

  void decrementBandPassWidthFreq() {
    double inc = 20;
    if (channelSeries.bpWidthFreq <= inc) {
      return;
    }
    channelSeries.bpWidthFreq = channelSeries.bpWidthFreq - inc;
  }

  void incrementBandPassWidthFreq() {
    double inc = 20;
    channelSeries.bpWidthFreq = channelSeries.bpWidthFreq + inc;
  }

  void decrementBandPassOrder() {
    int inc = 1;
    if (channelSeries.bpOrder <= inc) {
      return;
    }
    channelSeries.bpOrder = channelSeries.bpOrder - inc;
  }

  void incrementBandPassOrder() {
    int inc = 1;
    channelSeries.bpOrder = channelSeries.bpOrder + inc;
  }
}
