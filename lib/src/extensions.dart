import 'dart:typed_data';

extension DumpExtension on Uint8List {
  String dump() {
    var o = 0;
    var s = '$length bytes';
    for (final b in this) {
      if (o % 16 == 0) {
        s += '\n    ${o.toRadixString(10).padLeft(4, '0')}';
      }
      s += ' ${b.toRadixString(16).padLeft(2, '0')}';
      o++;
    }
    return s;
  }
}