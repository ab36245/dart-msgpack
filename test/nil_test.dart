import 'package:test/test.dart';

import 'util.dart';

void main() {
  test('nil', () {
    void run(String e) =>
      runTest(
        encode: (e) => e.putNil(),
        encoded: e,
      );

    run(
      '''
        |1 bytes
        |    0000 c0
      ''',
    );
    // TODO: test isNil and ifNil
  });
}