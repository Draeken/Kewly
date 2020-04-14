Iterable<T> mapJsonToList<T>(
    List<dynamic> rawList, T factory(Map<String, dynamic> data),{ toList = true }) {
  var mapped = rawList
      .map((productRaw) => factory(productRaw));
  return toList ? mapped.toList(growable: false) : mapped;
}

bool containsIgnoreCase(String string1, String string2) {
  return string1?.toLowerCase().contains(string2?.toLowerCase());
}