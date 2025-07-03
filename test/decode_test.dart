import 'dart:typed_data';

import 'package:test/test.dart';

import '../lib/dart_msgpack.dart';

void main() {
  group('Decode', () {
    decodeArrayLengths();
  });
}

void decodeArrayLengths() {
  void run(int n, String e) {
    final me = MsgPackEncoder();
    me.putArrayLength(n);
    final v = me.bytes;
    encodeTest(v, e);
  }
    group('array lengths', () {
      test('fixarray', () {
        run(10, '''
          |1 bytes
          |    0000 9a
        ''');
      });
      test('16 bit', () {
        run(30000, '''
          |3 bytes
          |    0000 dc 75 30
        ''');
      });
      test('32 bit', () {
        run(80000, '''
          |5 bytes
          |    0000 dd 00 01 38 80
        ''');
      });
    });
}

void encodeTest(Uint8List v, String e) {
  final vs = v.dump();
  final es = trim(e);
  expect(vs, es);
}

String trim(String s) {
  var t = '';
  for (final l in s.split('\n')) {
    var m = l.trim();
    final n = m.indexOf('|');
    if (n >= 0) {
      m = m.substring(n + 1);
      if (t != '') {
        t += '\n';
      }
      t += m;
    }
  }
  return t;
}
