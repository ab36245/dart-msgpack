import 'package:test/test.dart';

import 'util.dart';

void main() {
  group('map length', () {
    void run(int n, String e) =>
      runTest(
        encode: (e) => e.putMapLength(n),
        encoded: e,
        decode: (d) => d.getMapLength(),
        decoded: n,
      );

    test('fixarray', () {
      final max = 15;
      run(
        max,
        '''
          |1 bytes
          |    0000 8f
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
          |    0000 de 00 10
        ''',
      );
      run(
        max,
        '''
          |3 bytes
          |    0000 de ff ff
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
          |    0000 df 00 01 00 00
        ''',
      );
      run(
        max,
        '''
          |5 bytes
          |    0000 df ff ff ff ff
        ''',
      );
    });
    test('outside bounds', () {
      final neg = -1;
      run(
        neg,
        'exception: map length ($neg) negative'
      );
      final min = 4294967296;
      run(
        min,
        'exception: map length ($min) too large',
      );
    });
  });
}