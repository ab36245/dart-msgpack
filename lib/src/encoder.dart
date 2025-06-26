import 'dart:convert' show utf8;
import 'dart:typed_data';

import 'exception.dart';
import 'platform.dart';
import 'sizes.dart';
import 'writer.dart';

class MsgPackEncoder {
  MsgPackEncoder([Uint8List? prefix]) {
    if (prefix != null) {
      _writer.writeBytes(prefix);
    }
  }

  Uint8List get bytes =>
    _writer.bytes;

  void putArrayLength(int v) {
    switch (v) {
      case < 0:
        _fail('array length ($v) negative');
      case < size4:
        _writer.writeByte(0x90 | v);
      case < size16:
        _writer.writeByte(0xdc);
        _writer.writeUint16(v);
      case < size32:
        _writer.writeByte(0xdd);
        _writer.writeUint32(v);
      default:
        _fail('array length ($v) too large');
    }
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
    final n = v.length;
    switch (n) {
      case < size8:
        _writer.writeByte(0xc4);
      case < size16:
        _writer.writeByte(0xc5);
      case < size32:
        _writer.writeByte(0xc6);
      default:
        _fail('bytes ($n bytes) is too long to encode');
    }
    _writer.writeBytes(v);
  }

  void putFloat(double v) {
    // TODO: work out if and when encoding a float32 is acceptable!
    _writer.writeByte(0xcb);
    _writer.writeFloat64(v);
  }

  void putInt(int v) {
    switch (v) {
      case >= -size5 && < size7:
        _writer.writeInt8(v);
      case >= -size8 && < size8:
        _writer.writeByte(0xd0);
        _writer.writeInt8(v);
      case >= -size16 && < size16:
        _writer.writeByte(0xd1);
        _writer.writeInt16(v);
      case >= -size32 && < size32:
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
      case < size4:
        _writer.writeByte(0x80 | v);
      case < size16:
        _writer.writeByte(0xde);
        _writer.writeUint16(v);
      case < size32:
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
      case < size5:
        _writer.writeByte(0xa0 | n);
      case < size8:
        _writer.writeByte(0xd9);
        _writer.writeUint8(n);
      case < size16:
        _writer.writeByte(0xda);
        _writer.writeUint16(n);
      case < size32:
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

    if (sec < 0 || sec >= size34) {
      //timestamp 96
      _writer.writeByte(0xc7);
      _writer.writeByte(12);
      _writer.writeByte(-1);
      _writer.writeUint32(nsec);
      _writer.writeInt64(sec);
    } else if (sec >= size32 || nsec > 0) {
      //timestamp 64
      _writer.writeByte(0xd7);
      _writer.writeByte(-1);
      int data64;
      if (kIsWeb) {
        // Because JavaScript can't handle 64-bit bitwise operations!
        data64 = nsec * size34 + sec;
      } else {
        data64 = nsec << 34 | sec;
      }
      _writer.writeUint64(data64);
    } else {
      // timestamp 32
      _writer.writeByte(0xd6);
      _writer.writeByte(-1);
      _writer.writeInt32(sec);
    }
  }

  void putUint(int v) {
    switch (v) {
      case < 0:
        _fail('array length ($v) negative');
      case < size7:
        _writer.writeByte(v);
      case < size8:
        _writer.writeByte(0xcc);
        _writer.writeUint8(v);
      case < size16:
        _writer.writeByte(0xcd);
        _writer.writeUint16(v);
      case < size32:
        _writer.writeByte(0xcc);
        _writer.writeUint32(v);
      default:
        _writer.writeByte(0xcd);
        _writer.writeUint64(v);
    }
  }

  @override
  String toString() =>
    _writer.toString();

  final _writer = MsgPackWriter();

  Never _fail(String mesg) =>
      throw MsgPackException(mesg);
}
