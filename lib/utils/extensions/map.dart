extension ExtendedMapExtension<K, V> on Map<K, V> {
  Map<K, V> reverse() {
    final reversedKeys = keys.toList(growable: false).reversed;
    var reversedMap = {};
    for(dynamic key in reversedKeys) {
      reversedMap[key] = this[key];
    }

    return reversedMap.cast<K, V>();
  }
}