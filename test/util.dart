import 'dart:typed_data';
import 'package:test/test.dart';

import 'package:dart_msgpack/dart_msgpack.dart';

void runTest<T>({
  T Function(MsgPackDecoder)? decode,
  T? decoded,
  required Function(MsgPackEncoder) encode,
  required String encoded,
  bool prefixOnly = false,
}) {
  Uint8List bytes;

  try {
    final encoder = MsgPackEncoder();
    encode(encoder);
    bytes = encoder.bytes;
    var actual = bytes.dump();
    final expected = encoded.trimPrefix();
    if (prefixOnly) {
      actual = actual.substring(0, expected.length);
    }
    expect(actual, expected, reason: 'value $decoded');
  } on MsgPackException catch (e) {
    final actual = 'exception: ${e.mesg}';
    final expected = encoded.trimPrefix();
    expect(actual, expected);
    return;
  }

  if (decode == null || decoded == null) {
    return;
  }
  try {
    final decoder = MsgPackDecoder(bytes);
    final actual = decode(decoder);
    final expected = decoded;
    expect(actual, expected);
  } on MsgPackException catch (e) {
    fail('exception: ${e.mesg}');
  }
}

extension TrimPrefixExtension on String {
  String trimPrefix([String prefix = '|']) {
    var trimmed = '';
    for (var line in trim().split('\n')) {
      if (trimmed != '') {
        trimmed += '\n';
      }
      line = line.trim();
      final pos = line.indexOf('|');
      if (pos >= 0) {
        line = line.substring(pos + 1);
      }
      trimmed += line;
    }
    return trimmed;
  }
}