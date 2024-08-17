import 'dart:convert';

import 'package:my_wealth/_index.g.dart';

ErrorModel parseError(String body) {
  ErrorModel err = ErrorModel.fromJson(jsonDecode(body));
  return err;
}