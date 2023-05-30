import 'dart:io';

class MeshNode {
  String uuid;
  String name;
  InternetAddress address;
  int port;
  bool isSelf;
  MeshNode({
    required this.uuid,
    required this.name,
    required this.address,
    required this.port,
    this.isSelf = false,
  });
}

typedef OnClientDiscovered = void Function(MeshNode node);

abstract interface class IBroadcaster {
  Future<void> init();
  void discoverNodes();
  List<MeshNode> get nodes;

  Future<void> sendTestToNode(String uuid);
  Future<void> sendResetToNode(String uuid);
  Future<void> sendTestToAllNodes();
  Future<void> sendResetToAllNodes();
  Future<void> removeNode(String uuid);
}
