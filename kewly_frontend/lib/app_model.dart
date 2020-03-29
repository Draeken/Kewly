import 'dart:collection';
import 'dart:convert';
import 'package:flutter/widgets.dart';

import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;

class Composition {
  final int ingredientId;
  final int quantity;

  Composition({ this.ingredientId, this.quantity });

  factory Composition.fromJson(Map<String, dynamic> json) {
    return Composition(
      ingredientId: json['ingredientId'] as int,
      quantity: json['quantity'] as int
    );
  }
}

class Product {
  final int id;
  final String name;
  final List<Composition> composition;

  Product({this.id, this.name, this.composition });

  factory Product.fromJson(Map<String, dynamic> json) {
    final composition = json['composition'] as List<Map<String, dynamic>>;
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      composition: composition.map((rawCompo) => Composition.fromJson(rawCompo)).toList(growable: false)
    );
  }
}

Future<String> loadGraph() async {
  return await rootBundle.loadStructuredData(
      'assets/graph.json', (s) async => json.decode(s));
}

class AppModel extends ChangeNotifier {
  final List<Product> _products = [];

  UnmodifiableListView<Product> get products => UnmodifiableListView(_products);
}
