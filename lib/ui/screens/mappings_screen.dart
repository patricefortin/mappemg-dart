import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

import '../../constants.dart';
import '../../mapping/in_out_mapper.dart';
import '../../mapping/range_mapper.dart';

class MapPlot extends StatelessWidget {
  final double height;
  final double width;
  final String title;
  ValueRangeMap inputRangeMap = normMap;
  ValueRangeMap outputRangeMap = outputIdentityMap;

  late List<double> xValues;

  MapPlot({
    super.key,
    required this.height,
    required this.width,
    required this.title,
    inputRangeMap,
    outputRangeMap,
  }) {
    if (inputRangeMap != null) {
      this.inputRangeMap = inputRangeMap;
    }
    if (outputRangeMap != null) {
      this.outputRangeMap = outputRangeMap;
    }
    xValues = this.inputRangeMap.getXRangeValues();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(title),
      Container(
          color: Colors.white70, // TODO move color to constants
          height: height,
          width: width,
          child: Chart<double>(
            data: xValues,
            variables: {
              'x': Variable(
                  accessor: (x) => x,
                  scale: LinearScale(ticks: inputRangeMap.getFromTicks())),
              'y': Variable(
                  accessor: (x) =>
                      outputRangeMap.getDouble(inputRangeMap.getDouble(x)),
                  scale: LinearScale(
                      ticks: outputRangeMap.getToTicks(),
                      formatter: (y) => y.toStringAsFixed(2))),
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
          ))
    ]);
  }
}

class MappingsScreen extends StatelessWidget {
  const MappingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const double plotHeight = 120;
    final double rowWidth = MediaQuery.of(context).size.width;

    return ListView(
      children: <Widget>[
        // End to End mappings
        MapPlot(
          height: plotHeight,
          width: rowWidth,
          inputRangeMap: normMap,
          outputRangeMap: sensorToOscVibrationIntensityMap,
          title: 'Sensor EMG -> OSC Vibration intensity (state message)',
        ),
        MapPlot(
          height: plotHeight,
          width: rowWidth,
          inputRangeMap: normMap,
          outputRangeMap: sensorToOscVibrationSharpnessMap,
          title: 'Sensor EMG -> OSC Vibration sharpness (state message)',
        ),
        MapPlot(
          height: plotHeight,
          width: rowWidth,
          inputRangeMap: inputOscManagerStateBrightnessMap,
          outputRangeMap: sensorToOscBrightnessMap,
          title: 'Sensor EMG -> OSC Brightness (state message)',
        ),

        MapPlot(
          height: plotHeight,
          width: rowWidth,
          outputRangeMap: sensorToSelfVibrationMap,
          title: 'Sensor EMG -> Local Vibration (this device)',
        ),

        MapPlot(
          height: plotHeight,
          width: rowWidth,
          outputRangeMap: sensorToSelfBrightnessTransform,
          title: 'Sensor EMG -> Local Brightness (this device)',
        ),

        // Inputs
        MapPlot(
          height: plotHeight,
          width: rowWidth,
          inputRangeMap: commandChannelBrightnessToNormMap,
          title:
              'Input OSC command $kCommandChannelOscAddressBrightness brightness',
        ),
        MapPlot(
          height: plotHeight,
          width: rowWidth,
          inputRangeMap: commandChannelVibrateToNormMap,
          title:
              'Input OSC command $kCommandChannelOscAddressVibrate vibration',
        ),
        MapPlot(
          height: plotHeight,
          width: rowWidth,
          inputRangeMap: inputOscManagerStateBrightnessMap,
          title: 'Input OSC message state brightness',
        ),
        MapPlot(
          height: plotHeight,
          width: rowWidth,
          inputRangeMap: inputOscManagerStateVibrateMap,
          title: 'Input OSC message state vibration',
        ),
        MapPlot(
          height: plotHeight,
          width: rowWidth,
          inputRangeMap: inputOscManagerStateRGBMap,
          title: 'Input OSC message state RGB color components',
        ),

        // Outputs
        MapPlot(
          height: plotHeight,
          width: rowWidth,
          outputRangeMap: outputAmplitudeActuatorVibrationMap,
          title: 'Output device vibration',
        ),

        MapPlot(
          height: plotHeight,
          width: rowWidth,
          outputRangeMap: sensorToOscBrightnessMap,
          title: 'Output OSC message state brightness',
        ),

        // Row(children: [
        //   MapPlot(
        //     height: plotHeight,
        //     width: rowWidth / 2,
        //     title: 'test1',
        //     rangeMap: InputRangeMap(Range(0, 255)),
        //   ),
        //   MapPlot(
        //     height: plotHeight,
        //     width: rowWidth / 2,
        //     title: 'test2',
        //     rangeMap: InputRangeMap(Range(0, 255)),
        //   ),
        // ]),
      ],
    );
  }
}
