import 'package:test/test.dart';

import 'package:dart_msgpack/dart_msgpack.dart';

void main() {
  group('ext uint', () {
    void run(int ti, int i, String e) {
      final mpe = MsgPackEncoder();
      mpe.putExtUint(ti, i);
      expect(mpe.asString(), e);
      final mpd = MsgPackDecoder(mpe.bytes);
      final (ta, a) = mpd.getExtUint();
      expect(ta, ti);
      expect(a, i);
    }

    group('fixext1', () {
      test('max', () => run(255, 42, 'd4 2a ff'));
    });

    group('16 bit', () {
      test('min', () => run(256, 42, 'd5 2a 01 00'));
      test('max', () => run(65535, 42, 'd5 2a ff ff'));
    });

    group('32 bit', () {
      test('min', () => run(65536, 42, 'd6 2a 00 01 00 00'));
      test('max', () => run(4294967295, 42, 'd6 2a ff ff ff ff'));
    });

    group('64 bit', () {
      test('min', () => run(4294967296, 42, 'd7 2a 00 00 00 01 00 00 00 00'));
    });

    group('invalid', () {
      void run(int ti, int i, String e) {
        var mesg = 'expected an exception but didn\'t get one';
        try {
          final mpe = MsgPackEncoder();
          mpe.putExtUint(ti, i);
        } on MsgPackException catch(e) {
          mesg = e.mesg;
        } catch (e) {
          mesg = 'unexpected exception $e';
        }
        expect(mesg, e);
      }

      test('reserved type', () => run(-1, 0, 'ext type (-1) is reserved'));
      test('invalid type', () => run(256, 0, 'ext type (256) is too large to encode'));
      test('negative value', () => run(42, -1, 'ext uint (-1) negative'));

    });
  });
}