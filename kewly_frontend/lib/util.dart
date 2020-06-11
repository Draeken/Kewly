import 'dart:typed_data';

import 'package:flutter/rendering.dart';

Iterable<T> mapJsonToList<T>(
    List<dynamic> rawList, T factory(Map<String, dynamic> data),{ toList = true, growable = false }) {
  if (rawList == null) {
    return const [];
  }
  var mapped = rawList
      .map((productRaw) => factory(productRaw));
  return toList ? mapped.toList(growable: growable) : mapped;
}

bool containsIgnoreCase(String string1, String string2) {
  return string1?.toLowerCase()?.contains(string2?.toLowerCase());
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

typedef R Func1<A, R>(A a);
typedef R Func2<A, B, R>(A a, B b);

/// Checks 1 argument for equality with [identical] call and returns the cached
/// result if it was not changed.
Func1<A, R> imemo1<A, R>(Func1<A, R> func) {
  A prevArg;
  R prevResult;
  bool isInitial = true;

  return ((A arg) {
    if (!isInitial && identical(arg, prevArg)) {
      return prevResult;
    } else {
      prevArg = arg;
      prevResult = func(arg);
      isInitial = false;

      return prevResult;
    }
  });
}

/// Checks 2 arguments for equality with [identical] call and returns the cached
/// result if they were not changed.
Func2<A, B, R> imemo2<A, B, R>(Func2<A, B, R> func) {
  A prevArgA;
  B prevArgB;
  R prevResult;
  bool isInitial = true;

  return ((A argA, B argB) {
    if (!isInitial && identical(argA, prevArgA) && identical(argB, prevArgB)) {
      return prevResult;
    } else {
      prevArgA = argA;
      prevArgB = argB;
      prevResult = func(argA, argB);
      isInitial = false;

      return prevResult;
    }
  });
}