import 'package:dart_msgpack/dart_msgpack.dart';
import 'package:test/test.dart';

void main() {
  group('nil', () {
    test('put', () {
      final mpe = MsgPackEncoder();
      mpe.putNil();
      expect(mpe.asString(), 'c0');
    });
    // TODO: test isNil and ifNil
  });
}