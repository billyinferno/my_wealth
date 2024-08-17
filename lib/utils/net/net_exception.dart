import 'package:my_wealth/_index.g.dart';

class NetException {
  final int code;
  final NetType type;
  final String message;
  final String? body;

  const NetException({required this.code, required this.type, required this.message, this.body});

  @override
  String toString() {
    return '[$type][$code] $message';
  }

  ErrorModel? error() {
    // check if body is not null
    if (body != null) {
      return parseError(body!);
    }

    // return null if body is null
    return null;
  }
}