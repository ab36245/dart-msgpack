import 'package:test/test.dart';

import 'util.dart';

void main() {
  group('array', () {
    void run(int n, String encoded) =>
      runTest(
        encode: (e) => e.putArrayLength(n),
        encoded: encoded,
        decode: (d) => d.getArrayLength(),
        decoded: n,
      );

    test('fixarray', () {
      final max = 15;
      run(
        max,
        '''
          |1 bytes
          |    0000 9f
        ''',
      );
    });
    test('16 bit', () {
      final min = 16;
      final max = 65535;
      run(
        min,
        '''
          |3 bytes
          |    0000 dc 00 10
        ''',
      );
      run(
        max,
        '''
          |3 bytes
          |    0000 dc ff ff
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
          |    0000 dd 00 01 00 00
        ''',
      );
      run(
        max,
        '''
          |5 bytes
          |    0000 dd ff ff ff ff
        ''',
      );
    });
    test('outside bounds', () {
      final neg = -1;
      run(
        neg,
        'exception: array length ($neg) negative'
      );
      final min = 4294967296;
      run(
        min,
        'exception: array length ($min) too large',
      );
    });
  });
}