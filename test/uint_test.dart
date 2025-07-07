import 'package:test/test.dart';

import 'package:dart_msgpack/dart_msgpack.dart';

void main() {
  group('uint', () {
    void run(int i, String e) {
      final mpe = MsgPackEncoder();
      mpe.putUint(i);
      expect(mpe.asString(), e);
      final mpd = MsgPackDecoder(mpe.bytes);
      final a = mpd.getUint();
      expect(a, i);
    }

    group('fixint', () {
      test('max', () => run(127, '7f'));
    });

    group('8 bit', () {
      test('min', () => run(128, 'cc 80'));
      test('max', () => run(255, 'cc ff'));
    });

    group('16 bit', () {
      test('min', () => run(256, 'cd 01 00'));
      test('max', () => run(65535, 'cd ff ff'));
    });

    group('32 bit', () {
      test('min', () => run(65536, 'ce 00 01 00 00'));
      test('max', () => run(4294967295, 'ce ff ff ff ff'));
    });

    group('64 bit', () {
      test('min', () => run(4294967296, 'cf 00 00 00 01 00 00 00 00'));
    });

    test('negative', () {
      var mesg = 'expected an exception but didn\'t get one';
      try {
        final mpe = MsgPackEncoder();
        mpe.putUint(-1);
      } on MsgPackException catch(e) {
        mesg = e.mesg;
      } catch (e) {
        mesg = 'unexpected exception $e';
      }
      expect(mesg, 'uint (-1) negative');
    });
  });
}
