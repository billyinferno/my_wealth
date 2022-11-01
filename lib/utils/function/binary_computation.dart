class Bit {
  int _value = 0;

  void set(int value) {
    _value = value;
  }

  bool operator [](int index) {
    assert(index < 0 || index > 15, "Bit position should be between 0-15");

    // check if the value is odd after shr, if odd, it means that the bit is enabled
    return ((_value >> index) % 2 == 0 ? false : true);
  }

  operator []=(int index, int value) {
    assert(index < 0 || index > 15, "Bit position should be between 0-15");
    assert(value != 0 && value != 1, "Bit value should be 0 or 1");

    // check whether we want to set the value or else
    if (value == 1) {
      // do the or of the shl 1 of idx
      _value |= (1 << index);
    }
    else {
      // this is setting up the bit to 0
      _value &= ~(1 << index);
    }
  }

  int toInt() {
    return _value;
  }
}