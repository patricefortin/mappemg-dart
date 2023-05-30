import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../constants.dart';
import '../../models/sensor_model.dart';
import '../sensor/sensor_controls.dart';
import '../sensor/sensor_plots.dart';

class SensorScreen extends StatelessWidget {
  const SensorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kSensorEnabled) {
      return const Center(child: Text('Sensor is disabled'));
    }

    const double rawChartsTotalHeight = 100;
    const double computedChartsTotalHeight = 100;
    const double averagedChartsTotalHeight = 100;

    return ListView(
      children: <Widget>[
        ScopedModelDescendant<SensorModel>(
            builder: (context, child, model) =>
                Text('Status: ${model.status}')),
        const SensorControls(),
        const SensorPlots(
            rawChartsTotalHeight: rawChartsTotalHeight,
            computedChartsTotalHeight: computedChartsTotalHeight,
            averagedChartsTotalHeight: averagedChartsTotalHeight)
      ],
    );
  }
}
