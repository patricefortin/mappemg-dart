import 'dart:async';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:osc/osc.dart';
import 'package:multicast_dns/multicast_dns.dart';

import '../../configuration.dart';
import '../../constants.dart';
import '../../interfaces/i_amplitude_actuator.dart';
import '../../interfaces/i_broadcaster.dart';
import '../../mapping/color_mapper.dart';
import '../../mapping/in_out_mapper.dart';
import '../../models/core_model.dart';
import '../../osc/osc_message_generator.dart';
import '../../types/state.dart';
import 'amplitude_actuator_base.dart';

class TargetOscSocket {
  OSCSocket socket;
  bool isSelf;
  TargetOscSocket(this.socket, this.isSelf);
}

class AmplitudeActuatorOscBroadcaster extends AmplitudeActuatorBase
    implements IAmplitudeActuator, IBroadcaster {
  final CoreModel coreModel;

  MDnsClient mdnsClient = MDnsClient();
  final Map<String, TargetOscSocket> broadcastTargets = {};
  Timer? discoverTimer;

  AmplitudeActuatorOscBroadcaster({required this.coreModel});

  late Logger logger = getLogger();

  @override
  Future<void> init() async {
    // Start the client with default options.
    if (kMdnsMeshEnabled) {
      await mdnsClient.start();
      discoverNodes();
    }
  }

  Future<void> sendAmplitudeToNode(OSCSocket socket, double amplitude) async {
    AppColor color = AppColor.fromString(kActuatorColorBase);
    ActuatorState actuatorState = ActuatorState(
        vibrationIntensity:
            sensorToOscVibrationIntensityMap.getDouble(amplitude),
        vibrationSharpness:
            sensorToOscVibrationSharpnessMap.getDouble(amplitude),
        color: color,
        brightness: sensorToOscBrightnessMap.getDouble(amplitude));
    OSCMessage message = createOscMessageManagerApplyState(actuatorState);
    // logger.d('Broadcaster send: $message (amplitude: $amplitude)');
    await socket.send(message);
  }

  @override
  Future<void> actuate(double amplitude) async {
    super.actuate(amplitude);
    // Exclude this instance if necessary, to avoid reading signal and streaming it to ourself at the same time
    await Future.wait(broadcastTargets.values
        .where((target) => kMdnsMeshExcludeSelf ? !target.isSelf : true)
        .map((target) async {
      return sendAmplitudeToNode(target.socket, amplitude);
    }));
  }

  void _handleStreamPTR(PtrResourceRecord ptr) async {
    logger.d('Broadcaster: received a PTR entry: $ptr');

    ResourceRecordQuery srvQuery = ResourceRecordQuery.service(ptr.domainName);
    Stream<SrvResourceRecord> srvStream = mdnsClient.lookup(srvQuery);

    await for (final SrvResourceRecord srv in srvStream) {
      logger.d('Broadcaster: srv ${srv.toString()}');
      // logger.i('Broadcaster: Dart observatory instance found at ' '${srv.target}:${srv.port} for "${srv.name}".');
      ResourceRecordQuery addressQuery =
          ResourceRecordQuery.addressIPv4(srv.target);
      Stream<IPAddressResourceRecord> addressStream =
          mdnsClient.lookup<IPAddressResourceRecord>(addressQuery);

      try {
        await for (final IPAddressResourceRecord ip in addressStream) {
          String name = ip.name;
          InternetAddress address = ip.address;

          // Make sure not to add this instance, to avoid sending OSC packets to ourself
          if (address.address == '127.0.0.1') {
            continue;
          }

          bool isSelf = -1 !=
              coreModel.networkAddress
                  .replaceAll(' ', '')
                  .split(RegExp(',|;')) // Our delimiters
                  .indexWhere((selfAddress) => selfAddress == address.address);

          await addNode(MeshNode(
            uuid: srv.name,
            name: name,
            address: address,
            port: srv.port,
            isSelf: isSelf,
          ));
        }
      } catch (e) {
        logger.w(
            'Broadcaster: Error in broadcaster lookup for address "${srv.target}": $e');
      }
    }
  }

  void _onStreamPTRError(dynamic error) {
    int seconds = kMdnsMeshDiscoverIntervalSeconds;
    logger.e('Broadcaster: Error in PTR Stream: $error');
    logger.i('Broadcaster: Restarting listen in $seconds seconds');
    Timer(Duration(seconds: seconds), () {
      discoverNodes();
    });
  }

  void _onStreamPTRDone() {
    int seconds = kMdnsMeshDiscoverIntervalSeconds;
    logger.i(
        'Broadcaster: Stream PTR is done. Restarting it in $seconds seconds');

    // Create a new mdnsClient to workaround the multicast_dns cache, and launch a new discovery
    Timer(Duration(seconds: seconds), () async {
      mdnsClient.stop();
      mdnsClient = MDnsClient();
      await mdnsClient.start();
      discoverNodes();
    });
  }

  @override
  void discoverNodes() {
    // Need to add .local because of a bug in multicast_dns library, it adds a .tcp after our .udp

    String nodeType = '$kMdnsNodeType.local';
    logger.i('Broadcaster: Checking for mDNS nodes of type $nodeType');

    ResourceRecordQuery ptrQuery = ResourceRecordQuery.serverPointer(nodeType);

    // The ptrStream will send event when a discovery request has been answered
    Stream<PtrResourceRecord> ptrStream = mdnsClient.lookup(ptrQuery);

    ptrStream.listen(_handleStreamPTR,
        onError: _onStreamPTRError,
        onDone: _onStreamPTRDone,
        cancelOnError: true);
  }

  @override
  List<MeshNode> get nodes => coreModel.meshNodes;

  Future<void> addNode(MeshNode node) async {
    if (coreModel.meshNodes
            .indexWhere((element) => element.uuid == node.uuid) ==
        -1) {
      logger.i(
          'Broadcaster: Adding mDNS node "${node.uuid}": ${node.address.address}:${node.port}');

      await Future.wait(coreModel
          .findMeshUuidsForAddressPort(node.address, node.port)
          .map(removeNode));

      coreModel.addMeshNode(node);
      broadcastTargets[node.uuid] = TargetOscSocket(
          OSCSocket(
            destination: node.address,
            destinationPort: node.port,
          ),
          node.isSelf);
    }
  }

  @override
  Future<void> removeNode(String uuid) async {
    coreModel.removeMeshNode(uuid);
    broadcastTargets.removeWhere((key, value) => key == uuid);
  }

  @override
  Future<void> sendTestToNode(String uuid) async {
    OSCSocket? socket = broadcastTargets[uuid]?.socket;
    if (socket == null) {
      logger.w('Broadcaster: No socket found for node with uuid "$uuid"');
      return;
    }
    sendAmplitudeToNode(socket, testValue);
  }

  double testValue = 0.5;
  double resetValue = 0;

  @override
  Future<void> sendTestToAllNodes() async {
    for (var target in broadcastTargets.values) {
      sendAmplitudeToNode(target.socket, testValue);
    }
  }

  @override
  Future<void> sendResetToNode(String uuid) async {
    OSCSocket? socket = broadcastTargets[uuid]?.socket;
    if (socket == null) {
      logger.w('Broadcaster: No socket found for node with uuid "$uuid"');
      return;
    }
    sendAmplitudeToNode(socket, resetValue);
  }

  @override
  Future<void> sendResetToAllNodes() async {
    for (var target in broadcastTargets.values) {
      sendAmplitudeToNode(target.socket, resetValue);
    }
  }

  // TODO: dispose, with mdnsClient.stop()
}
