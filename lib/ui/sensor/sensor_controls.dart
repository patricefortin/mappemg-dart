import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../models/sensor_model.dart';

// Set the address in initPlatformState

class SensorControls extends StatelessWidget {
  const SensorControls({super.key});

  @override
  Widget build(BuildContext context) {
    double buttonHeight = 35;

    TextEditingController addressTextController = TextEditingController(
        text: ScopedModel.of<SensorModel>(context).address);

    // In order to display the saved address on load, we need to listen to changes on sensorModel.address
    // because the key-value is loaded async and instanciation of this SensorControls widget happen before
    ScopedModel.of<SensorModel>(context).addListener(() {
      try {
        addressTextController.text = ScopedModel.of<SensorModel>(context).address;
      } catch (e) {
        // ignore
      }
    });

    return ScopedModelDescendant<SensorModel>(
        builder: (context, child, model) => Column(
              children: <Widget>[
                TextField(
                  decoration: const InputDecoration(hintText: "MAC"),
                  textAlign: TextAlign.center,
                  controller: addressTextController,
                ),
                SizedBox(
                    height: buttonHeight,
                    child: Row(
                      children: [
                        Expanded(
                            child: ElevatedButton(
                                onPressed: () => model.initPlatformState(
                                    addressTextController.text),
                                child: const Text("Init"))),
                        Expanded(
                            child: ElevatedButton(
                          onPressed:
                              model.canConnect ? model.actionConnect : null,
                          child: const Text("Connect"),
                        )),
                        Expanded(
                            child: ElevatedButton(
                                onPressed: model.canDisconnect
                                    ? model.actionDisconnect
                                    : null,
                                child: const Text("Disconnect")))
                      ],
                    )),
                SizedBox(
                    height: buttonHeight,
                    child: Row(
                      children: [
                        Expanded(
                            child: ElevatedButton(
                                onPressed:
                                    model.canStart ? model.actionStart : null,
                                child: const Text("Start"))),
                        Expanded(
                            child: ElevatedButton(
                                onPressed:
                                    model.canStop ? model.actionStop : null,
                                child: const Text("Stop"))),
                        Expanded(
                            child: ElevatedButton(
                                onPressed: model.canSaveMVC
                                    ? model.actionSaveMVC
                                    : null,
                                child: const Text("Save MVC")))
                      ],
                    )),
                Row(
                  children: [
                    const Text('Enable chan. '),
                    ...model.availableChannels
                        .map((channel) => [
                              Container(
                                  padding: const EdgeInsets.all(0.0),
                                  width: 30.0,
                                  child: Checkbox(
                                      value:
                                          model.isAnalogChannelEnabled(channel),
                                      onChanged: (_) => model
                                          .toggleAnalogChannelEnabled(channel)))
                            ])
                        .expand((element) => element)
                        .toList(),
                  ],
                ),
                Row(children: [
                  const Text('Select chan.  '),
                  ...model.availableChannels
                      .map((channel) => [
                            Container(
                                padding: const EdgeInsets.all(0.0),
                                width: 30.0,
                                child: Radio<int>(
                                    value: channel,
                                    groupValue: (model.activeChannelIndex),
                                    onChanged:
                                        model.isAnalogChannelRecording(channel)
                                            ? model.setActiveChannelIndex
                                            : null)),
                          ])
                      .expand((element) => element)
                      .toList(),
                  const Text('Avg'),
                  Container(
                      padding: const EdgeInsets.all(0.0),
                      width: 30.0,
                      child: Radio<int>(
                          value: model.channelsAverageIndex,
                          groupValue: (model.activeChannelIndex),
                          onChanged: model.setActiveChannelIndex)),
                ])
              ],
            ));
  }
}
