import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../core_controller.dart';
import '../../models/sensor_model.dart';
import '../../models/core_model.dart';
import '../bits/debug_text.dart';

class AppInfoScreen extends StatelessWidget {
  final CoreController controller;
  const AppInfoScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ScopedModelDescendant<CoreModel>(
          builder: (context, child, model) => Table(
                  border: TableBorder.all(),
                  columnWidths: const <int, TableColumnWidth>{
                    0: IntrinsicColumnWidth(),
                    1: FlexColumnWidth(),
                  },
                  children: [
                    TableRow(children: [
                      const TableCell(child: Text('uuid: ')),
                      TableCell(child: Text(model.uuid)),
                    ]),
                    TableRow(children: [
                      const TableCell(child: Text('app state: ')),
                      TableCell(
                          child: Text(controller.actuatorState.toString())),
                    ]),
                    TableRow(children: [
                      const TableCell(child: Text('phone address: ')),
                      TableCell(child: Text(model.networkAddress)),
                    ]),
                    TableRow(children: [
                      const TableCell(child: Text('manager address: ')),
                      TableCell(child: Text('${controller.managerOutAddress}')),
                    ]),
                    TableRow(children: [
                      const TableCell(child: Text('sensor status: ')),
                      TableCell(
                          child: ScopedModelDescendant<SensorModel>(
                              builder: (context, child, model) =>
                                  Text(model.status))),
                    ]),
                    TableRow(children: [
                      const TableCell(child: Text('sensor MVC range: ')),
                      TableCell(
                          child: ScopedModelDescendant<SensorModel>(
                        builder: (context, child, model) => Column(
                            children: model.channelSeries.paramsVector
                                .map((params) => Text(
                                    '${params.channelName}: ${params.minValue} - ${params.maxValue}'))
                                .toList()),
                      ))
                    ]),
                  ])),
      const DebugText(),
    ]);
  }
}
