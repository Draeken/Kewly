import 'dart:typed_data';

import 'package:flutter/rendering.dart';

Iterable<T> mapJsonToList<T>(
    List<dynamic> rawList, T factory(Map<String, dynamic> data),{ toList = true }) {
  var mapped = rawList
      .map((productRaw) => factory(productRaw));
  return toList ? mapped.toList(growable: false) : mapped;
}

bool containsIgnoreCase(String string1, String string2) {
  return string1?.toLowerCase().contains(string2?.toLowerCase());
}

class Mtransform {
  static Float64List scale(double factor) {
    final matrix = Matrix4.identity()
      ..[0] = factor
      ..[5] = factor;
    return matrix.storage;
  }

  static final Float64List mirrorX = (Matrix4.identity()..[0] = -1).storage;
}