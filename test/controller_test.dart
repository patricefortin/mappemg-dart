import 'package:flutter_test/flutter_test.dart';
import 'package:mappemg/core_controller.dart';

import 'test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Controller -', () {
    test('init', () async {
      CoreController controller = await getTestController(null);
    });
  });

  group('Controller Management -', () {
    test('sync', () async {
      CoreController controller = await getTestController(null);
      expect(controller.lastManagerOutSync, null);
      controller.handleManagerOutSyncCommand('1.1.1.1', true);
      expect(controller.lastManagerOutSync, isNot(null));
    });
  });
}
