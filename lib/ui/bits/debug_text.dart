import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../models/core_model.dart';

class DebugText extends StatelessWidget {
  const DebugText({super.key});

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<CoreModel>(
        builder: (context, child, model) => Text(model.message,
            style: Theme.of(context).textTheme.headlineLarge));
  }
}
