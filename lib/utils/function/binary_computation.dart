import 'dart:math';

class Bit {
  int? _value;

  void set(int value) {
    _value = value;
  }

  bool operator [](int index) {
    if (_value == null) {
      throw Exception("Value not being set yet");
    }

    if (index < 0 || index > 15) {
      throw Exception("Bit position should be between 0-15");
    }

    // to check the bit we can just perform right shift index
    int tmp = _value! >> index;

    // check if tmp is odd, if odd, it means that the bit is enabled
    return (tmp % 2 == 0 ? false : true);
  }

  operator []=(int index, int value) {
    if (_value == null) {
      throw Exception("Value not being set yet");
    }

    if (index < 0 || index > 15) {
      throw Exception("Bit position should be between 0-15");
    }

    if (value != 0 && value != 1) {
      throw Exception("Bit value should be 0 or 1");
    }

    // check whether we want to set the value or else
    if (value == 1) {
      // this is easy, we can just do operator |
      int powVal = pow(2, index) as int;
      _value = _value! | powVal;
    }
    else {
      // this is setting up the bit to 0, so now check if this bit is being
      // enabled or not first
      int tmp = _value! >> index;

      // if odd, then it means the bit is being setup
      if (tmp % 2 == 1) {
        // subtract the _value with the powVal
        int powVal = pow(2, index) as int;
        _value = _value! - powVal;
      }
    }
  }

  int toInt() {
    if (_value == null) {
      throw Exception("Value not being set yet");
    }

    return _value!;
  }
}