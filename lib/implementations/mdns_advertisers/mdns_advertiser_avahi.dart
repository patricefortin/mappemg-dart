import 'dart:io';

import '../../configuration.dart';
import '../../constants.dart';
import '../../interfaces/i_advertiser.dart';
import '../../models/core_model.dart';

class MdnsAdvertiserAvahi implements IAdvertiser {
  MdnsAdvertiserAvahi({required this.coreModel});
  CoreModel coreModel;

  Process? process;

  @override
  Future<void> init() async {
    await startAdvertising(coreModel.uuid);
  }

  @override
  Future<void> startAdvertising(String uuid) async {
    getLogger().i(
        'Start advertising using "avahi-publish --service" for uuid: $uuid, type: $kMdnsNodeType, port: $kCommandChannelOscListenInPort');

    // stop old advertisers
    Process.runSync('./scripts/run-kill-avahi-zombies.sh', []);

    process = await Process.start('avahi-publish',
        ['--service', uuid, kMdnsNodeType, '$kCommandChannelOscListenInPort']);
  }

  @override
  Future<void> stopAdvertising() async {
    stop();
  }

  void stop() {
    getLogger().i('Stopping avahi process');
    process?.kill();
  }
}
