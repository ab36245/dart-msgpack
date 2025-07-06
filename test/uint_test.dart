import 'package:test/test.dart';

import 'util.dart';

void main() {
  group('uint', () {
    void run(int i, String e) =>
      runTest(
        encode: (e) => e.putUint(i),
        encoded: e,
        decode: (d) => d.getUint(),
        decoded: i,
      );

    test('fixint', () {
      final max = 127;
      run(
        max,
        '''
          |1 bytes
          |    0000 7f
        ''',
      );
    });

    test('8 bit', () {
      final min = 128;
      final max = 255;
      run(
        min,
        '''
          |2 bytes
          |    0000 cc 80
        ''',
      );
      run(
        max,
        '''
          |2 bytes
          |    0000 cc ff
        ''',
      );
    });

    test('16 bit', () {
      final min = 256;
      final max = 65535;
      run(
        min,
        '''
          |3 bytes
          |    0000 cd 01 00
        ''',
      );
      run(
        max,
        '''
          |3 bytes
          |    0000 cd ff ff
        ''',
      );
    });

    test('32 bit', () {
      final min = 65536;
      final max = 4294967295;
      run(
        min,
        '''
          |5 bytes
          |    0000 ce 00 01 00 00
        ''',
      );
      run(
        max,
        '''
          |5 bytes
          |    0000 ce ff ff ff ff
        ''',
      );
    });

    test('64 bit', () {
      final min = 4294967296;
      run(
        min,
        '''
          |9 bytes
          |    0000 cf 00 00 00 01 00 00 00 00
        ''',
      );
    });

    test('outside bounds', () {
      final neg = -1;
      run(
        neg,
        'exception: uint ($neg) negative'
      );
    });
  });
}
