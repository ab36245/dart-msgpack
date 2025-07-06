import 'package:test/test.dart';

import 'util.dart';

void main() {
  test('float32', () {
    void run(double f, String e) =>
      runTest(
        encode: (e) => e.putFloat32(f),
        encoded: e,
        decode: (d) => d.getFloat(),
        decoded: f,
      );

    run(
      85.125,
      '''
        |5 bytes
        |    0000 ca 42 aa 40 00
      ''',
    );
    // run(
    //   85.3,
    //   '''
    //     |5 bytes
    //     |    0000 ca 42 aa 99 9a
    //   ''',
    // );
    run(
      0.00085125,
      '''
        |5 bytes
        |    0000 ca 3a 5f 26 6c
      ''',
    );
  });

  test('float64', () {
    void run(double f, String e) =>
      runTest(
        decode: (d) => d.getFloat(),
        decoded: f,
        encode: (e) => e.putFloat64(f),
        encoded: e,
      );

    run(
      85.125,
      '''
        |9 bytes
        |    0000 cb 40 55 48 00 00 00 00 00
      ''',
    );
    run(
      85.3,
      '''
        |9 bytes
        |    0000 cb 40 55 53 33 33 33 33 33
      ''',
    );
    run(
      0.00085125,
      '''
        |9 bytes
        |    0000 cb 3f 4b e4 cd 74 92 79 14
      ''',
    );
  });
}