import 'dart:typed_data';

import 'exception.dart';
import 'platform.dart';
import 'sizes.dart';

class MsgPackReader {
  MsgPackReader(this._bytes);

  Uint8List get bytes =>
    _bytes.sublist(_index);

  int peekByte() =>
    _peek(1, (i) => _bytes[i]);

  int readByte() =>
    _read(1, (i) => _bytes[i]);

  Uint8List readBytes(int n) =>
    _read(n, (i) => _bytes.sublist(i, i + n));

  double readFloat32() =>
    _read(4, _view.getFloat32);

  double readFloat64() =>
    _read(8, _view.getFloat64);

  int readInt8() =>
    _read(1, _view.getInt8);

  int readInt16() =>
    _read(2, _view.getInt16);

  int readInt32() =>
    _read(4, _view.getInt32);

  int readInt64() {
    if (isJS) {
      // Because JavaScript can't handle 64-bit bitwise operations!
      final be = _read(4, _view.getInt32);
      final le = _read(4, _view.getUint32);
      return be * size32 + le;
    }
    return _read(8, _view.getInt64);
  }

  int readUint8() =>
    _read(1, _view.getUint8);

  int readUint16() =>
    _read(2, _view.getUint16);

  int readUint32() =>
    _read(4, _view.getUint32);

  int readUint64() {
    if (isJS) {
      // Because JavaScript can't handle 64-bit bitwise operations!
      final be = _read(4, _view.getUint32);
      final le = _read(4, _view.getUint32);
      return be * size32 + le;
    }
    return _read(8, _view.getUint64);
  }


  final Uint8List _bytes;
  var _index = 0;
  late final _length = _bytes.length;
  late final _view = ByteData.sublistView(_bytes);

  T _peek<T>(int size, T Function(int) f) {
    int excess = _index + size - _length;
    if (excess > 0) {
      throw MsgPackException('trying to read $excess bytes beyond end of buffer ($_length bytes)');
    }
    final value = f(_index);
    return value;
  }

  T _read<T>(int size, T Function(int) f) {
    final value = _peek(size, f);
    _index += size;
    return value;
  }
}
