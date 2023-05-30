import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../implementations/actuators/amplitude_actuator_vibrator.dart';
import '../../models/core_model.dart';
import '../../types/common.dart';
import '../bits/plot_time_series.dart';
import '../bits/window_step_controls.dart';

class VibrationScreen extends StatelessWidget {
  const VibrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const double plotHeight = 200;
    return Column(children: [
      ScopedModelDescendant<AmplitudeActuatorVibrator>(
        builder: (context, child, model) =>
            WindowStepControlsWidget(model: model),
      ),
      SizedBox(
          height: 300,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Center(child: Text('Vibration time series')),
                Expanded(
                    child: ScopedModelDescendant<CoreModel>(
                        builder: (context, child, model) => PlotTimeSeries(
                              height: plotHeight,
                              data: model.vibrationTimeSeries.timeSeriesItems,
                              timeAccessor: (datum) => datum.time,
                              valueAccessor: (datum) => datum.value,
                              range: Range(0, 1),
                            ))),
              ])),
    ]);
  }
}
