import 'package:flutter_test/flutter_test.dart';
import 'package:mappemg/core_controller.dart';
import 'package:mappemg/implementations/mdns_advertisers/mdns_advertiser_dummy.dart';

import 'test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Advertiser (mDNS) -', () {
    test('advertise about this node on init', () async {
      CoreController controller = await getTestController(null);
      expect((controller.mdnsAdvertiser as MdnsAdvertiserDummy).advertisingUUID,
          controller.coreModel.uuid);
    });
  });
}
