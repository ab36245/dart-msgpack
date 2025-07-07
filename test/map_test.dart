import 'package:test/test.dart';

import 'package:dart_msgpack/dart_msgpack.dart';

void main() {
  group('map length', () {
    void run(int n, String e) {
      final mpe = MsgPackEncoder();
      mpe.putMapLength(n);
      expect(mpe.asString(), e);
      final mpd = MsgPackDecoder(mpe.bytes);
      final a = mpd.getMapLength();
      expect(a, n);
    }

    test('fixarray', () => run(15, '8f'));
    group('16 bit', () {
      test('min', () => run(16, 'de 00 10'));
      test('max', () => run(65535, 'de ff ff'));
    });
    group('32 bit', () {
      test('min', () => run(65536, 'df 00 01 00 00'));
      test('max', () => run(4294967295, 'df ff ff ff ff'));
    });

    test('negative', () {
      var mesg = 'expected an exception but didn\'t get one';
      try {
        final mpe = MsgPackEncoder();
        mpe.putMapLength(-1);
      } on MsgPackException catch(e) {
        mesg = e.mesg;
      } catch (e) {
        mesg = 'unexpected exception $e';
      }
      expect(mesg, 'map length (-1) negative');
    });

    test('too big', () {
      var mesg = 'expected an exception but didn\'t get one';
      try {
        final mpe = MsgPackEncoder();
        mpe.putMapLength(4294967296);
      } on MsgPackException catch(e) {
        mesg = e.mesg;
      } catch (e) {
        mesg = 'unexpected exception $e';
      }
      expect(mesg, 'map length (4294967296) too large');
    });
  });
}