List<T> mapJsonToList<T>(
    List<dynamic> rawList, T factory(Map<String, dynamic> data)) {
  return rawList
      .map((productRaw) => factory(productRaw))
      .toList(growable: false);
}
