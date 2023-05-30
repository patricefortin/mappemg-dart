class InitException implements Exception {
  final String msg;
  const InitException(this.msg);

  @override
  String toString() => 'InitException: $msg';
}
