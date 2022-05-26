import 'dart:convert';

import 'package:my_wealth/model/error_model.dart';

ErrorModel parseError(String body) {
  ErrorModel err = ErrorModel.fromJson(jsonDecode(body));
  return err;
}