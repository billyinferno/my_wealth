int bit({required int data, required int pos, required int value}) {
  // value should be 0 - 1
  if (value != 0 && value != 1) {
    throw Exception("Binary value should be 0 or 1 only");
  }

  // for int, pos should be between 0-15
  if (pos < 0 || pos > 15) {
    throw Exception("Bit position should be between 0-15");
  }

  // now convert the data from int to binary string
  String binStr = data.toRadixString(2).padLeft(16, '0');
  // print(binStr);

  // once we got the binary string, then we can manipulate the pos
  List<String> binArr = List<String>.generate(binStr.length, (index) {
    // print("$index => ${binStr[index]}");
    return binStr[index];
  });
  binArr[pos] = value.toString();

  // now join the binary arr back to binStr
  binStr = binArr.join();
  // print(binStr);

  // convert from binary to int
  return int.parse(binStr, radix: 2);
}