abstract interface class IDebugChannel {
  Future<void> init();
  Future<void> write(String msg);
  void listenOnStreamScalar(Stream<dynamic> stream);
  void listenOnStreamList(Stream<List<dynamic>> stream);
}
