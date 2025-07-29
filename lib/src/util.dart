import 'exception.dart';

Never fail(String mesg) =>
    throw MsgPackException(mesg);

String hex(int b) =>
  b.toRadixString(16).padLeft(2, '0');