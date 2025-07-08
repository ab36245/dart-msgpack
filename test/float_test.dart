import 'package:test/test.dart';

import 'package:dart_msgpack/dart_msgpack.dart';

void main() {
  group('float32', () {
    void run(double f, String e) {
      final mpe = MsgPackEncoder();
      mpe.putFloat32(f);
      expect(mpe.asString(), e);
      final mpd = MsgPackDecoder(mpe.bytes);
      final a = mpd.getFloat();
      expect(a, closeTo(f, 0.00001));
    }

    test('85.125', () => run(85.125, 'ca 42 aa 40 00'));
    test('85.3', () => run(85.3, 'ca 42 aa 99 9a'));
    test('0.00085125', () => run(0.00085125, 'ca 3a 5f 26 6c'));
    test('3.1415', () => run(3.1415, 'ca 40 49 0e 56'));
  });

  group('float64', () {
    void run(double f, String e) {
      final mpe = MsgPackEncoder();
      mpe.putFloat64(f);
      expect(mpe.asString(), e);
      final mpd = MsgPackDecoder(mpe.bytes);
      final a = mpd.getFloat();
      expect(a, f);
    }

    test('85.125', () => run(85.125, 'cb 40 55 48 00 00 00 00 00'));
    test('85.3', () => run(85.3, 'cb 40 55 53 33 33 33 33 33'));
    test('0.00085125', () => run(0.00085125, 'cb 3f 4b e4 cd 74 92 79 14'));
    test('3.1415', () => run(3.1415, 'cb 40 09 21 ca c0 83 12 6f'));
  });

  group('float', () {
    void run(double f, String e) {
      final mpe = MsgPackEncoder();
      mpe.putFloat(f);
      expect(mpe.asString(), e);
      final mpd = MsgPackDecoder(mpe.bytes);
      final a = mpd.getFloat();
      expect(a, f);
    }

    test('85.125', () => run(85.125, 'ca 42 aa 40 00'));
    test('85.3', () => run(85.3, 'cb 40 55 53 33 33 33 33 33'));
    test('0.00085125', () => run(0.00085125, 'cb 3f 4b e4 cd 74 92 79 14'));
    test('3.1415', () => run(3.1415, 'ca 40 49 0e 56'));
  });
}