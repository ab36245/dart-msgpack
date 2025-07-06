import 'package:test/test.dart';

import 'util.dart';

void main() {
  group('bool', () {
    void run(bool b, String e) =>
      runTest(
        encode: (e) => e.putBool(b),
        encoded: e,
        decode: (d) => d.getBool(),
        decoded: b,
      );

    test('false', () {
      run(
        false,
        '''
          |1 bytes
          |    0000 c2
        ''',
      );
    });
    test('true', () {
      run(
        true,
        '''
          |1 bytes
          |    0000 c3
        ''',
      );
    });
  });
}