import 'exception.dart';

Never fail(String mesg) =>
    throw MsgPackException(mesg);

String hex(int b) =>
  b.toRadixString(16).padLeft(2, '0');

Never invalid(String what, int b) =>
  fail('invalid byte for $what (0x${hex(b)})');