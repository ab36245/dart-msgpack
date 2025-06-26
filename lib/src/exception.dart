class MsgPackException implements Exception {
  final String mesg;

  const MsgPackException(this.mesg);

  @override
  String toString() =>
    '$runtimeType: $mesg';
}