import 'dart:typed_data';

import 'extensions.dart';
import 'platform.dart';
import 'sizes.dart';

class MsgPackWriter {
  Uint8List get bytes =>
    _builder.takeBytes();

  void writeByte(int v) {
    _builder.addByte(v);
  }

  void writeBytes(Uint8List v) {
    _builder.add(v);
  }

  void writeFloat32(double v) {
    _view.setFloat32(0, v);
    _copy(4);
  }

  void writeFloat64(double v) {
    _view.setFloat64(0, v);
    _copy(8);
  }

  void writeInt8(int v) {
    _view.setInt8(0, v);
    _copy(1);
  }

  void writeInt16(int v) {
    _view.setInt16(0, v);
    _copy(2);
  }

  void writeInt32(int v) {
    _view.setInt32(0, v);
    _copy(4);
  }

  void writeInt64(int v) {
    if (kIsWeb) {
      // Because JavaScript can't handle 64-bit bitwise operations!
      var be = v ~/ size32;
      if (v < 0) {
        be--;
      }
      final le = v % size32;
      _view.setInt32(0, be);
      _view.setInt32(4, le);
    } else {
      _view.setInt64(0, v);
    }
    _copy(8);
  }

  void writeUint8(int v) {
    _view.setUint8(0, v);
    _copy(1);
  }

  void writeUint16(int v) {
    _view.setUint16(0, v);
    _copy(2);
  }

  void writeUint32(int v) {
    _view.setUint32(0, v);
    _copy(4);
  }

  void writeUint64(int v) {
    if (kIsWeb) {
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

  @override
  String toString() =>
    _builder.toBytes().dump();

  final _buffer = Uint8List(8);
  final _builder = BytesBuilder();
  late final _view = ByteData.sublistView(_buffer);

  void _copy(int size) {
    _builder.add(_buffer.sublist(0, size));
  }
}

