import 'dart:collection';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:kewly/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompositionRaw {
  final int ingredientId;
  final double quantity;
  final String unit;

  CompositionRaw({this.ingredientId, this.quantity, this.unit});

  static CompositionRaw fromJson(Map<String, dynamic> json) {
    return CompositionRaw(
        ingredientId: json['ingredientId'] as int,
        quantity: json['quantity'].toDouble(),
        unit: json['unit'] ?? "");
  }
}

class ProductRaw {
  final int id;
  final String name;
  final String link;
  final List<CompositionRaw> composition;
  final double capacity;

  ProductRaw({this.id, this.name, this.link, this.composition, this.capacity});

  static ProductRaw fromJson(Map<String, dynamic> json) {
    final List<CompositionRaw> composition =
        mapJsonToList(json['composition'], CompositionRaw.fromJson);
    return ProductRaw(
        id: json['id'] as int,
        name: json['name'] as String,
        link: json['link'] as String,
        capacity: json['capacity']?.toDouble(),
        composition: composition);
  }
}

class Composition {
  Ingredient ingredient;
  final int ingredientId;
  final double quantity;
  final String unit;

  Composition({this.ingredient, this.ingredientId, this.quantity, this.unit});
}

abstract class Id {
  int get id;
}

class Product implements Id {
  final int id;
  final String name;
  final String link;
  final double capacity;
  final Iterable<Composition> composition;

  Product({this.id, this.name, this.link, this.composition, this.capacity});
}

class IngredientRaw {
  final int id;
  final String name;
  final Color color;
  final List<int> usedBy;

  IngredientRaw({this.id, this.name, this.color, this.usedBy});

  static IngredientRaw fromJson(Map<String, dynamic> json) {
    return IngredientRaw(
      name: json['name'] as String,
      id: json['id'] as int,
      usedBy: List<int>.from(json['usedBy'], growable: false),
      color: Color(int.parse(json['color'] ?? "0xFFFFFF")),
    );
  }
}

class Ingredient implements Id {
  final int id;
  final String name;
  final Color color;
  final List<Product> usedBy;
  bool isOwned;

  Ingredient(
      {this.id, this.name, this.color, this.usedBy, this.isOwned = false});
}

class UserReviewRaw {
  final int productId;
  final double rating;

  UserReviewRaw({this.productId, this.rating});

  static UserReviewRaw fromJson(Map<String, dynamic> json) {
    return UserReviewRaw(productId: json['productId'], rating: json['rating']);
  }

  Map<String, dynamic> toJson() {
    return {'productId': productId, 'rating': rating};
  }
}

class UserReview {
  final Product product;
  final double rating;

  UserReview({this.product, this.rating});
}

class UserData {
  final List<int> ownedIngredients;
  final List<int> productsToPurchase;
  final List<int> ingredientsToPurchase;
  final List<int> nextToTest;
  final List<int> historic;
  final List<UserReviewRaw> reviewedProducts;

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
    final List<UserReviewRaw> reviewedProducts =
        mapJsonToList(json['reviewedProducts'], UserReviewRaw.fromJson);
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

  List<IngredientRaw> getOwnedIngredientObj(List<IngredientRaw> ingredients) {
    return this
        .ownedIngredients
        .map(
            (ingreId) => ingredients.firstWhere((ingre) => ingre.id == ingreId))
        .toList(growable: false);
  }
}

class AppModel extends ChangeNotifier {
  static const USER_PREF_KEY = 'userData';

  List<Product> _products;
  List<Ingredient> _ingredients;

  UserData _userData;
  List<Ingredient> _ownedIngredients;
  List<Product> _productsToPurchase;
  List<Ingredient> _ingredientsToPurchase;
  List<Product> _nextToTest;
  List<Product> _historic;
  List<UserReview> _reviewedProducts;

  AppModel(BuildContext context) {
    _initData(context);
  }

  UnmodifiableListView<Product> get products =>
      UnmodifiableListView(_products ?? []);

  UnmodifiableListView<Ingredient> get ingredients =>
      UnmodifiableListView(_ingredients ?? []);

  UnmodifiableListView<Ingredient> get ownedIngredients =>
      UnmodifiableListView(_ownedIngredients ?? []);

  void addOwnedIngredient(Ingredient ingredient) {
    _userData.ownedIngredients.add(ingredient.id);
    _ownedIngredients.add(ingredient);
    ingredient.isOwned = true;
    _saveUserData();
    notifyListeners();
  }

  void removeOwnedIngredient(Ingredient ingredient) {
    _userData.ownedIngredients.remove(ingredient.id);
    _ownedIngredients.remove(ingredient);
    ingredient.isOwned = false;
    _saveUserData();
    notifyListeners();
  }

  void _initData(BuildContext context) async {
    await _loadGraph(context);
    _loadUserData();
    notifyListeners();
  }

  Future<void> _loadGraph(BuildContext context) async {
    final graph = await DefaultAssetBundle.of(context)
        .loadStructuredData('assets/graph.json', (s) async => jsonDecode(s));
    final Iterable<ProductRaw> products =
        mapJsonToList(graph['products'], ProductRaw.fromJson, toList: false);
    final Iterable<IngredientRaw> ingredients = mapJsonToList(
        graph['ingredients'], IngredientRaw.fromJson,
        toList: false);
    _products = products
        .map((productRaw) => Product(
            name: productRaw.name,
            id: productRaw.id,
            link: productRaw.link,
            capacity: productRaw.capacity,
            composition: productRaw.composition
                .map((compoRaw) => Composition(
                    unit: compoRaw.unit,
                    quantity: compoRaw.quantity,
                    ingredientId: compoRaw.ingredientId))
                .toList(growable: false)))
        .toList(growable: false);
    _ingredients = ingredients
        .map((ingredientRaw) => Ingredient(
            id: ingredientRaw.id,
            name: ingredientRaw.name,
            color: ingredientRaw.color,
            usedBy: _objectifyIdList<Product>(ingredientRaw.usedBy, _products,
                growable: false)))
        .toList(growable: false);
    _products.forEach((product) {
      product.composition.forEach((compo) {
        compo.ingredient = _firstWithId(_ingredients)(compo.ingredientId);
      });
    });
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = jsonDecode(prefs.getString(AppModel.USER_PREF_KEY) ?? '{}');
    _userData = UserData.fromJson(rawJson);
    _ownedIngredients = _userData.ownedIngredients.map((ingredientId) {
      final ingredient = _firstWithId(_ingredients)(ingredientId);
      ingredient.isOwned = true;
      return ingredient;
    }).toList();
    _objectifyIdList(_userData.ownedIngredients, _ingredients);
    _productsToPurchase =
        _objectifyIdList(_userData.productsToPurchase, _products);
    _ingredientsToPurchase =
        _objectifyIdList(_userData.ingredientsToPurchase, _ingredients);
    _nextToTest = _objectifyIdList(_userData.nextToTest, _products);
    _historic = _objectifyIdList(_userData.historic, _products);
    _reviewedProducts = _userData.reviewedProducts
        .map((rawReview) => UserReview(
              rating: rawReview.rating,
              product: _firstWithId(_products)(rawReview.productId),
            ))
        .toList();
  }

  void _saveUserData() async {
    final String userDataRaw = jsonEncode(_userData);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(AppModel.USER_PREF_KEY, userDataRaw);
  }
}

List<U> _objectifyIdList<U extends Id>(List<int> listOfId, List<U> listOfObj,
    {growable = true}) {
  return listOfId.map(_firstWithId<U>(listOfObj)).toList(growable: growable);
}

U Function(int) _firstWithId<U extends Id>(List<U> list) {
  return (int id) => list.firstWhere(_checkById<U>(id));
}

bool Function(T) _checkById<T extends Id>(int toCheck) {
  return (T against) => against.id == toCheck;
}
