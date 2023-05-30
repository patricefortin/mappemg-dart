/*
 * This is the "TCP Client" transport channel. 
 * We connect to a server listening for incoming TCP connection (from us)
 * This server can send commands
 * 
 * Typical use:
 * - start netcat in listen mode
 * - wait for a client to connect
 * - type a command "/color ff0000" + Enter
 * - see the change in the application
 */
import 'dart:async';

import 'package:tcp_socket_connection/tcp_socket_connection.dart';

import '../../configuration.dart';
import '../../constants.dart';
import '../../interfaces/i_configurable_host_port.dart';
import '../../mapping/color_mapper.dart';
import '../../mapping/range_mapper.dart';
import '../../types/common.dart';
import 'command_channel_base.dart';

class CommandChannelReverseTcp extends CommandChannelBase
    implements IConfigurableHostPort {
  CommandChannelReverseTcp();
  CommandChannelReverseTcp.testable({this.networkEnabled = false});

  String tcpConnectHost = kCommandChannelReverseTcpAddress;
  int tcpConnectPort = kCommandChannelReverseTcpOutPort;

  TcpSocketConnection? socketConnection;

  ToNormRangeMap mapBrightness = ToNormRangeMap(Range(0, 255));
  ToNormRangeMap mapVibrate = ToNormRangeMap(Range(0, 255));

  bool networkEnabled = true;
  bool isConnecting = false;

  @override
  Future<void> init() async {
    await super.init();

    //use this to see in the console what's happening

    if (networkEnabled) {
      socketConnection = TcpSocketConnection(tcpConnectHost, tcpConnectPort);

      socketConnection!.enableConsolePrint(true);
      // Don't await
      reconnect();
      watchConnect();
    }
  }

  @override
  Future<void> stop() async {
    socketConnection?.disconnect();
    socketConnection = null;
  }

  Future<void> reconnect() async {
    isConnecting = true;
    await socketConnection?.connect(5000, messageReceived, attempts: 3);
    isConnecting = false;
  }

  Future<void> watchConnect() async {
    // ugly HACK: we fully reconnect every 20 seconds, because the TcpSocketConnection does not inform us on disconnection
    Timer.periodic(const Duration(seconds: 20), (timer) async {
      getLogger().d('Running periodic');
      if (!isConnecting) {
        socketConnection?.disconnect();
        getLogger().d('Reconnecting tcp client');
        reconnect();
      }
    });
  }

  //receiving and sending back a custom message
  void messageReceived(String msg) {
    onText(msg, true);
    socketConnection?.sendMessage(kCommandChannelReverseTcpPrompt);

    if (msg.startsWith(kCommandChannelReverseTcpTokenColor)) {
      const argIndex = kCommandChannelReverseTcpTokenColor.length + 1;
      onColor(AppColor.fromString(msg.substring(argIndex)), true);
      return;
    }

    if (msg.startsWith(kCommandChannelReverseTcpTokenBrightness)) {
      const argIndex = kCommandChannelReverseTcpTokenBrightness.length + 1;
      onBrightness(
          mapBrightness.getDoubleFromString(msg.substring(argIndex)), true);
      return;
    }

    if (msg.startsWith(kCommandChannelReverseTcpTokenVibrate)) {
      const argIndex = kCommandChannelReverseTcpTokenVibrate.length + 1;
      onVibrate(mapVibrate.getDoubleFromString(msg.substring(argIndex)), true);
      return;
    }

    if (msg.startsWith(kCommandChannelReverseTcpTokenHelp)) {
      socketConnection?.sendMessage(getHelpMessage());
      socketConnection?.sendMessage(kCommandChannelReverseTcpPrompt);
      return;
    }
  }

  String getHelpMessage() {
    return "\n"
        "\nThis is the MappEMG mobile application command interface (reverse TCP connection)."
        "\nCommands typed will be sent over the network to the mobile application."
        "\n"
        "\nUsage:"
        "\n  $kCommandChannelReverseTcpTokenVibrate <amplitude>"
        "\n  $kCommandChannelReverseTcpTokenBrightness <amplitude>"
        "\n  $kCommandChannelReverseTcpTokenColor <code>"
        "\n  ${kCommandChannelReverseTcpTokenHelp[0]}"
        "\n"
        "\nExamples:"
        "\n  $kCommandChannelReverseTcpTokenVibrate 100"
        "\n  $kCommandChannelReverseTcpTokenBrightness 200"
        "\n  $kCommandChannelReverseTcpTokenColor 00ff00"
        "\n\n";
  }

  @override
  Future<void> setHost(String host) async {
    await stop();
    tcpConnectHost = host;
    await init();
  }

  @override
  Future<void> setPort(int port) async {
    await stop();
    tcpConnectPort = port;
    await init();
  }

  @override
  Future<void> setHostPort(String host, int port) async {
    await stop();
    tcpConnectHost = host;
    tcpConnectPort = port;
    await init();
  }
}
