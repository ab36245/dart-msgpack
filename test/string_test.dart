import 'package:test/test.dart';

import 'package:dart_msgpack/dart_msgpack.dart';

void main() {
  group('string', () {
    final base = '*';
    void run(int n, String e) {
      final s = base * n;
      final mpe = MsgPackEncoder();
      mpe.putString(s);
      expect(mpe.asString(10), startsWith(e));
      final mpd = MsgPackDecoder(mpe.bytes);
      final a = mpd.getString();
      expect(a, s);
    }

    group('fixstr', () {
      test('max', () => run(31, 'bf 2a 2a'));
    });

    group('8 bit length', () {
      test('min', () => run(32, 'd9 20 2a 2a'));
      test('max', () => run(255, 'd9 ff 2a 2a'));
    });

    group('16 bit length', () {
      test('min', () => run(256, 'da 01 00 2a 2a'));
      test('max', () => run(65535, 'da ff ff 2a 2a'));
    });

    group('32 bit length', () {
      test('min', () => run(65536, 'db 00 01 00 00 2a 2a'));
      // Note: this test is *very slow*!
      // test('max', () => run(4294967295, 'db ff ff ff ff 2a 2a'));
    });

    test('too big', () {
      // Note: this test is *very slow*!
      // var mesg = 'expected an exception but didn\'t get one';
      // try {
      //   final mpe = MsgPackEncoder();
      //   mpe.putString(base * 4294967296);
      // } on MsgPackException catch(e) {
      //   mesg = e.mesg;
      // } catch (e) {
      //   mesg = 'unexpected exception $e';
      // }
      // expect(mesg, 'string (4294967296 bytes) is too long to encode');
    });
  });
}