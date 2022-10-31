class Bit {
  int _value = 0;
  List<String> _binArr = [];

  void set(int value) {
    _value = value;

    String binStr = _value.toRadixString(2).padLeft(16, '0');
    _binArr = List<String>.generate(binStr.length, (index) {
      return binStr[index];
    });
  }

  bool operator [](int index) {
    if (index < 0 || index > 15) {
      throw Exception("Bit position should be between 0-15");
    }

    return (int.tryParse(_binArr[index])! == 0 ? false : true);
  }

  operator []=(int index, int value) {
    if (index < 0 || index > 15) {
      throw Exception("Bit position should be between 0-15");
    }

    _binArr[index] = value.toString();
  }

  int toInt() {
    String binStr = _binArr.join();
    
    // convert from binary to int
    return int.parse(binStr, radix: 2);
  }
}
