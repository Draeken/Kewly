import 'dart:collection';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:kewly/util.dart';

class Composition {
  final int ingredientId;
  final int quantity;

  Composition({this.ingredientId, this.quantity});

  static Composition fromJson(Map<String, dynamic> json) {
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

  static Product fromJson(Map<String, dynamic> json) {
    final List<Composition> composition =
        mapJsonToList(json['composition'], Composition.fromJson);
    return Product(
        id: json['id'] as int,
        name: json['name'] as String,
        composition: composition);
  }
}

class Ingredient {
  final int id;
  final String name;

  Ingredient({this.id, this.name});

  static Ingredient fromJson(Map<String, dynamic> json) {
    return Ingredient(name: json['name'] as String, id: json['id'] as int);
  }
}

class Graph {
  final List<Product> products;
  final List<Ingredient> ingredients;

  Graph({this.products, this.ingredients});

  factory Graph.fromJson(Map<String, dynamic> json) {
    final List<Product> products =
        mapJsonToList(json['products'], Product.fromJson);
    final List<Ingredient> ingredients =
        mapJsonToList(json['ingredients'], Ingredient.fromJson);
    return Graph(products: products, ingredients: ingredients);
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
