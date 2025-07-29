import 'dart:typed_data';

import 'package:test/test.dart';

import 'package:dart_msgpack/dart_msgpack.dart';

void main() {
  group('binary', () {
    void run(int n, String e) {
      final b = Uint8List(n);
      final mpe = MsgPackEncoder();
      mpe.putBinary(b);
      expect(mpe.asString(10), startsWith(e));
      final mpd = MsgPackDecoder(mpe.bytes);
      final a = mpd.getBinary();
      expect(a, b);
    }

    group('8 bit length', () {
      test('max', () => run(255, 'c4 ff 00 00'));
    });

    group('16 bit length', () {
      test('min', () => run(256, 'c5 01 00 00 00'));
      test('max', () => run(65535, 'c5 ff ff 00 00'));
    });

    group('32 bit length', () {
      test('min', () => run(65536, 'c6 00 01 00 00 00 00'));
      // Note: this test is *very slow*!
      // test('max', () => run(4294967295, 'c6 ff ff ff ff 00 00'));
    });

    test('too big', () {
      var mesg = 'expected an exception but didn\'t get one';
      try {
        final mpe = MsgPackEncoder();
        mpe.putBinary(Uint8List(4294967296));
      } on MsgPackException catch(e) {
        mesg = e.mesg;
      } catch (e) {
        mesg = 'unexpected exception $e';
      }
      expect(mesg, 'byte list (4294967296 bytes) is too long to encode');
    });
  });
}