abstract interface class IAdvertiser {
  Future<void> init();
  Future<void> startAdvertising(String uuid);
  Future<void> stopAdvertising();
}
