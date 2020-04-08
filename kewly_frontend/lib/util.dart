List<T> mapJsonToList<T>(
    List<dynamic> rawList, T factory(Map<String, dynamic> data)) {
  return rawList
      .map((productRaw) => factory(productRaw))
      .toList(growable: false);
}

bool containsIgnoreCase(String string1, String string2) {
  return string1?.toLowerCase().contains(string2?.toLowerCase());
}