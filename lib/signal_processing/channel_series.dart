import 'dart:async';
import 'dart:math';
import 'package:iirjdart/butterworth.dart';
import 'package:circular_buffer/circular_buffer.dart';
import 'package:fftea/fftea.dart';

import '../constants.dart';
import 'signal_params.dart';

class ChannelSeries {
  ChannelSeries({
    required this.samplingRate,
    required this.keepTimeMs,
    required this.averagedStepSize, // Window size is per channel
    required this.channelsOfInterest,
    required this.isSpectrumEnabled,
    required this.isDerivativesEnabled,
    required this.isLowPassAveragedEnabled,
    required this.channelCount,
    required this.offsetRawForZero,
  }) {
    // Init the filters
    resetFilters();
  }

  //
  // Handling raw data
  //

  /// which channel to save
  List<int> channelsOfInterest;

  /// actual number of channels in raw data
  final int channelCount;

  /// sampling rate of received data
  final int samplingRate;

  /// how long to keep the data for display
  final int keepTimeMs;

  /// add/substract to every raw value to bring around zero
  final double offsetRawForZero;

  /// size of each time increment (depends on sampling rate)
  late double timeIncrement = 1 / samplingRate * 1000;

  /// keep track of the last received timestamp, and only add time increment
  double lastReceivedTime = 0;

  //
  // Filtering
  //

  /// moving average step size (how many steps to wait until we re-compute the moving average)
  int averagedStepSize;

  /// band-pass filter Butterworth order
  late int _bpOrder = kSensorBandPassOrder;

  /// band-pass filter center frequency
  late double _bpCenterFreq = kSensorBandPassCenterFreq;

  /// band-pass filter width of frequency (related to the center)
  late double _bpWidthFreq = kSensorBandPassWidthFreq;

  /// list of the IIR filters for every channels
  late final List<Butterworth> _bpFilters = List<Butterworth>.generate(
      channelCount, (index) => Butterworth(),
      growable: false);

  late final List<Butterworth> _lpAveragedFilters = List<Butterworth>.generate(
      channelCount, (index) => Butterworth(),
      growable: false);

  //
  // Data matrices
  //

  // actual width of matrices, including meta data of every frame, 1 extra column for time
  // number of column (width) to be added for extra data on each record
  // 1: average of all channels of interest for one frame
  // 2: timestamp
  late int matrixWidth = channelCount + 2;

  /// maximum height of our data matrices (will extend until this capacity)
  late int matrixHeightCapacity = samplingRate * keepTimeMs ~/ 1000;

  /// number of actual channels from sensor
  late int matrixWidthChannelOnly = channelCount;

  /// index of extra columns for frame average
  int get indexChannelsAverage => matrixWidthChannelOnly;

  /// index of extra columns for timestamp
  int get indexTime => indexChannelsAverage + 1;

  /// 2D matrix for raw samples (column: channel, row: sample frame)
  late CircularBuffer<List<double>> rawMatrix =
      CircularBuffer<List<double>>(matrixHeightCapacity);

  /// 2D matrix for band filtered and rectified samples
  late CircularBuffer<List<double>> filteredRectifiedMatrix =
      CircularBuffer<List<double>>(matrixHeightCapacity);

  /// 3D matrix for window averaged values and its derivatives, every "step size"
  late CircularBuffer<List<List<double>>> averagedMatrix =
      getNewAveragedMatrix();

  int derivativesCount = 4; // +1 for no derivative

  int noDerivativeIndex = 0;
  int firstDerivativeIndex = 1;
  int secondDerivativeIndex = 2;
  int thirdDerivativeIndex = 3;

  int firstDerivativeGap = 2;
  int secondDerivativeGap = 3;
  int thirdDerivativeGap = 4;

  /// Transposed 2D matrix for computing spectrum
  late List<CircularBuffer<double>> rawMatrixByColumn =
      List<CircularBuffer<double>>.generate(
          matrixWidth, (index) => CircularBuffer(matrixHeightCapacity));

  /// Transposed 2D matrix for computing spectrum
  late List<CircularBuffer<double>> filteredMatrixByColumn =
      List<CircularBuffer<double>>.generate(
          matrixWidth, (index) => CircularBuffer(matrixHeightCapacity));

  /// 1D vector for sum of every column of average matrix
  late List<double> windowSumVector =
      List<double>.filled(channelCount, 0, growable: false);

  // calibrated parameters for every column (channel)
  late List<SignalParams> paramsVector = List<SignalParams>.generate(
      channelCount,
      (index) => SignalParams(
          channelName: 'A${index + 1}', samplingRate: samplingRate),
      growable: false);

  //
  // Counters
  //

  /// total amount of received frames
  int _receivedCount = 0;

  /// number of rows in our circular buffers
  int _rowCount = 0;

  //
  // Spectrum
  //

  /// enable/disable the spectrum computation
  bool isSpectrumEnabled;
  bool isDerivativesEnabled;
  bool isLowPassAveragedEnabled;

  /// width of the fft window
  final int fftWidth = 1024;

  /// half the width of the fft window
  final int fftHalfWidth = 512;

  /// how many numeric frequencies to group per "bin"
  final int fftBinWidth = 10;

  //// the total count of bins
  late int fftBinCount = fftHalfWidth ~/ fftBinCount;

  /// pre initialized fft object
  late FFT fft = FFT(fftWidth);

  /// spectrum results for raw data
  late List<List<double>> rawSpectrums = List.generate(
      fftHalfWidth ~/ fftBinWidth, (index) => List.filled(matrixWidth, 0));

  /// spectrum results from filtered data
  late List<List<double>> filteredSpectrums = List.generate(
      fftHalfWidth ~/ fftBinWidth, (index) => List.filled(matrixWidth, 0));

  //
  // Intra-app data streams
  //

  /// enable/disable the streaming of raw data
  bool isRawStreamEnabled = false;

  /// stream controller for raw data
  late final StreamController<List<double>> _rawStreamController =
      StreamController<List<double>>(
    onListen: _startRawStream,
    onPause: _stopRawStream,
    onResume: _startRawStream,
    onCancel: _stopRawStream,
  );

  /// enable/disable the streaming of averaged data
  bool isAveragedStreamEnabled = false;

  /// stream controller for averaged data and its derivatives
  late final StreamController<List<List<double>>> _averagedStreamController =
      StreamController<List<List<double>>>(
    onListen: _startAveragedStream,
    onPause: _stopAveragedStream,
    onResume: _startAveragedStream,
    onCancel: _stopAveragedStream,
  );

  //
  // Getters / Setters
  //

  int get rowCount => _rowCount;

  int get bpOrder => _bpOrder;
  double get bpCenterFreq => _bpCenterFreq;
  double get bpWidthFreq => _bpWidthFreq;

  set bpOrder(int value) {
    _bpOrder = value;
    resetFilters();
  }

  set bpCenterFreq(double value) {
    _bpCenterFreq = value;
    resetFilters();
  }

  set bpWidthFreq(double value) {
    _bpWidthFreq = value;
    resetFilters();
  }

  /// Listen to this stream to get notified on new item
  Stream<List<List<double>>> get averagedStream =>
      _averagedStreamController.stream;
  Stream<List<double>> get rawStream => _rawStreamController.stream;

  void _startAveragedStream() {
    isAveragedStreamEnabled = true;
  }

  void _stopAveragedStream() {
    isAveragedStreamEnabled = false;
  }

  void _startRawStream() {
    isRawStreamEnabled = true;
  }

  void _stopRawStream() {
    isRawStreamEnabled = false;
  }

  static String asString(List<double> record) {
    // Time is the last item in the list
    int indexTime = record.length - 1;
    return '${record[indexTime].toInt()};[${record.sublist(0, indexTime - 1).map((value) => value.toInt()).join(',')}]';
  }

  CircularBuffer<List<List<double>>> getNewAveragedMatrix() {
    return CircularBuffer<List<List<double>>>(
        matrixHeightCapacity ~/ averagedStepSize);
  }

  void resetFilters() {
    for (var i = 0; i < _bpFilters.length; i++) {
      _bpFilters[i].bandPass(
        _bpOrder,
        kSensorSamplingRate.toDouble(),
        _bpCenterFreq,
        _bpWidthFreq,
      );

      _lpAveragedFilters[i].lowPass(
        _bpOrder,
        1000 / kSensorStepSize,
        kSensorLowPassAveragedCutoffFreq,
      );
    }
  }

  // Used for temporary storage of filtered data, not kept in circular buffers
  // Initialize once for the class instead of allocating memory on every record received
  late List<double> tmpFilteredVector =
      List<double>.filled(matrixWidth, 0, growable: false);

  void addNow(List<int> record) {
    // int microStart = DateTime.now().microsecondsSinceEpoch;
    double acc = 0;
    double filteredValue;

    // need to keep the time as double so it can go in our matrices
    if (lastReceivedTime == 0) {
      lastReceivedTime =
          DateTime.now().millisecondsSinceEpoch.toDouble() - timeIncrement;
    }
    lastReceivedTime += timeIncrement;
    _receivedCount++;

    List<double> rawVector = rawMatrix.isFilled
        ? rawMatrix[0]
        : List<double>.filled(matrixWidth, 0, growable: false);

    List<double> filteredRectifiedVector = filteredRectifiedMatrix.isFilled
        ? filteredRectifiedMatrix[0]
        : List<double>.filled(matrixWidth, 0, growable: false);

    List<List<double>> averagedVector = averagedMatrix.isFilled
        ? averagedMatrix[0]
        : List<List<double>>.generate(derivativesCount,
            (index) => List<double>.filled(matrixWidth, 0, growable: false),
            growable: false);

    // save time
    rawVector[indexTime] = lastReceivedTime;
    tmpFilteredVector[indexTime] = lastReceivedTime;
    filteredRectifiedVector[indexTime] = lastReceivedTime;
    for (var i = 0; i < derivativesCount; i++) {
      averagedVector[i][indexTime] = lastReceivedTime;
    }

    for (int i in channelsOfInterest) {
      rawVector[i] = record[i].toDouble() + offsetRawForZero; // save new value
      acc += rawVector[i];
    }
    rawVector[indexChannelsAverage] = acc;

    // Do the check before adding to matrices, to be sure _count reach length value
    if (rawMatrix.isUnfilled) {
      _rowCount += 1;
    }

    bool isOnStep = _receivedCount % averagedStepSize == 0;

    // Filter each channel
    acc = 0;
    for (int i in channelsOfInterest) {
      filteredValue = _bpFilters[i].filter(rawVector[i]);
      tmpFilteredVector[i] = filteredValue;
      filteredRectifiedVector[i] = filteredValue.abs();
      acc += filteredRectifiedVector[i];
    }
    filteredRectifiedVector[indexChannelsAverage] = acc;

    // Compute average
    SignalParams params;
    bool isWindowFull;
    double averagedValue;
    for (int i in channelsOfInterest) {
      // add new value
      windowSumVector[i] += filteredRectifiedVector[i];

      params = paramsVector[i];
      isWindowFull = rowCount >= params.windowSize;

      if (!isWindowFull) {
        continue;
      }

      // substract the value we are about to drop
      windowSumVector[i] -=
          filteredRectifiedMatrix[rowCount - params.windowSize][i];

      averagedValue = windowSumVector[i] / params.windowSize;

      // save the min/max
      if (params.isCalibrating) {
        if (params.minValue == null || averagedValue < params.minValue!) {
          params.minValue = averagedValue;
        }
        if (params.maxValue == null || averagedValue > params.maxValue!) {
          params.maxValue = averagedValue;
        }
      }
      if (isOnStep && params.isInitialized) {
        // actual signal
        if (isLowPassAveragedEnabled) {
          filteredValue = _lpAveragedFilters[i].filter(averagedValue);
          averagedVector[noDerivativeIndex][i] =
              params.normalize(filteredValue, cutZeroOne: true);
        } else {
          averagedVector[noDerivativeIndex][i] =
              params.normalize(averagedValue, cutZeroOne: true);
        }

        // first derivative
        if (isDerivativesEnabled &&
            averagedMatrix.length > firstDerivativeGap) {
          averagedVector[firstDerivativeIndex][i] =
              (averagedVector[noDerivativeIndex][i] -
                      averagedMatrix[averagedMatrix.length - firstDerivativeGap]
                          [noDerivativeIndex][i]) /
                  (firstDerivativeGap * timeIncrement);
        }

        // second derivative
        if (isDerivativesEnabled &&
            averagedMatrix.length > secondDerivativeGap) {
          averagedVector[secondDerivativeIndex]
              [i] = (averagedVector[firstDerivativeIndex][i] -
                  averagedMatrix[averagedMatrix.length - secondDerivativeGap]
                      [firstDerivativeIndex][i]) /
              (secondDerivativeGap * timeIncrement);
        }

        // third derivative
        if (isDerivativesEnabled &&
            averagedMatrix.length > thirdDerivativeGap) {
          averagedVector[thirdDerivativeIndex][i] =
              (averagedVector[secondDerivativeIndex][i] -
                      averagedMatrix[averagedMatrix.length - thirdDerivativeGap]
                          [secondDerivativeIndex][i]) /
                  (thirdDerivativeGap * timeIncrement);
        }
      }
    }

    // append to raw matrices
    rawMatrix.add(rawVector);
    for (int i in channelsOfInterest) {
      rawMatrixByColumn[i].add(rawVector[i]);
    }
    if (isRawStreamEnabled) {
      // notify all the listeners in application
      _rawStreamController.add(rawVector);
    }

    // append to filtered matrices
    filteredRectifiedMatrix.add(filteredRectifiedVector);
    for (int i in channelsOfInterest) {
      filteredMatrixByColumn[i].add(tmpFilteredVector[i]);
    }

    if (isOnStep) {
      acc = 0;
      for (int i in channelsOfInterest) {
        acc += averagedVector[noDerivativeIndex][i];
      }
      averagedVector[noDerivativeIndex][indexChannelsAverage] = acc;
      averagedMatrix.add(averagedVector);
      // notify all the listeners in application
      if (isAveragedStreamEnabled) {
        _averagedStreamController.add(averagedVector);
      }
    }

    // Spectrum
    if (isSpectrumEnabled && _receivedCount % fftHalfWidth == 0) {
      if (rawMatrix.isFilled) {
        computeSpectrum(rawMatrixByColumn, rawSpectrums);
      }
      if (filteredRectifiedMatrix.isFilled) {
        computeSpectrum(filteredMatrixByColumn, filteredSpectrums);
      }
    }

    // int microDuration = DateTime.now().microsecondsSinceEpoch - microStart;
    // getLogger().d('ChannelSeries addNow duration: $microDuration');
  }

  void computeSpectrum(List<CircularBuffer<double>> matrixByColumn,
      List<List<double>> spectrums) {
    double acc;
    for (int i in channelsOfInterest) {
      final magnitudes = fft
          .realFft(
              matrixByColumn[i].sublist(matrixByColumn[i].length - fftWidth))
          .discardConjugates()
          .magnitudes();

      for (var j = 0; j < fftHalfWidth ~/ fftBinWidth; j++) {
        spectrums[j][indexTime] =
            fft.frequency(j * fftBinWidth, kSensorSamplingRate.toDouble());
        acc = 0;
        for (var k = 0; k < fftBinWidth; k++) {
          if (j == 0 && k == 0) {
            acc += 0;
          } else {
            acc += magnitudes[j * fftBinWidth + k];
          }
        }
        spectrums[j][i] = acc;
      }
    }
  }

  double getAverageForChannel(int channel) {
    return windowSumVector[channel] / rowCount;
  }

  int getTime(List<double> record) {
    return record[indexTime].toInt();
  }

  void resetTime() {
    lastReceivedTime =
        DateTime.now().millisecondsSinceEpoch.toDouble() - timeIncrement;
  }

  void resetAveragedMatrix() {
    averagedMatrix = getNewAveragedMatrix();

    for (var i = 0; i < matrixWidthChannelOnly; i++) {
      windowSumVector[i] = 0;
    }
  }

  // We calibrate all the channel at the same time
  // IMPROVEMENT we should receive the channels in arguments, to calibrate each channel separately
  void startParamsCalibration() {
    for (var i = 0; i < paramsVector.length; i++) {
      paramsVector[i].isCalibrating = true;
    }
    resetAveragedMatrix();
  }

  void stopParamsCalibration() {
    for (var i = 0; i < paramsVector.length; i++) {
      paramsVector[i].isCalibrating = false;
    }
  }

  void changeAveragedStepSize(int value) {
    // step size can only be set for all channels at once
    averagedStepSize = value;
    resetAveragedMatrix();
  }

  void changeAveragedWindowSize(int windowSize) {
    // Window size is set in "params" of every channel, but we actually set them all at once

    // set in params and update sums
    for (var i = 0; i < matrixWidthChannelOnly; i++) {
      paramsVector[i].windowSize = windowSize;
      windowSumVector[i] = 0;
    }

    // recompute the sums for each channel, with the values we have
    for (var i = 0; i < matrixWidthChannelOnly; i++) {
      for (var j = 0;
          j < min(windowSize, filteredRectifiedMatrix.length);
          j++) {
        windowSumVector[i] += filteredRectifiedMatrix[j][i];
      }
    }
  }
}
