import 'dart:io';

import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'configuration.dart';
import 'constants.dart';
import 'core_controller.dart';
import 'implementations/actuators/amplitude_actuator_osc_broadcaster.dart';
import 'implementations/actuators/amplitude_actuator_vibrator.dart';
import 'implementations/actuators/manager_out_actuator_osc.dart';
import 'implementations/mdns_advertisers/mdns_advertiser_avahi.dart';
import 'implementations/mdns_advertisers/mdns_advertiser_bonsoir.dart';
import 'implementations/commands/command_channel_osc.dart';
import 'implementations/commands/command_channel_reverse_tcp.dart';
import 'implementations/debug/debug_channel_stream_out_udp.dart';
import 'implementations/sensors/sensor_bitalino_bluetooth_model.dart';
import 'implementations/sensors/sensor_replay_file_model.dart';
import 'interfaces/i_amplitude_actuator.dart';
import 'interfaces/i_display_actuator.dart';
import 'models/sensor_model.dart';
import 'models/core_model.dart';
import 'models/display_actuator_model.dart';
import 'mapping/color_mapper.dart';

import 'ui/menu.dart';
import 'ui/screens/mappings_screen.dart';
import 'ui/screens/sensor_screen.dart';
import 'ui/screens/app_info_screen.dart';
import 'ui/screens/mdns_mesh_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/screens/vibration_screen.dart';

CoreModel coreModel = CoreModel();

DisplayActuatorModel displayActuatorModel = DisplayActuatorModel();
// The DisplayActuator can dim the color instead of using the actual brightness of the phone
IAmplitudeActuator brightnessActuator = displayActuatorModel;

// For sending vibration to other clients
AmplitudeActuatorOscBroadcaster oscBroadcastActuator =
    AmplitudeActuatorOscBroadcaster(coreModel: coreModel);

AmplitudeActuatorVibrator vibrationActuator =
    AmplitudeActuatorVibrator(coreModel: coreModel);

SensorModel sensorModel = (Platform.isAndroid || Platform.isIOS)
    ? SensorBitalinoBluetoothModel()
    : SensorReplayFileModel();

makeApp() => const HapptiksApp();

void main() {
  runApp(makeApp());
}

class HapptiksApp extends StatelessWidget {
  const HapptiksApp({super.key});

  // This widget is the root of the application
  @override
  Widget build(BuildContext context) {
    return ScopedModel<CoreModel>(
        model: coreModel,
        child: ScopedModel<SensorModel>(
            model: sensorModel,
            child: ScopedModel<AmplitudeActuatorVibrator>(
                model: vibrationActuator,
                child: ScopedModel<DisplayActuatorModel>(
                    model: displayActuatorModel,
                    child: MaterialApp(
                        // title: 'Happtiks Demo',
                        home: const HapptiksStatefulWidget(),
                        theme: ThemeData(
                          colorScheme:
                              ColorScheme.fromSeed(seedColor: Colors.blue),
                          useMaterial3: true,
                        ))))));
  }
}

class HapptiksStatefulWidget extends StatefulWidget {
  const HapptiksStatefulWidget({super.key});

  @override
  State<HapptiksStatefulWidget> createState() => HapptiksState();
}

class HapptiksState extends State<HapptiksStatefulWidget>
    with SingleTickerProviderStateMixin
    implements IDisplayActuator {
  late CoreController controller = CoreController(
    coreModel: coreModel,
    sensorModel: sensorModel,
    brightnessActuator: brightnessActuator,
    displayActuator: this,
    hapticActuator: vibrationActuator,
    managerOutActuator: ManagerOutActuatorOsc(),
    mdnsAdvertiser: kMdnsNodeEnabled
        ? ((Platform.isAndroid || Platform.isIOS)
            ? MdnsAdvertiserBonsoir(coreModel: coreModel)
            : MdnsAdvertiserAvahi(coreModel: coreModel))
        : null,
    oscBroadcastActuator: oscBroadcastActuator,
    streamOut:
        kDebugChannelStreamOutUdpEnabled ? DebugChannelStreamOutUDP() : null,
    commandChannels: {
      CommandChannelOsc(coreModel: coreModel),
      ...(kCommandChannelReverseTcpEnabled ? [CommandChannelReverseTcp()] : []),
    },
  );

  bool _localStateFullMode = coreModel.isFullMode;
  Color _localColor = displayActuatorModel.color;

  HapptiksState() {
    // We need to change a local state for FullMode to control the AppBar
    coreModel.addListener(() {
      bool isFullMode = ScopedModel.of<CoreModel>(context).isFullMode;
      if (_localStateFullMode != isFullMode) {
        setState(() {
          _localStateFullMode = isFullMode;
        });
      }

      Color color = ScopedModel.of<DisplayActuatorModel>(context).color;
      if (_localColor != color) {
        setState(() {
          _localColor = color;
        });
      }
    });

    vibrationActuator.createTicker = createTicker;

    ProcessSignal.sigint.watch().listen((signal) {
      dispose();
      // TODO check if we should wait 2 seconds before exit
      exit(0);
    });
    ProcessSignal.sigterm.watch().listen((signal) {
      dispose();
      exit(0);
    });

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // When running in test, we do not "init()" the controller, to avoid doing network operations
    if (shouldInitController()) {
      controller.init();
    }

    // Set the real brightness of the device if available, so our colors appears all the same on every node
    () async {
      try {
        await ScreenBrightness().setScreenBrightness(1);
      } catch (e) {
        // not an issue, maybe we are on a desktop
        getLogger().i('Cannot control brightness on this device: $e');
      }
    }();
  }

  @override
  void initState() {
    super.initState();
    getLogger().d('Running initState');
  }

  @override
  void dispose() {
    // This does not seem to be called when app is killed
    controller.dispose();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey(); // Create a key

  @override
  Widget build(BuildContext context) {
    // Retrieve IP address
    if (shouldListNetworkInterfaces()) {
      NetworkInterface.list().then((interfaces) {
        ScopedModel.of<CoreModel>(context).networkAddress = interfaces
            .map((interface) =>
                interface.addresses.map((address) => address.address).join(','))
            .join('; ');
      });
    }

    // Init "toast" display (rounded notification in the middle of the screen)
    final fToast = FToast().init(context);
    void uiNotify(dynamic msg) {
      if (Platform.isAndroid || Platform.isIOS) {
        Fluttertoast.showToast(
          msg: msg,
          gravity: ToastGravity.CENTER,
        );
      } else {
        // remove last display if any
        fToast.removeCustomToast();
        fToast.showToast(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              color: Colors.lightBlue,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 12.0),
                Text(msg),
              ],
            ),
          ),
          gravity: ToastGravity.CENTER,
        );
      }
    }

    // Register a way to display UI notifications
    coreModel.uiNotify = uiNotify;
    sensorModel.uiNotify = uiNotify;

    // Assemble the screens in an list
    List<Widget> screenBodies = [
      const SensorScreen(),
      const VibrationScreen(),
      MdnsMeshScreenBody(broadcaster: oscBroadcastActuator),
      const MappingsScreen(),
      AppInfoScreen(controller: controller),
      const SettingsScreen(),
    ];

    double screenHeight = MediaQuery.of(context).size.height;
    double totalHeight = screenHeight - 110;

    return Scaffold(
      key: _scaffoldKey,
      appBar: _localStateFullMode
          ? AppBar(
              title: ScopedModelDescendant<CoreModel>(
                  builder: (context, child, model) => Text(model.title)))
          : null,
      drawer: const AppDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Debug data display
          ScopedModelDescendant<CoreModel>(
              builder: (context, child, model) => model.isFullMode
                  ? SizedBox(
                      height: totalHeight,
                      child: screenBodies[
                          model.currentScreenIndex % screenBodies.length])
                  : const Wrap()),

          // Fullscreen background color display
          Expanded(
              child: InkWell(
                  onTap: _localStateFullMode
                      ? null
                      : ScopedModel.of<CoreModel>(context).toggleFullMode,
                  child: ColoredBox(
                      // alignment: Alignment.bottomRight,
                      color: _localColor,
                      child: const Column(children: [
                        Spacer(),
                        Row(children: [
                          Spacer(),
                          // IconButton(
                          //   // color: _localStateFullMode ? null : model.color,
                          //   color: null,
                          //   // Debug button
                          //   icon: const Icon(toggleFullModeIcon),
                          //   onPressed: ScopedModel.of<CoreModel>(context)
                          //       .toggleFullMode,
                          // ),
                        ])
                      ]))))
        ],
      ),
    );
  }

  @override
  Future<void> init() async {
    getLogger().i('Loading saved preferences');
    sensorModel.loadPrefsLastAddress();
  }

  //receiving and sending back a custom message
  @override
  void setText(String msg) {
    ScopedModel.of<CoreModel>(context).message = msg;
  }

  @override
  void setColor(AppColor color) {
    displayActuatorModel.color = Color(color.asIntWithAlpha());
    ScopedModel.of<CoreModel>(context).lastAppColorReceived = color;
  }

  @override
  AppColor get lastColor {
    return ScopedModel.of<CoreModel>(context).lastAppColorReceived ??
        AppColor();
  }
}
