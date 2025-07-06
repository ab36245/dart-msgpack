import 'package:test/test.dart';

import 'util.dart';

void main() {
  group('time', () {
    void run(DateTime d, String e) =>
      runTest(
        encode: (e) => e.putTime(d),
        encoded: e,
        decode: (d) => d.getTime(), 
        decoded: d,
      );

    test('timestamp32', () {
      run(
        DateTime.utc(1997, 8, 28),
        '''
          |6 bytes
          |    0000 d6 ff 34 04 bf 80
        ''',
      );
    });

    test('timestamp64', () {
      run(
        DateTime.utc(1995, 9, 12, 0, 0, 0, 0, 420),
        '''
          |10 bytes
          |    0000 d7 ff 00 19 a2 80 30 54 cd 80
        ''',
      );
    });

    test('timestamp96', () {
      run(
        DateTime.utc(1961, 10, 19, 0, 0, 0, 0, 420),
        '''
          |15 bytes
          |    0000 c7 0c ff 00 06 68 a0 ff ff ff ff f0 92 32 00
        ''',
      );
    });
  });
}