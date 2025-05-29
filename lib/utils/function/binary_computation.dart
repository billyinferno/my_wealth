class Bit {
  int _value = 0;
  List<String> _binArr = [];

  // create a constructor where we can assign a value if needed
  // and if not assigned, it will be defaulted  to 0.
  Bit({int? value}) {
    if (value != null) {
      set(value);
    }
    else {
      // defauled to zero
      set(0);
    }
  }

  void set(int value) {
    _value = value;

    String binStr = _value.toRadixString(2).padLeft(16, '0');
    _binArr = List<String>.generate(binStr.length, (index) {
      return binStr[index];
    });
  }

  bool operator [](int index) {
    assert(index >= 0 && index <= 15, "Bit position should be between 0-15");

    // check if the value is odd after shr, if odd, it means that the bit is enabled
    return (int.tryParse(_binArr[index])! == 0 ? false : true);
  }

  void operator []=(int index, int value) {
    assert(index >= 0 && index <= 15, "Bit position should be between 0-15");
    assert(value == 0 || value == 1, "Bit value should be 0 or 1");

    // set the binary array with the value passed
    _binArr[index] = value.toString();
  }

  int toInt() {
    String binStr = _binArr.join();
    
    // convert from binary to int
    return int.parse(binStr, radix: 2);
  }
}