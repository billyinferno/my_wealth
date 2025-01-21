Map<K, V> assignEmptyMap<K, V, T>(T? data, Map<K, V> assigned) {
  if (data == null) {
    return <K, V>{};
  }
  else {
    return assigned;
  }
}