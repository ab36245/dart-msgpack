import 'dart:convert' show utf8;
import 'dart:typed_data';

import 'exception.dart';
import 'platform.dart';
import 'sizes.dart';

class MsgPackEncoder {
  MsgPackEncoder({
    Uint8List? prefix,
  })
  {
    if (prefix != null) {
      _writeBytes(prefix);
    }
  }

  Uint8List get bytes =>
    _builder.toBytes();

  String asString([int? maxLength]) {
    final subset = maxLength == null ? bytes : bytes.take(maxLength);
    return subset.map(_hex).join(' ');
  }

  void clear() {
    _builder.clear();
  }

  void putArrayLength(int v) {
    switch (v) {
      case < 0:
        _fail('array length ($v) negative');
      case <= mask4:
        _writeByte(0x90 | v);
      case <= mask16:
        _writeByte(0xdc);
        _writeUint16(v);
      case <= mask32:
        _writeByte(0xdd);
        _writeUint32(v);
      default:
        _fail('array length ($v) too large');
    }
  }

  void putBinary(Uint8List v) {
    final n = v.length;
    switch (n) {
      case <= mask8:
        _writeByte(0xc4);
        _writeUint8(n);
      case <= mask16:
        _writeByte(0xc5);
        _writeUint16(n);
      case <= mask32:
        _writeByte(0xc6);
        _writeUint32(n);
      default:
        _fail('byte list ($n bytes) is too long to encode');
    }
    _writeBytes(v);
  }

  void putBool(bool v) {
    switch (v) {
      case false:
        _writeByte(0xc2);
      case true:
        _writeByte(0xc3);
    }
  }

  void putBytes(Uint8List v) {
    _writeBytes(v);
  }

  void putExtUint(int typ, int v) {
    if (typ < 0) {
      _fail('ext type ($typ) is reserved');
    }
    if (typ > mask8) {
      _fail('ext type ($typ) is too large to encode');
    }
    switch (v) {
      case < 0:
        _fail('ext uint ($v) negative');
      case <= mask8:
        _writeByte(0xd4);
        _writeUint8(typ);
        _writeUint8(v);
      case <= mask16:
        _writeByte(0xd5);
        _writeUint8(typ);
        _writeUint16(v);
      case <= mask32:
        _writeByte(0xd6);
        _writeUint8(typ);
        _writeUint32(v);
      default:
        _writeByte(0xd7);
        _writeUint8(typ);
        _writeUint64(v);
    }
  }

  void putFloat(double v) {
    // Try to work out if encoding a single-precision IEEE754 value
    // is acceptable
    final ieee754 = ByteData(8);
    ieee754.setFloat64(0, v);

    // ...check if the exponent is inside the range for single-precision

    final biasedExp = (ieee754.getUint16(0) >> 4) & 0x7ff;
    final unbiasedExp = biasedExp - 1023;
    if (unbiasedExp < -128 || unbiasedExp > 127) {
      // nope!
      putFloat64(v);
      return;
    }

    // ...check if the least significant bits of the mantissa are zero
    final leastSignificantBits = ieee754.getUint32(4) & ((1 << 29) - 1);
    if (leastSignificantBits != 0) {
      // nope!
      putFloat64(v);
      return;
    }
    
    // ...it looks ok to only encode a single-precision (32 bit) version
    putFloat32(v);
  }

  void putFloat32(double v) {
    _writeByte(0xca);
    _writeFloat32(v);
  }

  void putFloat64(double v) {
    _writeByte(0xcb);
    _writeFloat64(v);
  }

  void putInt(int v) {
    switch (v) {
      case >= intFixMin && <= intFixMax:
        _writeInt8(v);
      case >= int8Min && <= int8Max:
        _writeByte(0xd0);
        _writeInt8(v);
      case >= int16Min && <= int16Max:
        _writeByte(0xd1);
        _writeInt16(v);
      case >= int32Min && <= int32Max:
        _writeByte(0xd2);
        _writeInt32(v);
      default:
        _writeByte(0xd3);
        _writeInt64(v);
    }
  }

  void putMapLength(int v) {
    switch (v) {
      case < 0:
        _fail('map length ($v) negative');
      case <= mask4:
        _writeByte(0x80 | v);
      case <= mask16:
        _writeByte(0xde);
        _writeUint16(v);
      case <= mask32:
        _writeByte(0xdf);
        _writeUint32(v);
      default:
        _fail('map length ($v) too large');
    }
  }

  void putNil() {
    _writeByte(0xc0);
  }

  void putString(String v) {
    final u = utf8.encode(v);
    final n = u.length;
    switch (n) {
      case <= mask5:
        _writeByte(0xa0 | n);
      case <= mask8:
        _writeByte(0xd9);
        _writeUint8(n);
      case <= mask16:
        _writeByte(0xda);
        _writeUint16(n);
      case <= mask32:
        _writeByte(0xdb);
        _writeUint32(n);
      default:
        _fail('string ($n bytes) is too long to encode');
    }
    _writeBytes(u);
  }

  void putTime(DateTime v) {
    final sec = v.millisecondsSinceEpoch ~/ 1000;
    final msec = v.millisecond;
    final usec = v.microsecond;
    final nsec = msec * 1000 * 1000 + usec * 1000;

    if (sec < 0 || sec > mask34) {
      //timestamp 96
      _writeByte(0xc7);
      _writeByte(12);
      _writeByte(0xff);
      _writeUint32(nsec);
      _writeInt64(sec);
    } else if (sec > mask32 || nsec > 0) {
      //timestamp 64
      _writeByte(0xd7);
      _writeByte(0xff);
      int data64;
      if (isJS) {
        // Because JavaScript can't handle 64-bit bitwise operations!
        data64 = nsec * (mask34 + 1) + sec;
      } else {
        data64 = nsec << 34 | sec;
      }
      _writeUint64(data64);
    } else {
      // timestamp 32
      _writeByte(0xd6);
      _writeByte(0xff);
      _writeInt32(sec);
    }
  }

  void putUint(int v) {
    switch (v) {
      case < 0:
        _fail('uint ($v) negative');
      case <= mask7:
        _writeByte(v);
      case <= mask8:
        _writeByte(0xcc);
        _writeUint8(v);
      case <= mask16:
        _writeByte(0xcd);
        _writeUint16(v);
      case <= mask32:
        _writeByte(0xce);
        _writeUint32(v);
      default:
        _writeByte(0xcf);
        _writeUint64(v);
    }
  }

  final _buffer = Uint8List(8);

  final _builder = BytesBuilder();

  late final _view = ByteData.sublistView(_buffer);

  void _copy(int size) {
    _builder.add(_buffer.sublist(0, size));
  }

  void _writeByte(int v) {
    _builder.addByte(v);
  }

  void _writeBytes(Uint8List v) {
    _builder.add(v);
  }

  void _writeFloat32(double v) {
    _view.setFloat32(0, v);
    _copy(4);
  }

  void _writeFloat64(double v) {
    _view.setFloat64(0, v);
    _copy(8);
  }

  void _writeInt8(int v) {
    _view.setInt8(0, v);
    _copy(1);
  }

  void _writeInt16(int v) {
    _view.setInt16(0, v);
    _copy(2);
  }

  void _writeInt32(int v) {
    _view.setInt32(0, v);
    _copy(4);
  }

  void _writeInt64(int v) {
    if (isJS) {
      // Because JavaScript can't handle 64-bit bitwise operations!
      var be = v ~/ size32;
      if (v < 0) {
        be--;
      }
      final le = v % size32;
      _view.setInt32(0, be);
      _view.setUint32(4, le);
    } else {
      _view.setInt64(0, v);
    }
    _copy(8);
  }

  void _writeUint8(int v) {
    _view.setUint8(0, v);
    _copy(1);
  }

  void _writeUint16(int v) {
    _view.setUint16(0, v);
    _copy(2);
  }

  void _writeUint32(int v) {
    _view.setUint32(0, v);
    _copy(4);
  }

  void _writeUint64(int v) {
    if (isJS) {
      // Because JavaScript can't handle 64-bit bitwise operations!
      var be = v ~/ size32;
      if (v < 0) {
        be--;
      }
      final le = v % size32;
      _view.setUint32(0, be);
      _view.setUint32(4, le);
    } else {
      _view.setUint64(0, v);
    }
    _copy(8);
  }
}

Never _fail(String mesg) =>
  throw MsgPackException(mesg);

String _hex(int b) =>
  b.toRadixString(16).padLeft(2, '0');