import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../constants.dart';
import '../../models/sensor_model.dart';
import '../../types/common.dart';
import '../bits/plot_time_series.dart';
import '../bits/window_step_controls.dart';

String getChannelName(SensorModel model) {
  if (model.activeChannelIndex == model.channelSeries.indexChannelsAverage) {
    return 'all enabled channels';
  }
  return 'channel A${model.activeChannelIndex + 1}';
}

class SensorPlots extends StatelessWidget {
  final double rawChartsTotalHeight;
  final double computedChartsTotalHeight;
  final double averagedChartsTotalHeight;
  const SensorPlots(
      {super.key,
      required this.rawChartsTotalHeight,
      required this.computedChartsTotalHeight,
      required this.averagedChartsTotalHeight});

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<SensorModel>(builder: (context, child, model) {
      List<int> channelIndexes = [];
      double plotHeight = rawChartsTotalHeight / model.channelsRecording.length;
      for (var i = 0; i < model.channelsRecording.length; i++) {
        channelIndexes.add(i);
      }
      return Column(children: [
        Row(children: [
          Text('Raw data (freq:${SensorModel.sensorSamplingResolution}Hz)')
        ]),
        Wrap(
            children: channelIndexes
                .map((channelIndex) => PlotTimeSeries(
                      height: plotHeight,
                      data: model.channelSeries.rawMatrix,
                      timeAccessor: (datum) =>
                          DateTime.fromMillisecondsSinceEpoch(
                              model.channelSeries.getTime(datum)),
                      valueAccessor: (datum) =>
                          datum.length > channelIndex ? datum[channelIndex] : 0,
                    ))
                .toList()),

        // Filtered data
        Row(children: [Text('Band-pass filtered (${getChannelName(model)})')]),
        model.isBandPassControlsEnabled
            ? Row(children: [
                Text("CenterFreq=${model.channelSeries.bpCenterFreq}"),
                IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: model.decrementBandPassCenterFreq),
                IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: model.incrementBandPassCenterFreq),
                const Spacer(),
              ])
            : const Wrap(),
        model.isBandPassControlsEnabled
            ? Row(children: [
                Text("WidthFreq=${model.channelSeries.bpWidthFreq}"),
                IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: model.decrementBandPassWidthFreq),
                IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: model.incrementBandPassWidthFreq),
                const Spacer(),
              ])
            : const Wrap(),
        model.isBandPassControlsEnabled
            ? Row(children: [
                Text("Order=${model.channelSeries.bpOrder}"),
                IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: model.decrementBandPassOrder),
                IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: model.incrementBandPassOrder),
                const Spacer(),
              ])
            : const Wrap(),
        PlotTimeSeries(
            height: computedChartsTotalHeight,
            data: model.channelSeries.filteredRectifiedMatrix,
            timeAccessor: (datum) => DateTime.fromMillisecondsSinceEpoch(
                model.channelSeries.getTime(datum)),
            valueAccessor: (datum) => datum[model.activeChannelIndex]),

        // Envelope
        Row(children: [Text('Moving average (${getChannelName(model)})')]),
        model.isMovingAverageControlsEnabled
            ? WindowStepControlsWidget(model: model)
            : const Wrap(),
        PlotTimeSeries(
            height: computedChartsTotalHeight,
            // BUG: when receiving sensor data on Android, first item seem to have time delta of zero
            //      so an horizontal line is displayed across the plot. Need to find why.
            //      Workaround: remove the item at index 0
            data: model.channelSeries.averagedMatrix.length > 2
                ? model.channelSeries.averagedMatrix
                    .sublist(1, model.channelSeries.averagedMatrix.length - 1)
                : model.channelSeries.averagedMatrix,
            range: Range(0, 1),
            timeAccessor: (datum) => DateTime.fromMillisecondsSinceEpoch(
                model.channelSeries.getTime(datum[model.noDerivativeIndex])),
            valueAccessor: (datum) =>
                datum[model.noDerivativeIndex][model.activeChannelIndex]),

        ...(model.getIsEnabledDerivatives()
            ? [
                Row(children: [
                  Text('First derivative (${getChannelName(model)})')
                ]),
                PlotTimeSeries(
                    height: computedChartsTotalHeight,
                    data: model.channelSeries.averagedMatrix,
                    range: Range(-kSensorDerivativesPlotRangeMax,
                        kSensorDerivativesPlotRangeMax),
                    timeAccessor: (datum) =>
                        DateTime.fromMillisecondsSinceEpoch(model.channelSeries
                            .getTime(datum[model.firstDerivativeIndex])),
                    valueAccessor: (datum) => datum[model.firstDerivativeIndex]
                        [model.activeChannelIndex]),
                Row(children: [
                  Text('Second derivative (${getChannelName(model)})')
                ]),
                PlotTimeSeries(
                    height: computedChartsTotalHeight,
                    data: model.channelSeries.averagedMatrix,
                    range: Range(-kSensorDerivativesPlotRangeMax,
                        kSensorDerivativesPlotRangeMax),
                    timeAccessor: (datum) =>
                        DateTime.fromMillisecondsSinceEpoch(model.channelSeries
                            .getTime(datum[model.secondDerivativeIndex])),
                    valueAccessor: (datum) => datum[model.secondDerivativeIndex]
                        [model.activeChannelIndex]),
                Row(children: [
                  Text('Third derivative (${getChannelName(model)})')
                ]),
                PlotTimeSeries(
                    height: computedChartsTotalHeight,
                    data: model.channelSeries.averagedMatrix,
                    range: Range(-kSensorDerivativesPlotRangeMax,
                        kSensorDerivativesPlotRangeMax),
                    timeAccessor: (datum) =>
                        DateTime.fromMillisecondsSinceEpoch(model.channelSeries
                            .getTime(datum[model.thirdDerivativeIndex])),
                    valueAccessor: (datum) => datum[model.thirdDerivativeIndex]
                        [model.activeChannelIndex]),
              ]
            : []),

        ...(model.getIsEnabledSpectrum()
            ? [
                // Spectrum
                const Row(children: [Text('Spectrum raw (1s)')]),
                SizedBox(
                  height: computedChartsTotalHeight,
                  child: model.channelSeries.rawSpectrums.length > 1
                      ? Chart<List<double>>(
                          data: model.channelSeries.rawSpectrums.toList(),
                          variables: {
                            'freq': Variable(
                                accessor: (datum) =>
                                    datum[model.channelSeries.indexTime]),
                            'value': Variable(
                                accessor: (datum) =>
                                    datum[model.activeChannelIndex] / 1000),
                          },
                          marks: [IntervalMark()],
                          axes: [
                            Defaults.horizontalAxis,
                            Defaults.verticalAxis,
                          ],
                        )
                      : null,
                ),
                const Row(children: [Text('Spectrum filtered (1s)')]),
                SizedBox(
                  height: computedChartsTotalHeight,
                  child: model.channelSeries.filteredSpectrums.length > 1
                      ? Chart<List<double>>(
                          data: model.channelSeries.filteredSpectrums.toList(),
                          variables: {
                            'freq': Variable(
                                accessor: (datum) =>
                                    datum[model.channelSeries.indexTime]),
                            'value': Variable(
                                accessor: (datum) =>
                                    datum[model.activeChannelIndex] / 1000),
                          },
                          marks: [IntervalMark()],
                          axes: [
                            Defaults.horizontalAxis,
                            Defaults.verticalAxis,
                          ],
                        )
                      : null,
                ),
              ]
            : [])
      ]);
    });
  }
}
