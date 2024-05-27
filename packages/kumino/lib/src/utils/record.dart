extension BinaryTupleExtension<A, B> on (A, B) {
  A get first => $1;

  B get second => $2;

  MapEntry<A, B> toMapEntry() => MapEntry($1, $2);
}
