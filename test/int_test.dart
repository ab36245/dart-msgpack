import 'package:test/test.dart';

import 'package:dart_msgpack/dart_msgpack.dart';

void main() {
  group('int', () {
    void run(int i, String e) {
      final mpe = MsgPackEncoder();
      mpe.putInt(i);
      expect(mpe.asString(), e);
      final mpd = MsgPackDecoder(mpe.bytes);
      final a = mpd.getInt();
      expect(a, i);
    }

    group('fixint', () {
      test('max positive', () => run(127, '7f'));
      test('min negative', () => run(-1, 'ff'));
      test('max negative', () => run(-32, 'e0'));
    });

    group('8 bit', () {
      test('min negative', () => run(-33, 'd0 df'));
      test('max negative', () => run(-128, 'd0 80'));
    });

    group('16 bit', () {
      test('min positive', () => run(128, 'd1 00 80'));
      test('max positive', () => run(32767, 'd1 7f ff'));
      test('min negative', () => run(-129, 'd1 ff 7f'));
      test('max negative', () => run(-32768, 'd1 80 00'));
    });

    group('32 bit', () {
      test('min positive', () => run(32768, 'd2 00 00 80 00'));
      test('max positive', () => run(2147483647, 'd2 7f ff ff ff'));
      test('min negative', () => run(-32769, 'd2 ff ff 7f ff'));
      test('max negative', () => run(-2147483648, 'd2 80 00 00 00'));
    });

    group('64 bit', () {
      test('min positive', () => run(2147483648, 'd3 00 00 00 00 80 00 00 00'));
      test('min negative', () => run(-2147483649, 'd3 ff ff ff ff 7f ff ff ff'));
    });
  });
}