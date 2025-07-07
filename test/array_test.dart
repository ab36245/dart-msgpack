import 'package:test/test.dart';

import 'package:dart_msgpack/dart_msgpack.dart';

void main() {
  group('array', () {
    void run(int n, String e) {
      final mpe = MsgPackEncoder();
      mpe.putArrayLength(n);
      expect(mpe.asString(), e);
      final mpd = MsgPackDecoder(mpe.bytes);
      final a = mpd.getArrayLength();
      expect(a, n);
    }

    test('fixarray', () => run(15, '9f'));
    group('16 bit', () {
      test('min', () => run(16, 'dc 00 10'));
      test('max', () => run(65535, 'dc ff ff'));
    });
    group('32 bit', () {
      test('min', () => run(65536, 'dd 00 01 00 00'));
      test('max', () => run(4294967295, 'dd ff ff ff ff'));
    });

    test('negative', () {
      var mesg = 'expected an exception but didn\'t get one';
      try {
        final mpe = MsgPackEncoder();
        mpe.putArrayLength(-1);
      } on MsgPackException catch(e) {
        mesg = e.mesg;
      } catch (e) {
        mesg = 'unexpected exception $e';
      }
      expect(mesg, 'array length (-1) negative');
    });

    test('too big', () {
      var mesg = 'expected an exception but didn\'t get one';
      try {
        final mpe = MsgPackEncoder();
        mpe.putArrayLength(4294967296);
      } on MsgPackException catch(e) {
        mesg = e.mesg;
      } catch (e) {
        mesg = 'unexpected exception $e';
      }
      expect(mesg, 'array length (4294967296) too large');
    });
  });
}