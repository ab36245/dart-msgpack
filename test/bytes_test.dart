import 'dart:typed_data';

import 'package:test/test.dart';

import 'util.dart';

void main() {
  group('bytes', () {
    void run(int n, String e) {
      final b = Uint8List(n);
      runTest(
        encode: (e) => e.putBytes(b),
        encoded: e,
        prefixOnly: true,
        decode: (d) => d.getBytes(),
        decoded: b,
      );
    }

    test('8 bit length', () {
      final max = 255;
      run(
        max,
        '''
          |257 bytes
          |    0000 c4 ff 00 00
        ''',
      );
    });
    test('16 bit length', () {
      final min = 256;
      final max = 65535;
      run(
        min,
        '''
          |259 bytes
          |    0000 c5 01 00 00 00
        ''',
      );
      run(
        max,
        '''
          |65538 bytes
          |    0000 c5 ff ff 00 00
        ''',
      );
    });
    test('32 bit length', () {
      final min = 65536;
      // final max = 4294967295;
      run(
        min,
        '''
          |65541 bytes
          |    0000 c6 00 01 00 00 00 00
        ''',
      );
      // Note: this test is *very slow*!
      // run(
      //   max,
      //   '''
      //     |240005 bytes
      //     |    0000 c6 00 03 a9 80 00 00
      //   ''',
      // );
    });
    test('over 32 bit length', () {
      // Note: this test is *very slow*!
      // final min = 4294967296;
      // run(
      //   min,
      //   'exception: byte list ($min bytes) is too long to encode',
      // );
    });
  });
}