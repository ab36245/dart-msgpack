import 'dart:typed_data';

import 'package:test/test.dart';

import 'package:dart_msgpack/dart_msgpack.dart';

void main() {
  group('MsgEncoder', () {
    group('array length', () {
      void run(int n, String e) =>
        _run(e, (me) => me.putArrayLength(n));

      test('fixarray', () {
        run(
          10,
          '''
            |1 bytes
            |    0000 9a
          ''',
        );
      });
      test('16 bit', () {
        run(
          30000,
          '''
            |3 bytes
            |    0000 dc 75 30
          ''',
        );
      });
      test('32 bit', () {
        run(
          80000,
          '''
            |5 bytes
            |    0000 dd 00 01 38 80
          ''',
        );
      });
    });

    group('bool', () {
      void run(bool b, String e) =>
        _run(e, (me) => me.putBool(b));
  
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

    group('bytes', () {
      void run(int n, String e) {
        final b = Uint8List(n);
        _run(e, (me) => me.putBytes(b), true);
      }

      test('8 bit length', () {
        run(
          240,
          '''
            |242 bytes
            |    0000 c4 f0 00 00
          ''',
        );
      });
      test('16 bit length', () {
        run(
          2400,
          '''
            |2403 bytes
            |    0000 c5 09 60 00 00
          ''',
        );
      });
      test('32 bit length', () {
        // Note: this test is *slow*!
        run(
          240000,
          '''
            |240005 bytes
            |    0000 c6 00 03 a9 80 00 00
          ''',
        );
      });
      test('over 32 bit length', () {
        final b = Uint8List(4294967296);
        final me = MsgPackEncoder();
        var v = '';
        try {
          me.putBytes(b);
        } on MsgPackException catch (e) {
          v = e.mesg;
        }
        final e = 'byte list (4294967296 bytes) is too long to encode';
        expect(v, e);
      });
    });

    test('float32', () {
      void run(double f, String e) =>
        _run(e, (me) => me.putFloat32(f));

      run(
        85.125,
        '''
          |5 bytes
          |    0000 ca 42 aa 40 00
        ''',
      );
      run(
        85.3,
        '''
          |5 bytes
          |    0000 ca 42 aa 99 9a
        ''',
      );
      run(
        0.00085125,
        '''
          |5 bytes
          |    0000 ca 3a 5f 26 6c
        ''',
      );
    });

    test('float64', () {
      void run(double f, String e) =>
        _run(e, (me) => me.putFloat64(f));

      run(
        85.125,
        '''
          |9 bytes
          |    0000 cb 40 55 48 00 00 00 00 00
        ''',
      );
      run(
        85.3,
        '''
          |9 bytes
          |    0000 cb 40 55 53 33 33 33 33 33
        ''',
      );
      run(
        0.00085125,
        '''
          |9 bytes
          |    0000 cb 3f 4b e4 cd 74 92 79 14
        ''',
      );
    });

    group('ints', () {
      void run(int i, String e) =>
        _run(e, (me) => me.putInt(i));

      test('fixint', () {
        run(
          69,
          '''
            |1 bytes
            |    0000 45
          ''',
        );
        run(
          -11,
          '''
            |1 bytes
            |    0000 f5
          ''',
        );
      });

      test('8 bit', () {
        run(
          -42,
          '''
            |2 bytes
            |    0000 d0 d6
          ''',
        );
      });

      test('16 bit', () {
        run(
          259,
          '''
            |3 bytes
            |    0000 d1 01 03
          ''',
        );
        run(
          -259,
          '''
            |3 bytes
            |    0000 d1 fe fd
          ''',
        );
      });

      test('32 bit', () {
        run(
          65538,
          '''
            |5 bytes
            |    0000 d2 00 01 00 02
          ''',
        );
        run(
          -65538,
          '''
            |5 bytes
            |    0000 d2 ff fe ff fe
          ''',
        );
      });

      test('64 bit', () {
        run(
          4294967299,
          '''
            |9 bytes
            |    0000 d3 00 00 00 01 00 00 00 03
          ''',
        );
        run(
          -4294967299,
          '''
            |9 bytes
            |    0000 d3 ff ff ff fe ff ff ff fd
          ''',
        );
      });
    });

    group('map length', () {
      void run(int n, String e) =>
        _run(e, (me) => me.putMapLength(n));

      test('fixarray', () {
        run(
          10,
          '''
            |1 bytes
            |    0000 8a
          ''',
        );
      });
      test('16 bit', () {
        run(
          30000,
          '''
            |3 bytes
            |    0000 de 75 30
          ''',
        );
      });
      test('32 bit', () {
        run(
          80000,
          '''
            |5 bytes
            |    0000 df 00 01 38 80
          ''',
        );
      });
    });

    test('nil', () {
      void run(String e) =>
        _run(e, (me) => me.putNil());

      run(
        '''
          |1 bytes
          |    0000 c0
        ''',
      );
    });

    group('strings', () {
      final base = 'hi!';
      void run(int n, String e) {
        final s = base * n;
        _run(e, (me) => me.putString(s), true);
      }

      test('fixstr', () {
        run(
          10,
          '''
            |31 bytes
            |    0000 be 68 69 21
          ''',
        );
      });

      test('8 bit length', () {
        run(
          80,
          '''
            |242 bytes
            |    0000 d9 f0 68 69 21
          ''',
        );
      });

      test('16 bit length', () {
        run(
          800,
          '''
            |2403 bytes
            |    0000 da 09 60 68 69 21
            ''',
        );
      });

      test('32 bit length', () {
        // Note: this test is *slow*!
        run(
          80000, '''
            |240005 bytes
            |    0000 db 00 03 a9 80 68 69 21
          ''',
        );
      });

      test('over 32 bit length', () {
        // Note: this test is *slow*!
        final s = "a" * 4294967296;
        final me = MsgPackEncoder();
        var v = '';
        try {
          me.putString(s);
        } on MsgPackException catch (e) {
          v = e.mesg;
        }
        final e = 'string (4294967296 bytes) is too long to encode';
        expect(v, e);
      });
    });

    group('time', () {
      void run(DateTime d, String e) =>
        _run(e, (me) => me.putTime(d));

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

      test('timestamp32', () {
        run(
          DateTime.utc(1961, 10, 19, 0, 0, 0, 0, 420),
          '''
            |15 bytes
            |    0000 c7 0c ff 00 06 68 a0 ff ff ff ff f0 92 32 00
          ''',
        );
      });
    });
  });
}

void _check(Uint8List v, String e, [bool prefix = false]) {
  var vs = v.dump();
  final es = _trim(e);
  if (prefix) {
    vs = vs.substring(0, es.length);
  }
  expect(vs, es);
}

void _run(String e, Function(MsgPackEncoder me) f, [bool prefix = false]) {
  final me = MsgPackEncoder();
  f(me);
  final v = me.bytes;
  _check(v, e, prefix);
}

String _trim(String s) {
  var t = '';
  for (final l in s.split('\n')) {
    var m = l.trim();
    final n = m.indexOf('|');
    if (n >= 0) {
      m = m.substring(n + 1);
      if (t != '') {
        t += '\n';
      }
      t += m;
    }
  }
  return t;
}