import 'dart:convert' show utf8;
import 'dart:typed_data';

import 'platform.dart';
import 'sizes.dart';
import 'util.dart';

class MsgPackDecoder {
  MsgPackDecoder(this._bytes);

  Uint8List get bytes =>
    _bytes.sublist(_index);

  bool get isEmpty =>
    _index >= _bytes.length;

  int get length =>
    _bytes.length - _index;

  int getArrayLength() {
    final b = _readByte();
    if (b & 0xf0 == 0x90) {
      return b & 0x0f;
    }
    return switch (b) {
      0xdc => _readUint16(),
      0xdd => _readUint32(),
      _ => fail('invalid byte for array length (${hex(b)})'),
    };
  }

  bool getBool() {
    final b = _readByte();
    return switch (b) {
      0xc2 => false,
      0xc3 => true,
      _ => fail('invalid byte for boolean (${hex(b)})'),
    };
  }

  Uint8List getBytes() {
    final b = _readByte();
    final n = switch (b) {
      0xc4 => _readUint8(),
      0xc5 => _readUint16(),
      0xc6 => _readUint32(),
      _ => fail('invalid byte for bytes length (${hex(b)})'),
    };
    return _readBytes(n);
  }

  (int, int) getExtUint() {
    final b = _readByte();
    final typ = _readUint8();
    return switch (b) {
      0xd4 => (typ, _readUint8()),
      0xd5 => (typ, _readUint16()),
      0xd6 => (typ, _readUint32()),
      0xd7 => (typ, _readUint64()),
      _ => fail('invalid byte for ext uint (${hex(b)})'),
    };
  }

  double getFloat() {
    final b = _readByte();
    return switch (b) {
      0xca => _readFloat32(),
      0xcb => _readFloat64(),
      _ => fail('invalid byte for float (${hex(b)})'),
    };
  }

  int getInt() {
    final b = _readByte();
    if (b & 0x80 == 0) {
      // positive
      return b;
    }
    if (b & 0xe0 == 0xe0) {
      // negative
      return b - 256;
    }
    return switch (b) {
      0xd0 => _readInt8(),
      0xd1 => _readInt16(),
      0xd2 => _readInt32(),
      0xd3 => _readInt64(),
      _ => fail('invalid byte for int (${hex(b)})'),
    };
  }

  int getMapLength() {
    final b = _readByte();
    if (b & 0xf0 == 0x80) {
      return b & 0x0f;
    }
    return switch (b) {
      0xde => _readUint16(),
      0xdf => _readUint32(),
      _ => fail('invalid byte for map length (${hex(b)})'),
    };
  }

  String getString() {
    final b = _readByte();
    int n;
    if (b & 0xe0 == 0xa0) {
      n = b & 0x1f;
    } else {
      n = switch (b) {
        0xd9 => _readUint8(),
        0xda => _readUint16(),
        0xdb => _readUint32(),
        _ => fail('invalid byte for string length (${hex(b)})'),
      };
    }
    final u = _readBytes(n);
    return utf8.decode(u);
  }

  DateTime getTime() {
    final b = _readByte();
    var nsec = 0;
    var sec = 0;
    switch (b) {
      case 0xd6:
        // timestamp 32
        final t = _readByte();
        if (t != 255) {
          fail('invalid type for timestamp 32 extension (${hex(t)})');
        }
        nsec = 0;
        sec = _readInt32();
      case 0xd7:
        // timestamp 64
        final t = _readByte();
        if (t != 255) {
          fail('invalid type for timestamp 64 extension (${hex(t)})');
        }
        final data64 = _readUint64();
        if (isJS) {
          // Because JavaScript can't handle 64-bit bitwise operations!
          nsec = data64 ~/ size34;
          sec = data64 % size34;
        } else {
          nsec = data64 >> 34;
          sec = data64 & (size34 - 1);
        }
      case 0xc7:
        // timestamp 96
        final n = _readByte();
        if (n != 12) {
          fail('invalid length for timestamp 96 extension (${hex(n)})');
        }
        final t = _readByte();
        if (t != 255) {
          fail('invalid type for timestamp 96 extension (${hex(t)})');
        }
        nsec = _readUint32();
        sec = _readInt64();
      default:
        fail('invalid byte for timestamp extension (${hex(b)})');
    }
    final usec = sec * 1000 * 1000 + nsec ~/ 1000;
    return DateTime.fromMicrosecondsSinceEpoch(usec, isUtc: true);
  }

  int getUint() {
    final b = _readByte();
    if (b & 0x80 == 0) {
      return b;
    }
    return switch (b) {
      0xcc => _readUint8(),
      0xcd => _readUint16(),
      0xce => _readUint32(),
      0xcf => _readUint64(),
      _ => fail('invalid byte for unsigned int (${hex(b)})'),
    };
  }

  bool ifNil() {
    final b = _peekByte();
    if (b != 0xc0) {
      return false;
    }
    _readByte();
    return true;
  }

  final Uint8List _bytes;
  var _index = 0;
  late final _view = ByteData.sublistView(_bytes);

  T _peek<T>(int size, T Function(int) f) {
    int length = _bytes.length;
    int excess = _index + size - length;
    if (excess > 0) {
      fail('trying to read $excess bytes beyond end of buffer ($length bytes)');
    }
    final value = f(_index);
    return value;
  }

  int _peekByte() =>
    _peek(1, (i) => _bytes[i]);

  T _read<T>(int size, T Function(int) f) {
    final value = _peek(size, f);
    _index += size;
    return value;
  }

  int _readByte() =>
    _read(1, (i) => _bytes[i]);

  Uint8List _readBytes(int n) =>
    _read(n, (i) => _bytes.sublist(i, i + n));

  double _readFloat32() =>
    _read(4, _view.getFloat32);

  double _readFloat64() =>
    _read(8, _view.getFloat64);

  int _readInt8() =>
    _read(1, _view.getInt8);

  int _readInt16() =>
    _read(2, _view.getInt16);

  int _readInt32() =>
    _read(4, _view.getInt32);

  int _readInt64() {
    if (isJS) {
      // Because JavaScript can't handle 64-bit bitwise operations!
      final be = _read(4, _view.getInt32);
      final le = _read(4, _view.getUint32);
      return be * size32 + le;
    }
    return _read(8, _view.getInt64);
  }

  int _readUint8() =>
    _read(1, _view.getUint8);

  int _readUint16() =>
    _read(2, _view.getUint16);

  int _readUint32() =>
    _read(4, _view.getUint32);

  int _readUint64() {
    if (isJS) {
      // Because JavaScript can't handle 64-bit bitwise operations!
      final be = _read(4, _view.getUint32);
      final le = _read(4, _view.getUint32);
      return be * size32 + le;
    }
    return _read(8, _view.getUint64);
  }
}