import 'decoder.dart';
import 'encoder.dart';

class MsgPackCodec<T> {
  MsgPackCodec({
    required this.decode,
    required this.encode,
  });

  final T Function(MsgPackDecoder) decode;
  final void Function(MsgPackEncoder, T) encode;
}