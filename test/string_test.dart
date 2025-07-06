import 'package:test/test.dart';

import 'util.dart';

void main() {
  group('string', () {
    final base = '*';
    void run(int n, String e) {
      final s = base * n;
      runTest(
        encode: (e) => e.putString(s),
        encoded: e,
        decode: (d) => d.getString(),
        decoded: s,
        prefixOnly: true,
      );
    }

    test('fixstr', () {
      final max = 31;
      run(
        max,
        '''
          |32 bytes
          |    0000 bf 2a 2a
        ''',
      );
    });

    test('8 bit length', () {
      final min = 32;
      final max = 255;
      run(
        min,
        '''
          |34 bytes
          |    0000 d9 20 2a 2a
        ''',
      );
      run(
        max,
        '''
          |257 bytes
          |    0000 d9 ff 2a 2a
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
          |    0000 da 01 00 2a 2a
          ''',
      );
      run(
        max,
        '''
          |65538 bytes
          |    0000 da ff ff 2a 2a
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
          |    0000 db 00 01 00 00 2a 2a
        ''',
      );
      // Note: this test is *very slow*!
      // run(
      //   max,
      //   '''
      //     |65541 bytes
      //     |    0000 db 00 01 00 00 2a 2a
      //   ''',
      // );
    });

    test('over 32 bit length', () {
      // Note: this test is *very slow*!
      // final min = 4294967296;
      // run(
      //   min,
      //   'exception: string ($min bytes) is too long to encode',
      // );
    });
  });
}