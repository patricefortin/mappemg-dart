import 'package:flutter_test/flutter_test.dart';
import 'package:mappemg/signal_processing/channel_series.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('ChannelSeries -', () {
    ChannelSeries getTestChannelSeries() => ChannelSeries(
          channelCount: 2,
          keepTimeMs: 100,
          samplingRate: 100,
          averagedStepSize: 1,
          channelsOfInterest: [0, 1],
          isSpectrumEnabled: true,
          isDerivativesEnabled: false,
          isLowPassAveragedEnabled: false,
          offsetRawForZero: 0,
        );
    test('can add', () {
      ChannelSeries channelSeries = getTestChannelSeries();
      expect(channelSeries.rowCount, 0);

      channelSeries.addNow([1, 2]);
      expect(channelSeries.rowCount, 1);
    });

    test('count stops when matrix is full', () {
      ChannelSeries channelSeries = ChannelSeries(
        channelCount: 2,
        keepTimeMs: 2000,
        samplingRate: 1,
        averagedStepSize: 1,
        channelsOfInterest: [0, 1],
        isSpectrumEnabled: true,
        isDerivativesEnabled: false,
        isLowPassAveragedEnabled: false,
        offsetRawForZero: 0,
      );
      expect(channelSeries.matrixWidthChannelOnly, 2);
      expect(channelSeries.matrixHeightCapacity, 2);
      expect(channelSeries.rowCount, 0);

      channelSeries.addNow([1, 2]);
      expect(channelSeries.rowCount, 1);

      channelSeries.addNow([1, 2]);
      expect(channelSeries.rowCount, 2);

      // Should not add anymore
      channelSeries.addNow([1, 2]);
      expect(channelSeries.rowCount, 2);
    });

    test('average', () {
      ChannelSeries channelSeries = ChannelSeries(
        channelCount: 2,
        keepTimeMs: 2000,
        samplingRate: 1,
        averagedStepSize: 1,
        channelsOfInterest: [0, 1],
        isSpectrumEnabled: true,
        isDerivativesEnabled: false,
        isLowPassAveragedEnabled: false,
        offsetRawForZero: 0,
      );

      channelSeries.addNow([1, 2]);
      expect(channelSeries.getAverageForChannel(0), greaterThan(0));
      expect(channelSeries.getAverageForChannel(1), greaterThan(0));

      channelSeries.addNow([2, 4]);
      expect(channelSeries.getAverageForChannel(0), greaterThan(0));
      expect(channelSeries.getAverageForChannel(1),
          greaterThan(channelSeries.getAverageForChannel(0)));
    });

    test('change averaged step size', () {
      ChannelSeries channelSeries = ChannelSeries(
        channelCount: 1,
        keepTimeMs: 4000,
        samplingRate: 1,
        averagedStepSize: 1,
        channelsOfInterest: [0],
        isSpectrumEnabled: true,
        isDerivativesEnabled: false,
        isLowPassAveragedEnabled: false,
        offsetRawForZero: 0,
      );

      channelSeries.addNow([1]);
      channelSeries.addNow([2]);
      channelSeries.addNow([3]);
      channelSeries.addNow([4]);
      channelSeries.addNow([5]);

      // Should keep 4 values to fill the required "keepTimeMs"
      expect(channelSeries.averagedMatrix.length, 4);
      double lastValue = channelSeries.averagedMatrix[0][0][0];

      channelSeries.changeAveragedStepSize(2);
      // Check resetted
      expect(channelSeries.averagedMatrix.length, 0);
      expect(channelSeries.windowSumVector[0], 0);

      channelSeries.addNow([6]);
      channelSeries.addNow([7]);
      channelSeries.addNow([8]);
      channelSeries.addNow([9]);

      // Should not have changed, since we are not on step
      expect(channelSeries.averagedMatrix[0][0][0], lastValue);

      // Should now keep 2 values to fill the required "keepTimeMs"
      expect(channelSeries.averagedMatrix.length, 2);
    });

    // test('items are dropped after max', () {
    //   TimeSeries<int> timeSeries = TimeSeries<int>();
    //   timeSeries.maxCount = 1;
    //   timeSeries.add(TimeSeriesItem<int>(DateTime.now(), 1));
    //   expect(timeSeries.timeSeriesItems.length, 1);
    //   timeSeries.add(TimeSeriesItem<int>(DateTime.now(), 2));
    //   expect(timeSeries.timeSeriesItems.length, 1);
    // });

    // test('add now', () {
    //   var now = DateTime.now();
    //   TimeSeries<int> timeSeries = TimeSeries<int>();
    //   timeSeries.addNow(1);
    //   expect(timeSeries.timeSeriesItems.length, 1);
    //   expect(timeSeries.timeSeriesItems[0].time.millisecond,
    //       greaterThanOrEqualTo(now.millisecond));
    // });
  });
}
