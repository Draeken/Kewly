import 'dart:collection';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:kewly/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class UserReview {
  final int productId;
  final double rating;

  UserReview({this.productId, this.rating});

  static UserReview fromJson(Map<String, dynamic> json) {
    return UserReview(productId: json['productId'], rating: json['rating']);
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'rating': rating
    };
  }
}

class UserData {
  final List<int> ownedIngredients;
  final List<int> productsToPurchase;
  final List<int> ingredientsToPurchase;
  final List<int> nextToTest;
  final List<int> historic;
  final List<UserReview> reviewedProducts;

  UserData(
      {this.historic,
      this.ingredientsToPurchase,
      this.nextToTest,
      this.ownedIngredients,
      this.productsToPurchase,
      this.reviewedProducts});

  factory UserData.fromJson(Map<String, dynamic> json) {
    if (json['ownedIngredients'] == null) {
      return UserData.empty();
    }
    final List<UserReview> reviewedProducts =
        mapJsonToList(json['reviewedProducts'], UserReview.fromJson);
    return UserData(
        historic: List<int>.from(json['historic']),
        ingredientsToPurchase: List<int>.from(json['ingredientsToPurchase']),
        nextToTest: List<int>.from(json['nextToTest']),
        ownedIngredients: List<int>.from(json['ownedIngredients']),
        productsToPurchase: List<int>.from(json['productsToPurchase']),
        reviewedProducts: reviewedProducts);
  }

  factory UserData.empty() {
    return UserData(
        historic: [],
        ingredientsToPurchase: [],
        nextToTest: [],
        ownedIngredients: [],
        productsToPurchase: [],
        reviewedProducts: []);
  }

  Map<String, dynamic> toJson() {
    return {
      'historic': historic,
      'ingredientsToPurchase': ingredientsToPurchase,
      'nextToTest': nextToTest,
      'ownedIngredients': ownedIngredients,
      'productsToPurchase': productsToPurchase,
      'reviewedProducts': reviewedProducts
    };
  }
}

class AppModel extends ChangeNotifier {
  static const USER_PREF_KEY = 'userData';
  Graph _graph;
  UserData _userData;

  AppModel(BuildContext context) {
    _loadGraph(context);
    _loadUserData();
  }

  UnmodifiableListView<Product> get products =>
      UnmodifiableListView(_graph?.products ?? []);

  UnmodifiableListView<Ingredient> get ingredients =>
      UnmodifiableListView(_graph?.ingredients ?? []);

  UserData get userData => _userData;

  void addOwnedIngredient(Ingredient ingredient) {
    _userData.ownedIngredients.add(ingredient.id);
    _saveUserData();
    notifyListeners();
  }

  void _loadGraph(BuildContext context) async {
    final graph = await DefaultAssetBundle.of(context)
        .loadStructuredData('assets/graph.json', (s) async => jsonDecode(s));
    _graph = Graph.fromJson(graph);
    notifyListeners();
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = jsonDecode(prefs.getString(AppModel.USER_PREF_KEY) ?? '{}');
    _userData = UserData.fromJson(rawJson);
  }

  void _saveUserData() async {
    final String userDataRaw = jsonEncode(_userData);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(AppModel.USER_PREF_KEY, userDataRaw);
  }
}
