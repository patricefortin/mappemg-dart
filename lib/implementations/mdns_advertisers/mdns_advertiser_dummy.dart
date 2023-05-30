import '../../interfaces/i_advertiser.dart';
import '../../models/core_model.dart';

class MdnsAdvertiserDummy implements IAdvertiser {
  MdnsAdvertiserDummy({required this.coreModel});
  CoreModel coreModel;
  String? advertisingUUID;

  @override
  Future<void> init() async {
    await startAdvertising(coreModel.uuid);
  }

  @override
  Future<void> startAdvertising(String uuid) async {
    advertisingUUID = uuid;
  }

  @override
  Future<void> stopAdvertising() async {
    advertisingUUID = null;
  }
}
