import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../configuration.dart';
import '../../constants.dart';
import '../../models/core_model.dart';
import '../../models/sensor_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double totalHeight = screenHeight - 100;

    return ScopedModelDescendant<CoreModel>(
        builder: (context, child, model) => ScopedModelDescendant<SensorModel>(
            builder: (sensorContext, sensorChild, sensorModel) => SizedBox(
                  height: totalHeight,
                  child: SettingsList(
                    sections: [
                      SettingsSection(
                        title: const Text('Physical vibration'),
                        tiles: [
                          SettingsTile.switchTile(
                            title: const Text('Enable physical vibration'),
                            initialValue:
                                model.inOutMap.physicalVibrationEnabled,
                            onToggle: (bool value) {
                              model.inOutMap.physicalVibrationEnabled = value;
                            },
                          ),
                        ],
                      ),
                      SettingsSection(
                        title: const Text('Actuator mappings'),
                        tiles: [
                          SettingsTile.switchTile(
                            title: const Row(children: [
                              Text('Sensors'),
                              Icon(Icons.forward),
                              Text('Brightness')
                            ]),
                            initialValue:
                                model.inOutMap.sensorToBrightnessEnabled,
                            onToggle: (bool value) {
                              model.inOutMap.sensorToBrightnessEnabled = value;
                            },
                          ),
                          SettingsTile.switchTile(
                            title: const Row(children: [
                              Text('Sensors'),
                              Icon(Icons.forward),
                              Text('Vibration')
                            ]),
                            initialValue:
                                model.inOutMap.sensorToVibrationEnabled,
                            onToggle: (bool value) {
                              model.inOutMap.sensorToVibrationEnabled = value;
                            },
                          ),
                          SettingsTile.switchTile(
                            title: const Row(children: [
                              Text('Sensors'),
                              Icon(Icons.forward),
                              Text('OSC')
                            ]),
                            description: const Text(
                                'Broadcast signal as OSC messages to devices found through mDNS discovery'),
                            initialValue:
                                model.inOutMap.sensorToOscBroadcastEnabled,
                            onToggle: (bool value) {
                              model.inOutMap.sensorToOscBroadcastEnabled =
                                  value;
                            },
                          ),
                          SettingsTile.switchTile(
                            title: const Row(children: [
                              Text('OSC'),
                              Icon(Icons.forward),
                              Text('Brightness')
                            ]),
                            initialValue: model.inOutMap.oscToBrightnessEnabled,
                            onToggle: (bool value) {
                              model.inOutMap.oscToBrightnessEnabled = value;
                            },
                          ),
                          SettingsTile.switchTile(
                            title: const Row(children: [
                              Text('OSC'),
                              Icon(Icons.forward),
                              Text('Vibration')
                            ]),
                            initialValue: model.inOutMap.oscToVibrationEnabled,
                            onToggle: (bool value) {
                              model.inOutMap.oscToVibrationEnabled = value;
                            },
                          ),
                          SettingsTile.switchTile(
                            title: const Row(children: [
                              Text('OSC'),
                              Icon(Icons.forward),
                              Text('Sync/Ping')
                            ]),
                            description: const Text(
                                'Respond to manager sync/ping messages'),
                            initialValue: model.inOutMap.oscToManagerInEnabled,
                            onToggle: (bool value) {
                              model.inOutMap.oscToManagerInEnabled = value;
                            },
                          ),
                        ],
                      ),
                      SettingsSection(
                        title: const Text('Sensors'),
                        tiles: [
                          SettingsTile.switchTile(
                            title: const Row(children: [
                              Text('Enable spectrum'),
                            ]),
                            initialValue: sensorModel.getIsEnabledSpectrum(),
                            onToggle: (bool value) =>
                                sensorModel.setIsEnabledSpectrum(value),
                          ),
                          SettingsTile.switchTile(
                            title: const Row(children: [
                              Text('Enable derivatives'),
                            ]),
                            initialValue: sensorModel.getIsEnabledDerivatives(),
                            onToggle: (bool value) =>
                                sensorModel.setIsEnabledDerivatives(value),
                          ),
                          SettingsTile.switchTile(
                            title: const Row(children: [
                              Text('Enable low-pass filter'),
                            ]),
                            description: const Text(
                                'Enable an extra low-pass filter on calculated moving average'),
                            initialValue:
                                sensorModel.getIsEnabledLowPassAveraged(),
                            onToggle: (bool value) =>
                                sensorModel.setIsEnabledLowPassAveraged(value),
                          ),
                          SettingsTile.switchTile(
                            title: const Row(children: [
                              Text('Show band-pass controls'),
                            ]),
                            initialValue:
                                sensorModel.getIsEnabledBandPassControls(),
                            onToggle: (bool value) =>
                                sensorModel.setIsEnabledBandPassControls(value),
                          ),
                          SettingsTile.switchTile(
                            title: const Row(children: [
                              Text('Show moving avg controls'),
                            ]),
                            initialValue:
                                sensorModel.getIsEnabledMovingAverageControls(),
                            onToggle: (bool value) => sensorModel
                                .setIsEnabledMovingAverageControls(value),
                          ),
                        ],
                      ),
                      SettingsSection(
                        title: const Text('mDNS Mesh'),
                        tiles: [
                          SettingsTile.switchTile(
                            title: const Row(children: [
                              Text('Broadcaster Mode'),
                            ]),
                            initialValue: kMdnsMeshEnabled,
                            description: const Text(
                                'In Broadcaster Mode, we send OSC data to other happtiks node'),
                            onToggle: (bool value) {
                              getLogger().w('Not implemented yet');
                            },
                            // Handling of live change of this value is not yet implemented
                            enabled: false,
                          ),
                          SettingsTile.switchTile(
                            title: const Row(children: [
                              Text('Node Mode'),
                            ]),
                            initialValue: kMdnsNodeEnabled,
                            description: const Text(
                                'In Node Mode, we receive OSC data from a broadcaster (or manager)'),
                            onToggle: (bool value) {
                              getLogger().w('Not implemented yet');
                            },
                            // Handling of live change of this value is not yet implemented
                            enabled: false,
                          ),
                        ],
                      ),
                      SettingsSection(
                        title: const Text('Other'),
                        tiles: [
                          SettingsTile.switchTile(
                            title: const Row(children: [
                              Text('Full mode'),
                            ]),
                            initialValue: kDefaultFullModeEnabled,
                            onToggle: (bool value) {
                              getLogger().w('Not implemented yet');
                            },
                            // Handling of live change of this value is not yet implemented
                            enabled: false,
                          ),
                        ],
                      )
                    ],
                  ),
                )));
  }
}
