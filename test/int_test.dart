import 'package:test/test.dart';

import 'util.dart';

void main() {
  group('int', () {
    void run(int i, String e) =>
      runTest(
        encode: (e) => e.putInt(i),
        encoded: e,
        decode: (d) => d.getInt(),
        decoded: i,
      );

    test('fixint', () {
      final maxPos = 127;
      final minNeg = -1;
      final maxNeg = -32;
      run(
        maxPos,
        '''
          |1 bytes
          |    0000 7f
        ''',
      );
      run(
        minNeg,
        '''
          |1 bytes
          |    0000 ff
        ''',
      );
      run(
        maxNeg,
        '''
          |1 bytes
          |    0000 e0
        ''',
      );
    });

    test('8 bit', () {
      final minNeg = -33;
      final maxNeg = -128;
      run(
        minNeg,
        '''
          |2 bytes
          |    0000 d0 df
        ''',
      );
      run(
        maxNeg,
        '''
          |2 bytes
          |    0000 d0 80
        ''',
      );
    });

    test('16 bit', () {
      final minPos = 128;
      final maxPos = 32767;
      final minNeg = -minPos - 1;
      final maxNeg = -maxPos - 1;
      run(
        minPos,
        '''
          |3 bytes
          |    0000 d1 00 80
        ''',
      );
      run(
        maxPos,
        '''
          |3 bytes
          |    0000 d1 7f ff
        ''',
      );
      run(
        minNeg,
        '''
          |3 bytes
          |    0000 d1 ff 7f
        ''',
      );
      run(
        maxNeg,
        '''
          |3 bytes
          |    0000 d1 80 00
        ''',
      );
    });

    test('32 bit', () {
      final minPos = 32768;
      final maxPos = 2147483647;
      final minNeg = -minPos - 1;
      final maxNeg = -maxPos - 1;
      run(
        minPos,
        '''
          |5 bytes
          |    0000 d2 00 00 80 00
        ''',
      );
      run(
        maxPos,
        '''
          |5 bytes
          |    0000 d2 7f ff ff ff
        ''',
      );
      run(
        minNeg,
        '''
          |5 bytes
          |    0000 d2 ff ff 7f ff
        ''',
      );
      run(
        maxNeg,
        '''
          |5 bytes
          |    0000 d2 80 00 00 00
        ''',
      );
    });

    test('64 bit', () {
      final minPos = 2147483648;
      final minNeg = -minPos - 1;
      run(
        minPos,
        '''
          |9 bytes
          |    0000 d3 00 00 00 00 80 00 00 00
        ''',
      );
      run(
        minNeg,
        '''
          |9 bytes
          |    0000 d3 ff ff ff ff 7f ff ff ff
        ''',
      );
    });
  });
}