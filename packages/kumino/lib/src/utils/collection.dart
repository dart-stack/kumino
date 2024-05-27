extension IterableMapEntryExtension<K, V> on Iterable<MapEntry<K, V>> {
  Map<K, V> toMap() => Map.fromEntries(this);
}

extension AnyMapEntryExtension<K, V> on MapEntry<K, V> {
  MapEntry<RK, RV> cast<RK, RV>() => MapEntry(key as RK, value as RV);
}
