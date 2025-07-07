import 'package:test/test.dart';

import 'package:dart_msgpack/dart_msgpack.dart';

void main() {
  group('time', () {
    void run(DateTime d, String e) {
      final mpe = MsgPackEncoder();
      mpe.putTime(d);
      expect(mpe.asString(), e);
      final mpd = MsgPackDecoder(mpe.bytes);
      final a = mpd.getTime();
      expect(a, d);

    }

    test('timestamp32', () => run(
      DateTime.utc(1997, 8, 28),
      'd6 ff 34 04 bf 80',
    ));

    test('timestamp64', () => run(
      DateTime.utc(1995, 9, 12, 0, 0, 0, 0, 420),
      'd7 ff 00 19 a2 80 30 54 cd 80',
    ));

    test('timestamp96', () => run(
      DateTime.utc(1961, 10, 19, 0, 0, 0, 0, 420),
      'c7 0c ff 00 06 68 a0 ff ff ff ff f0 92 32 00',
    ));
  });
}