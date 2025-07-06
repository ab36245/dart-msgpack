import 'dart:typed_data';

import 'package:test/test.dart';

import 'package:dart_msgpack/dart_msgpack.dart';

void main() {
  final decodeJS = false;
  MsgPackDecoder getDecoder(Uint8List bytes) =>
    MsgPackDecoder(bytes, isJS: decodeJS);

  final encodeJS = false;
  MsgPackEncoder getEncoder() =>
    MsgPackEncoder(isJS: encodeJS);

  String doTrim(String s) {
    s = s.trim();
    var t = '';
    for (final l in s.split('\n')) {
      if (t != '') {
        t += '\n';
      }
      var m = l.trim();
      final n = m.indexOf('|');
      if (n >= 0) {
        m = m.substring(n + 1);
      }
      t += m;
    }
    return t;
  }

  void doRun<T>({
    required Function(MsgPackEncoder) encode,
    required String encoded,
    T Function(MsgPackDecoder)? decode,
    T? decoded,
    bool prefixOnly = false,
  }) {
    Uint8List bytes;

    try {
      final encoder = getEncoder();
      encode(encoder);
      bytes = encoder.bytes;
      var actual = bytes.dump();
      final expected = doTrim(encoded);
      if (prefixOnly) {
        actual = actual.substring(0, expected.length);
      }
      expect(actual, expected);
    } on MsgPackException catch (e) {
      final actual = 'exception: ${e.mesg}';
      final expected = doTrim(encoded);
      expect(actual, expected);
      return;
    }

    if (decode == null || decoded == null) {
      return;
    }
    try {
      final decoder = getDecoder(bytes);
      final actual = decode(decoder);
      final expected = decoded;
      expect(actual, expected);
    } on MsgPackException catch (e) {
      fail('exception: ${e.mesg}');
    }
  }

  group('array length', () {
    void run(int n, String encoded) =>
      doRun(
        decode: (d) => d.getArrayLength(),
        decoded: n,
        encode: (e) => e.putArrayLength(n),
        encoded: encoded,
      );

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
    test('negative', () {
      run(
        -1,
        'exception: array length (-1) negative'
      );
    });
    test('over 32 bit', () {
      run(
        4294967299,
        'exception: array length (4294967299) too large',
      );
    });
  });

  group('bool', () {
    void run(bool b, String e) =>
      doRun(
        decode: (d) => d.getBool(),
        decoded: b,
        encode: (e) => e.putBool(b),
        encoded: e,
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

  group('bytes', () {
    void run(Uint8List b, String e) =>
      doRun(
        decode: (d) => d.getBytes(),
        decoded: b,
        encode: (e) => e.putBytes(b),
        encoded: e,
        prefixOnly: true,
      );

    test('8 bit length', () {
      run(
        Uint8List(240),
        '''
          |242 bytes
          |    0000 c4 f0 00 00
        ''',
      );
    });
    test('16 bit length', () {
      run(
        Uint8List(2400),
        '''
          |2403 bytes
          |    0000 c5 09 60 00 00
        ''',
      );
    });
    test('32 bit length', () {
      // Note: this test is *slow*!
      run(
        Uint8List(240000),
        '''
          |240005 bytes
          |    0000 c6 00 03 a9 80 00 00
        ''',
      );
    });
    test('over 32 bit length', () {
      // Note: this test is *slow*!
      run(
        Uint8List(4294967296),
        'exception: byte list (4294967296 bytes) is too long to encode',
      );
    });
  });

  test('float32', () {
    void run(double f, String e) =>
      doRun(
        decode: (d) => d.getFloat(),
        decoded: f,
        encode: (e) => e.putFloat32(f),
        encoded: e,
      );

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
      doRun(
        decode: (d) => d.getFloat(),
        decoded: f,
        encode: (e) => e.putFloat64(f),
        encoded: e,
      );

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
      doRun(
        encode: (e) => e.putInt(i),
        encoded: e,
        decode: (d) => d.getInt(),
        decoded: i,
      );

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
      doRun(
        encode: (e) => e.putMapLength(n),
        encoded: e,
        decode: (d) => d.getMapLength(),
        decoded: n,
      );

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
    test('negative', () {
      run(
        -1,
        'exception: map length (-1) negative'
      );
    });
    test('over 32 bit', () {
      run(
        4294967299,
        'exception: map length (4294967299) too large',
      );
    });
  });

  test('nil', () {
    void run(String e) =>
      doRun(
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

  group('strings', () {
    final base = 'hi!';
    void run(int n, String e) {
      final s = base * n;
      doRun(
        encode: (e) => e.putString(s),
        encoded: e,
        decode: (d) => d.getString(),
        decoded: s,
        prefixOnly: true,
      );
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
        80000,
        '''
          |240005 bytes
          |    0000 db 00 03 a9 80 68 69 21
        ''',
      );
    });

    test('over 32 bit length', () {
      // Note: this test is *slow*!
      run(
        431655800,
        'exception: string (4294967296 bytes) is too long to encode',
      );
    });
  });

  group('time', () {
    void run(DateTime d, String e) =>
      doRun(
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

  group('uint', () {
    void run(int i, String e) =>
      doRun(
        encode: (e) => e.putUint(i),
        encoded: e,
        decode: (d) => d.getUint(),
        decoded: i,
      );

    test('fixint', () {
      run(
        69,
        '''
          |1 bytes
          |    0000 45
        ''',
      );
    });

    test('8 bit', () {
      run(
        130,
        '''
          |2 bytes
          |    0000 cc 82
        ''',
      );
    });

    test('16 bit', () {
      run(
        259,
        '''
          |3 bytes
          |    0000 cd 01 03
        ''',
      );
    });

    test('32 bit', () {
      run(
        65538,
        '''
          |5 bytes
          |    0000 ce 00 01 00 02
        ''',
      );
    });

    test('64 bit', () {
      run(
        4294967299,
        '''
          |9 bytes
          |    0000 cf 00 00 00 01 00 00 00 03
        ''',
      );
    });

    test('negative', () {
      run(
        -1,
        'exception: uint (-1) negative'
      );
    });
  });
}
