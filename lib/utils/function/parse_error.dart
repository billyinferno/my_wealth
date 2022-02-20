import 'dart:convert';

import 'package:my_wealth/model/error_model.dart';

ErrorModel parseError(String body) {
  ErrorModel _err = ErrorModel.fromJson(jsonDecode(body));
  return _err;
}