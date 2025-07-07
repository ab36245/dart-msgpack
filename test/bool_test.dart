import 'package:test/test.dart';

import 'package:dart_msgpack/dart_msgpack.dart';

void main() {
  group('bool', () {
    void run(bool b, String e) {
      final mpe = MsgPackEncoder();
      mpe.putBool(b);
      expect(mpe.asString(), e);
      final mpd = MsgPackDecoder(mpe.bytes);
      final a = mpd.getBool();
      expect(a, b);
    }

    test('false', () => run(false, 'c2'));
    test('true', () => run(true, 'c3'));
  });
}