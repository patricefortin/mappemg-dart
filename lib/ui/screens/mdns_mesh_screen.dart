import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../interfaces/i_broadcaster.dart';
import '../../models/core_model.dart';

class MdnsMeshScreenBody extends StatelessWidget {
  final IBroadcaster broadcaster;
  const MdnsMeshScreenBody({super.key, required this.broadcaster});

  @override
  Widget build(BuildContext context) {
    double padding = 10;
    double actionButtonHeight = 35;
    double screenHeight = MediaQuery.of(context).size.height;
    double totalHeight = screenHeight - 100;
    return SizedBox(
        height: totalHeight,
        child: SingleChildScrollView(
            child: ScopedModelDescendant<CoreModel>(
          builder: (context, child, model) => Column(
            children: [
              SizedBox(
                  height: actionButtonHeight,
                  child: Row(
                    children: [
                      Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                broadcaster.sendTestToAllNodes();
                              },
                              child: const Text("Test all"))),
                      Expanded(
                          child: ElevatedButton(
                        onPressed: () {
                          broadcaster.sendResetToAllNodes();
                        },
                        child: const Text("Reset all"),
                      )),
                    ],
                  )),
              Table(
                  border: TableBorder.all(),
                  columnWidths: const <int, TableColumnWidth>{
                    // 0: IntrinsicColumnWidth(),
                    1: FlexColumnWidth(),
                    2: IntrinsicColumnWidth(),
                  },
                  children: [
                    TableRow(children: [
                      TableCell(
                          child: Container(
                              padding: EdgeInsets.all(padding),
                              child: const Text('Node'))),
                      TableCell(
                          child: Container(
                              padding: EdgeInsets.all(padding),
                              child: const Text('Address'))),
                      TableCell(
                          child: Container(
                              padding: EdgeInsets.all(padding),
                              child: const Text('Actions'))),
                    ]),
                    ...model.meshNodes
                        .map((client) => TableRow(children: [
                              TableCell(
                                  child: Container(
                                      padding: EdgeInsets.all(padding),
                                      child: Column(children: [
                                        Text(client.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        Text(client.uuid),
                                      ]))),
                              TableCell(
                                  child: Container(
                                      padding: EdgeInsets.all(padding),
                                      child: Text(
                                          '${client.address.address}:${client.port.toString()}${client.isSelf ? ' (self)' : ''}'))),
                              TableCell(
                                  child: Container(
                                      padding: EdgeInsets.zero,
                                      child: Column(children: [
                                        SizedBox(
                                            height: actionButtonHeight,
                                            child: TextButton(
                                                onPressed: () {
                                                  broadcaster.sendTestToNode(
                                                      client.uuid);
                                                },
                                                child: const Text('Test'))),
                                        SizedBox(
                                            height: actionButtonHeight,
                                            child: TextButton(
                                                onPressed: () {
                                                  broadcaster.sendResetToNode(
                                                      client.uuid);
                                                },
                                                child: const Text('Reset'))),
                                        SizedBox(
                                            height: actionButtonHeight,
                                            child: TextButton(
                                                onPressed: () {
                                                  broadcaster
                                                      .removeNode(client.uuid);
                                                },
                                                child: const Text('Remove'))),
                                      ]))),
                            ]))
                        .toList(),
                  ])
            ],
          ),
        )));
  }
}
