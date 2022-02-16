import 'package:flutter/foundation.dart';

class StepperSelectorController extends ChangeNotifier {
  int? value = -1;

  void changeValue(int newValue) {
    value = newValue;
    notifyListeners();
  }
}