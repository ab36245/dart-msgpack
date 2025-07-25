import 'dart:convert' show utf8;
import 'dart:typed_data';

import 'exception.dart';
import 'platform.dart';
import 'sizes.dart';
import 'writer.dart';

class MsgPackEncoder {
  MsgPackEncoder({
    Uint8List? prefix,
  }) :
    _writer = MsgPackWriter()
  {
    if (prefix != null) {
      _writer.writeBytes(prefix);
    }
  }

  Uint8List get bytes =>
    _writer.bytes;

  String asString([int? maxLength]) {
    final subset = maxLength == null ? bytes : bytes.take(maxLength);
    return subset.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
  }

  void clear() =>
    _writer.clear();

  void putArrayLength(int v) {
    switch (v) {
      case < 0:
        _fail('array length ($v) negative');
      case <= mask4:
        _writer.writeByte(0x90 | v);
      case <= mask16:
        _writer.writeByte(0xdc);
        _writer.writeUint16(v);
      case <= mask32:
        _writer.writeByte(0xdd);
        _writer.writeUint32(v);
      default:
        _fail('array length ($v) too large');
    }
  }

  void putBinary(Uint8List v) {
    final n = v.length;
    switch (n) {
      case <= mask8:
        _writer.writeByte(0xc4);
        _writer.writeUint8(n);
      case <= mask16:
        _writer.writeByte(0xc5);
        _writer.writeUint16(n);
      case <= mask32:
        _writer.writeByte(0xc6);
        _writer.writeUint32(n);
      default:
        _fail('byte list ($n bytes) is too long to encode');
    }
    _writer.writeBytes(v);
  }

  void putBool(bool v) {
    switch (v) {
      case false:
        _writer.writeByte(0xc2);
      case true:
        _writer.writeByte(0xc3);
    }
  }

  void putBytes(Uint8List v) {
    _writer.writeBytes(v);
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
        _writer.writeByte(0xd4);
        _writer.writeUint8(typ);
        _writer.writeUint8(v);
      case <= mask16:
        _writer.writeByte(0xd5);
        _writer.writeUint8(typ);
        _writer.writeUint16(v);
      case <= mask32:
        _writer.writeByte(0xd6);
        _writer.writeUint8(typ);
        _writer.writeUint32(v);
      default:
        _writer.writeByte(0xd7);
        _writer.writeUint8(typ);
        _writer.writeUint64(v);
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
    _writer.writeByte(0xca);
    _writer.writeFloat32(v);
  }

  void putFloat64(double v) {
    _writer.writeByte(0xcb);
    _writer.writeFloat64(v);
  }

  void putInt(int v) {
    switch (v) {
      case >= intFixMin && <= intFixMax:
        _writer.writeInt8(v);
      case >= int8Min && <= int8Max:
        _writer.writeByte(0xd0);
        _writer.writeInt8(v);
      case >= int16Min && <= int16Max:
        _writer.writeByte(0xd1);
        _writer.writeInt16(v);
      case >= int32Min && <= int32Max:
        _writer.writeByte(0xd2);
        _writer.writeInt32(v);
      default:
        _writer.writeByte(0xd3);
        _writer.writeInt64(v);
    }
  }

  void putMapLength(int v) {
    switch (v) {
      case < 0:
        _fail('map length ($v) negative');
      case <= mask4:
        _writer.writeByte(0x80 | v);
      case <= mask16:
        _writer.writeByte(0xde);
        _writer.writeUint16(v);
      case <= mask32:
        _writer.writeByte(0xdf);
        _writer.writeUint32(v);
      default:
        _fail('map length ($v) too large');
    }
  }

  void putNil() {
    _writer.writeByte(0xc0);
  }

  void putString(String v) {
    final u = utf8.encode(v);
    final n = u.length;
    switch (n) {
      case <= mask5:
        _writer.writeByte(0xa0 | n);
      case <= mask8:
        _writer.writeByte(0xd9);
        _writer.writeUint8(n);
      case <= mask16:
        _writer.writeByte(0xda);
        _writer.writeUint16(n);
      case <= mask32:
        _writer.writeByte(0xdb);
        _writer.writeUint32(n);
      default:
        _fail('string ($n bytes) is too long to encode');
    }
    _writer.writeBytes(u);
  }

  void putTime(DateTime v) {
    final sec = v.millisecondsSinceEpoch ~/ 1000;
    final msec = v.millisecond;
    final usec = v.microsecond;
    final nsec = msec * 1000 * 1000 + usec * 1000;

    if (sec < 0 || sec > mask34) {
      //timestamp 96
      _writer.writeByte(0xc7);
      _writer.writeByte(12);
      _writer.writeByte(0xff);
      _writer.writeUint32(nsec);
      _writer.writeInt64(sec);
    } else if (sec > mask32 || nsec > 0) {
      //timestamp 64
      _writer.writeByte(0xd7);
      _writer.writeByte(0xff);
      int data64;
      if (isJS) {
        // Because JavaScript can't handle 64-bit bitwise operations!
        data64 = nsec * (mask34 + 1) + sec;
      } else {
        data64 = nsec << 34 | sec;
      }
      _writer.writeUint64(data64);
    } else {
      // timestamp 32
      _writer.writeByte(0xd6);
      _writer.writeByte(0xff);
      _writer.writeInt32(sec);
    }
  }

  void putUint(int v) {
    switch (v) {
      case < 0:
        _fail('uint ($v) negative');
      case <= mask7:
        _writer.writeByte(v);
      case <= mask8:
        _writer.writeByte(0xcc);
        _writer.writeUint8(v);
      case <= mask16:
        _writer.writeByte(0xcd);
        _writer.writeUint16(v);
      case <= mask32:
        _writer.writeByte(0xce);
        _writer.writeUint32(v);
      default:
        _writer.writeByte(0xcf);
        _writer.writeUint64(v);
    }
  }

  @override
  String toString() =>
    _writer.toString();

  final MsgPackWriter _writer;

  Never _fail(String mesg) =>
      throw MsgPackException(mesg);
}
