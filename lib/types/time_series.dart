import 'dart:async';

import '../constants.dart';
import 'time_series_types.dart';

class TimeSeries<T> {
  final List<TimeSeriesItem<T>> _timeSeriesItems = <TimeSeriesItem<T>>[];
  int? maxCount; // Set this to limit the number of items
  final int maxElapsedMs = kPlotTimeSeriesDurationSeconds * 1000;

  bool isStreamEnabled = false;

  late final StreamController<TimeSeriesItem<T>> _streamController =
      StreamController<TimeSeriesItem<T>>(
    onListen: _startStream,
    onPause: _stopStream,
    onResume: _startStream,
    onCancel: _stopStream,
  );

  List<TimeSeriesItem<T>> get timeSeriesItems => _timeSeriesItems;

  /// Listen to this stream to get notified on new item
  Stream<TimeSeriesItem<T>> get stream => _streamController.stream;

  void add(TimeSeriesItem<T> item) {
    _timeSeriesItems.add(item);

    if (maxCount != null && _timeSeriesItems.length > maxCount!) {
      _timeSeriesItems.removeAt(0);
    }

    int removeBefore = DateTime.now().millisecondsSinceEpoch - maxElapsedMs;

    while (_timeSeriesItems.isNotEmpty &&
        _timeSeriesItems.first.time.millisecondsSinceEpoch < removeBefore) {
      _timeSeriesItems.removeAt(0);
    }

    if (isStreamEnabled) {
      _streamController.add(item);
    }
  }

  TimeSeriesItem<T> addNow(T value) {
    TimeSeriesItem<T> item = TimeSeriesItem.createNow(value);
    add(item);
    return item;
  }

  void _startStream() {
    isStreamEnabled = true;
  }

  void _stopStream() {
    isStreamEnabled = false;
  }

  bool hasAtLeastTwoPoints() {
    return _timeSeriesItems.length >= 2;
  }

  static int elapsedSeconds(DateTime time) =>
      (DateTime.now().millisecondsSinceEpoch - time.millisecondsSinceEpoch) ~/
      1000;

  static String toStringPositive(int value) {
    String ret = value >= 0 ? value.toString() : '';
    return ret;
  }

  static String getElapsedSecondsStr(DateTime time) {
    return toStringPositive(elapsedSeconds(time));
  }
}
