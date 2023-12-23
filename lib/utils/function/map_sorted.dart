Map<K, V> sortedMap<K, V>({required Map<K, V> data, String? type}) {
  Map<K, V> sorted = {};
  
  String sortType = (type ?? 'asc');
  sortType = sortType.toLowerCase();

  List<K> sortedKeys = data.keys.toList()..sort();
  
  // check sort type
  if (sortType == 'desc') {
    sortedKeys = sortedKeys.reversed.toList();
  }

  // loop thru the sorted keys, and create the sorted map
  for (var keys in sortedKeys) {
    sorted[keys] = data[keys] as V;
  }

  // return sorted map
  return sorted;
}