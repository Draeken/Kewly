import 'dart:collection';
import 'dart:convert';
import 'package:flutter/widgets.dart';

class Composition {
  final int ingredientId;
  final int quantity;

  Composition({this.ingredientId, this.quantity});

  factory Composition.fromJson(Map<String, dynamic> json) {
    return Composition(
        ingredientId: json['ingredientId'] as int,
        quantity: json['quantity'] as int);
  }
}

class Product {
  final int id;
  final String name;
  final List<Composition> composition;

  Product({this.id, this.name, this.composition});

  factory Product.fromJson(Map<String, dynamic> json) {
    final List<Composition> composition = (json['composition'] as List<dynamic>)
        .map((rawCompo) => Composition.fromJson(rawCompo))
        .toList(growable: false);
    return Product(
        id: json['id'] as int,
        name: json['name'] as String,
        composition: composition);
  }
}

class Graph {
  final List<Product> products;

  Graph({this.products});

  factory Graph.fromJson(Map<String, dynamic> json) {
    final List<Product> products = (json['products'] as List<dynamic>)
        .map((productRaw) => Product.fromJson(productRaw))
        .toList(growable: false);
    return Graph(products: products);
  }
}

class AppModel extends ChangeNotifier {
  Graph _graph;

  AppModel(BuildContext context) {
    _loadGraph(context);
  }

  UnmodifiableListView<Product> get products =>
      UnmodifiableListView(_graph?.products ?? []);

  void _loadGraph(BuildContext context) async {
    final graph = await DefaultAssetBundle.of(context)
        .loadStructuredData('assets/graph.json', (s) async => json.decode(s));
    _graph = Graph.fromJson(graph);
    notifyListeners();
  }
}
