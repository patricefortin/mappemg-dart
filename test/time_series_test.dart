import 'package:flutter_test/flutter_test.dart';
import 'package:mappemg/types/time_series.dart';
import 'package:mappemg/types/time_series_types.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('TimeSeries -', () {
    test('can add', () {
      TimeSeries<int> timeSeries = TimeSeries<int>();
      expect(timeSeries.timeSeriesItems.length, 0);
      timeSeries.add(TimeSeriesItem<int>(DateTime.now(), 1));
      expect(timeSeries.timeSeriesItems.length, 1);
    });

    test('items are dropped after max', () {
      TimeSeries<int> timeSeries = TimeSeries<int>();
      timeSeries.maxCount = 1;
      timeSeries.add(TimeSeriesItem<int>(DateTime.now(), 1));
      expect(timeSeries.timeSeriesItems.length, 1);
      timeSeries.add(TimeSeriesItem<int>(DateTime.now(), 2));
      expect(timeSeries.timeSeriesItems.length, 1);
    });

    test('add now', () {
      var now = DateTime.now();
      TimeSeries<int> timeSeries = TimeSeries<int>();
      timeSeries.addNow(1);
      expect(timeSeries.timeSeriesItems.length, 1);
      expect(timeSeries.timeSeriesItems[0].time.millisecond,
          greaterThanOrEqualTo(now.millisecond));
    });
  });
}
