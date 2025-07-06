import 'dart:convert' show utf8;
import 'dart:typed_data';

import 'exception.dart';
import 'platform.dart';
import 'reader.dart';
import 'sizes.dart';

class MsgPackDecoder {
  MsgPackDecoder(Uint8List bytes, {
    bool isJS = isJS,
  }) :
    _isJS = isJS,
    _reader = MsgPackReader(bytes, isJS);

  int getArrayLength() {
    final b = _reader.readByte();
    if (b & 0xf0 == 0x90) {
      return b & 0x0f;
    }
    return switch (b) {
      0xdc => _reader.readUint16(),
      0xdd => _reader.readUint32(),
      _ => _fail('invalid byte for array length (${_hex(b)})'),
    };
  }

  bool getBool() {
    final b = _reader.readByte();
    return switch (b) {
      0xc2 => false,
      0xc3 => true,
      _ => _fail('invalid byte for boolean (${_hex(b)})'),
    };
  }

  Uint8List getBytes() {
    final b = _reader.readByte();
    final n = switch (b) {
      0xc4 => _reader.readUint8(),
      0xc5 => _reader.readUint16(),
      0xc6 => _reader.readUint32(),
      _ => _fail('invalid byte for bytes length (${_hex(b)})'),
    };
    return _reader.readBytes(n);
  }

  double getFloat() {
    final b = _reader.readByte();
    return switch (b) {
      0xca => _reader.readFloat32(),
      0xcb => _reader.readFloat64(),
      _ => _fail('invalid byte for float (${_hex(b)})'),
    };
  }

  int getInt() {
    final b = _reader.readByte();
    if (b & 0x80 == 0) {
      // positive
      return b;
    }
    if (b & 0xe0 == 0xe0) {
      // negative
      return b - 256;
    }
    return switch (b) {
      0xd0 => _reader.readInt8(),
      0xd1 => _reader.readInt16(),
      0xd2 => _reader.readInt32(),
      0xd3 => _reader.readInt64(),
      _ => _fail('invalid byte for int (${_hex(b)})'),
    };
  }

  int getMapLength() {
    final b = _reader.readByte();
    if (b & 0xf0 == 0x80) {
      return b & 0x0f;
    }
    return switch (b) {
      0xde => _reader.readUint16(),
      0xdf => _reader.readUint32(),
      _ => _fail('invalid byte for map length (${_hex(b)})'),
    };
  }

  String getString() {
    final b = _reader.readByte();
    int n;
    if (b & 0xe0 == 0xa0) {
      n = b & 0x1f;
    } else {
      n = switch (b) {
        0xd9 => _reader.readUint8(),
        0xda => _reader.readUint16(),
        0xdb => _reader.readUint32(),
        _ => _fail('invalid byte for string length (${_hex(b)})'),
      };
    }
    final u = _reader.readBytes(n);
    return utf8.decode(u);
  }

  DateTime getTime() {
    final b = _reader.readByte();
    var nsec = 0;
    var sec = 0;
    switch (b) {
      case 0xd6:
        // timestamp 32
        final t = _reader.readByte();
        if (t != 255) {
          _fail('invalid type for timestamp 32 extension (${_hex(t)})');
        }
        nsec = 0;
        sec = _reader.readInt32();
      case 0xd7:
        // timestamp 64
        final t = _reader.readByte();
        if (t != 255) {
          _fail('invalid type for timestamp 64 extension (${_hex(t)})');
        }
        final data64 = _reader.readUint64();
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
        final n = _reader.readByte();
        if (n != 12) {
          _fail('invalid length for timestamp 96 extension (${_hex(n)})');
        }
        final t = _reader.readByte();
        if (t != 255) {
          _fail('invalid type for timestamp 96 extension (${_hex(t)})');
        }
        nsec = _reader.readUint32();
        sec = _reader.readInt64();
      default:
        _fail('invalid byte for timestamp extension (${_hex(b)})');
    }
    final usec = sec * 1000 * 1000 + nsec ~/ 1000;
    return DateTime.fromMicrosecondsSinceEpoch(usec, isUtc: true);
  }

  int getUint() {
    final b = _reader.readByte();
    if (b & 0x80 == 0) {
      return b;
    }
    return switch (b) {
      0xcc => _reader.readUint8(),
      0xcd => _reader.readUint16(),
      0xce => _reader.readUint32(),
      0xcf => _reader.readUint64(),
      _ => _fail('invalid byte for unsigned int (${_hex(b)})'),
    };
  }

  bool ifNil() {
    final b = _reader.peekByte();
    if (b != 0xc0) {
      return false;
    }
    _reader.readByte();
    return true;
  }

  final MsgPackReader _reader;

  Never _fail(String mesg) =>
      throw MsgPackException(mesg);

  String _hex(int b) =>
    '0x${b.toRadixString(16).padLeft(2, '0')}';

  final bool _isJS;
}