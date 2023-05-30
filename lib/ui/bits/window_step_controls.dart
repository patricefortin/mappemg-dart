import 'package:flutter/material.dart';

import '../../interfaces/i_with_window_step.dart';

class WindowStepControlsWidget extends StatelessWidget {
  final IWithWindowStep model;

  const WindowStepControlsWidget({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text("Step=${model.stepSize}"),
      IconButton(
          icon: const Icon(Icons.remove), onPressed: model.decrementStepSize),
      IconButton(
          icon: const Icon(Icons.add), onPressed: model.incrementStepSize),
      Text("| Win=${model.windowSize}"),
      IconButton(
          icon: const Icon(Icons.remove), onPressed: model.decrementWindowSize),
      IconButton(
          icon: const Icon(Icons.add), onPressed: model.incrementWindowSize),
      const Spacer(),
    ]);
  }
}
