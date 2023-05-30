import 'package:flutter_test/flutter_test.dart';
import 'package:mappemg/core_controller.dart';
import 'package:mappemg/implementations/commands/command_channel_osc.dart';
import 'package:mappemg/interfaces/i_manager_out_actuator.dart';
import 'package:mappemg/osc/osc_message_generator.dart';

import 'test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('OSC CommandChannel -', () {
    test('haptics channel', () async {
      double amplitude = 20;
      CommandChannelOsc commandChannel = getTestOscCommandChannel();
      CoreController controller = await getTestController(commandChannel);

      commandChannel.messageReceived(createOscMessageHaptics(amplitude));

      expect(controller.actuatorState.vibrationIntensity, greaterThan(0));
    });

    test('color channel', () async {
      String colorCode = 'ffffff';
      CommandChannelOsc commandChannel = getTestOscCommandChannel();
      CoreController controller = await getTestController(commandChannel);

      commandChannel.messageReceived(createOscMessageColor(colorCode));

      expect(controller.actuatorState.color.toString(), colorCode);
    });

    test('brightness channel', () async {
      double value = 1;
      CommandChannelOsc commandChannel = getTestOscCommandChannel();
      CoreController controller = await getTestController(commandChannel);

      commandChannel.messageReceived(createOscMessageBrightness(value));

      expect(controller.actuatorState.brightness, greaterThan(0));
    });

    test('management ping pong', () async {
      CommandChannelOsc commandChannel = getTestOscCommandChannel();
      CoreController controller = await getTestController(commandChannel);
      int messageId = 9999;
      commandChannel.messageReceived(createOscMessageManagerInPing(messageId));

      ManagerOutPong? lastPong = controller.lastManagerOutPong;
      expect(lastPong?.id, messageId);
    });

    test('management sync', () async {
      CommandChannelOsc commandChannel = getTestOscCommandChannel();
      CoreController controller = await getTestController(commandChannel);
      String fakeIP = '1.1.1.1';
      commandChannel.messageReceived(createOscMessageManagerInSync(fakeIP));

      ManagerOutSync? lastSync = controller.lastManagerOutSync;
      expect(lastSync, isNot(null));
    });
  });
}
