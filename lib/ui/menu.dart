import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../constants.dart';
import '../models/core_model.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            padding: EdgeInsets.zero,
            child: Column(children: [
              Row(children: [
                const Spacer(),
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context))
              ]),
              const Column(children: [
                Text(kAppName),
                Text('(v=$kVersion)'),
              ]),
            ]),
          ),
          ListTile(
            leading: const Icon(Icons.monitor_heart),
            title: const Text(kScreenIndexSensorLabel),
            onTap: () {
              ScopedModel.of<CoreModel>(context).selectScreenSensor();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.vibration),
            title: const Text(kScreenIndexVibrationLabel),
            onTap: () {
              ScopedModel.of<CoreModel>(context).selectScreenVibrate();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.broadcast_on_home),
            title: const Text(kScreenIndexMdnsMeshLabel),
            onTap: () {
              ScopedModel.of<CoreModel>(context).selectScreenMdnsMesh();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.show_chart),
            title: const Text(kScreenIndexMappingLabel),
            onTap: () {
              ScopedModel.of<CoreModel>(context).selectScreenMapping();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text(kScreenIndexSettingsLabel),
            onTap: () {
              ScopedModel.of<CoreModel>(context).selectScreenSettings();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text(kScreenIndexAppInfoLabel),
            onTap: () {
              ScopedModel.of<CoreModel>(context).selectScreenAppInfo();
              Navigator.pop(context);
            },
          ),
          // Ensure we have a black line at the end of menu
          Container(
            color: Colors.black,
            width: double.infinity,
            height: 0.1,
          ),
        ],
      ),
    );
  }
}
