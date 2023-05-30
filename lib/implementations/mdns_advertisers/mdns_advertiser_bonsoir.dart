import 'dart:async';

import 'package:bonsoir/bonsoir.dart';

import '../../configuration.dart';
import '../../constants.dart';
import '../../interfaces/i_advertiser.dart';
import '../../models/core_model.dart';

class MdnsAdvertiserBonsoir implements IAdvertiser {
  MdnsAdvertiserBonsoir({required this.coreModel});
  CoreModel coreModel;

  BonsoirService? service;
  BonsoirBroadcast? broadcast;

  @override
  Future<void> init() async {
    BonsoirService service = BonsoirService(
      name: coreModel.uuid,
      type: kMdnsNodeType,
      port: kMdnsNodePort,
    );
    broadcast = BonsoirBroadcast(service: service, printLogs: true);

    await startAdvertising(coreModel.uuid);
  }

  @override
  Future<void> startAdvertising(String uuid) async {
    getLogger().d(
        'BonsoirAdvertiser: Starting Bonsoir broadcast (uuid: $uuid) with this info: ${service.toString()}');
    await broadcast!.ready;
    await broadcast!.start();

    // Timer.periodic(const Duration(seconds: 10), (Timer t) async {
    //   logger.i('BonsoirAdvertiser: Stop and Start again to force advertising');
    //   await broadcast!.stop();
    //   await broadcast!.start();
    // });
  }

  @override
  Future<void> stopAdvertising() async {
    await broadcast!.stop();
  }
}
