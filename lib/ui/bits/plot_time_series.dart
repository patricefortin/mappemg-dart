import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

import '../../types/common.dart';
import '../../types/time_series.dart';

class PlotTimeSeries<T> extends StatelessWidget {
  final double height;
  final List<T> data;
  final DateTime Function(T) timeAccessor;
  final dynamic Function(T) valueAccessor;
  final Range? range;
  const PlotTimeSeries(
      {super.key,
      required this.height,
      required this.data,
      required this.timeAccessor,
      required this.valueAccessor,
      this.range});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white70, // TODO move color to constants
      height: height,
      child: data.length >= 2
          ? Chart<T>(
              data: data,
              variables: {
                'time': Variable(
                    accessor: timeAccessor,
                    scale: TimeScale(
                        tickCount: 5,
                        formatter: (time) =>
                            TimeSeries.getElapsedSecondsStr(time))),
                'value': Variable(
                    accessor: valueAccessor,
                    scale: LinearScale(
                        min: range?.min, max: range?.max, niceRange: true)),
              },
              marks: [
                LineMark(
                  shape: ShapeEncode(value: BasicLineShape()),
                  selected: {
                    'touchMove': {1}
                  },
                )
              ],
              axes: [
                Defaults.horizontalAxis,
                Defaults.verticalAxis,
              ],
            )
          : const Text('No data'),
    );
  }
}
