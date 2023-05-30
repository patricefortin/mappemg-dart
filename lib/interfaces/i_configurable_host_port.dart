abstract interface class IConfigurableHostPort {
  Future<void> init();
  Future<void> stop();
  Future<void> setHost(String host);
  Future<void> setPort(int port);
  Future<void> setHostPort(String host, int port);
}
