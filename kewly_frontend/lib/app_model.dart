import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kewly/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Tag {
  static const syriup = 'syriup';
  static const alcohol = 'alcool';
  static const ice = 'ice';
  static const hot = 'hot';
  static const sparkling = 'sparkling';
  static const blended = 'blended';
  static const mixed = 'mixed';
  static const filtered = 'filtered';
}

class CompositionRaw {
  final int ingredientId;
  final double quantity;
  final double eqQuantity;
  final String unit;

  const CompositionRaw(
      {this.ingredientId, this.quantity, this.unit, this.eqQuantity});

  static CompositionRaw fromJson(Map<String, dynamic> json) {
    return CompositionRaw(
        ingredientId: json['ingredientId'] as int,
        quantity: json['quantity'].toDouble(),
        eqQuantity: json['_quantity']?.toDouble(),
        unit: json['unit'] ?? "");
  }
}

class DecorationRaw {
  final int id;
  final String as;

  const DecorationRaw({this.id, this.as});

  static DecorationRaw fromJson(Map<String, dynamic> json) {
    return DecorationRaw(
      id: json['id'] as int,
      as: json['as'],
    );
  }
}

class ProductRaw {
  final int id;
  final String name;
  final String link;
  final List<CompositionRaw> composition;
  final List<DecorationRaw> decoratedWith;
  final List<String> tags;
  final double capacity;
  final int glass;

  const ProductRaw(
      {this.id,
      this.tags,
      this.name,
      this.link,
      this.composition,
      this.decoratedWith,
      this.capacity,
      this.glass});

  static ProductRaw fromJson(Map<String, dynamic> json) {
    final List<CompositionRaw> composition =
        mapJsonToList(json['composition'], CompositionRaw.fromJson);
    final List<DecorationRaw> decoration =
        mapJsonToList(json['decoratedWith'], DecorationRaw.fromJson);
    return ProductRaw(
        id: json['id'] as int,
        glass: json['glass'] as int,
        tags: List<String>.from(json['tags'], growable: false),
        name: json['name'] as String,
        link: json['link'] as String,
        decoratedWith: decoration,
        capacity: json['capacity']?.toDouble(),
        composition: composition);
  }
}

class Composition {
  Ingredient ingredient;
  final int ingredientId;
  final double quantity;
  final double eqQuantity;
  final String unit;

  Composition(
      {this.ingredient,
      this.eqQuantity,
      this.ingredientId,
      this.quantity,
      this.unit});
}

class Decoration {
  Ingredient ingredient;
  final int ingredientId;
  final String as;

  Decoration({this.ingredient, this.ingredientId, this.as});
}

abstract class Id {
  int get id;
}

class Product implements Id {
  final int id;
  final String name;
  final String link;
  final double capacity;
  final int glass;
  final List<String> tags;
  final Iterable<Composition> composition;
  final Iterable<Decoration> decoratedWith;

  const Product(
      {this.id,
      this.name,
      this.link,
      this.composition,
      this.decoratedWith,
      this.tags,
      this.capacity,
      this.glass});

  get heroTag {
    return name + id.toString();
  }
}

class ColorRaw {
  final double alpha;
  final double hue;
  final double lightness;
  final double saturation;
  final double concentration;

  const ColorRaw(
      {this.lightness,
      this.alpha,
      this.hue,
      this.saturation,
      this.concentration});

  static ColorRaw fromJson(Map<String, dynamic> json) {
    return ColorRaw(
        concentration: json['concentration']?.toDouble(),
        alpha: json['alpha']?.toDouble(),
        hue: json['hue']?.toDouble(),
        lightness: json['lightness']?.toDouble(),
        saturation: json['saturation']?.toDouble());
  }
}

// Color(int.parse(json['color'] ?? "0xFFFFFF"))
class IngredientRaw {
  final int id;
  final String name;
  final ColorRaw color;
  final List<int> usedBy;
  final List<int> decorates;
  final List<String> tags;

  const IngredientRaw(
      {this.id, this.name, this.color, this.usedBy, this.decorates, this.tags});

  static IngredientRaw fromJson(Map<String, dynamic> json) {
    return IngredientRaw(
      name: json['name'] as String,
      id: json['id'] as int,
      tags: List<String>.from(json['tags'], growable: false),
      usedBy: List<int>.from(json['usedBy'], growable: false),
      decorates: List<int>.from(json['decorates'], growable: false),
      color: json['color'] == null ? null : ColorRaw.fromJson(json['color']),
    );
  }
}

class Ingredient implements Id {
  final int id;
  final String name;
  final HSLColor color;
  final double colorConcentration;
  final List<Product> usedBy;
  final List<Product> decorates;
  final List<String> tags;
  bool isOwned;

  Ingredient(
      {this.id,
      this.name,
      ColorRaw color,
      this.usedBy,
      this.isOwned = false,
      this.decorates,
      this.tags})
      : this.color = color == null
            ? HSLColor.fromColor(Colors.transparent)
            : HSLColor.fromAHSL(
                color.alpha, color.hue, color.saturation, color.lightness),
        this.colorConcentration = color?.concentration ?? 1;

  get heroTag {
    return name + id.toString();
  }
}

class UserReviewRaw {
  final int productId;
  final double rating;

  const UserReviewRaw({this.productId, this.rating});

  static UserReviewRaw fromJson(Map<String, dynamic> json) {
    return UserReviewRaw(
        productId: json['productId'], rating: json['rating']?.toDouble());
  }

  Map<String, dynamic> toJson() {
    return {'productId': productId, 'rating': rating};
  }
}

class UserReview {
  final Product product;
  final double rating;

  const UserReview({this.product, this.rating});
}

enum TagType {
  contain,
  without,
}

class NoGo {
  final Ingredient ingredient;
  final String tag;
  final TagType type;

  const NoGo({this.ingredient, this.tag, this.type});
}

class NoGoRaw {
  final int ingredientId;
  final String tag;
  final TagType type;

  const NoGoRaw({this.ingredientId, this.tag, this.type});

  static NoGoRaw fromJson(Map<String, dynamic> json) {
    final type = json['type'] != null ? TagType.values[json['type']] : null;
    return NoGoRaw(
        ingredientId: json['ingredientId'], tag: json['tag'], type: type);
  }

  Map<String, dynamic> toJson() {
    return {'ingredientId': ingredientId, 'tag': tag, 'type': type?.index};
  }
}

class UserData {
  final List<int> ownedIngredients;
  final List<int> productsToPurchase;
  final List<int> ingredientsToPurchase;
  final List<int> nextToTest;
  final List<int> historic;
  final List<NoGoRaw> noGo;
  final List<UserReviewRaw> reviewedProducts;

  const UserData(
      {this.historic,
      this.ingredientsToPurchase,
      this.nextToTest,
      this.ownedIngredients,
      this.productsToPurchase,
      this.noGo,
      this.reviewedProducts});

  factory UserData.fromJson(Map<String, dynamic> json) {
    if (json['ownedIngredients'] == null) {
      return UserData.empty();
    }
    final List<UserReviewRaw> reviewedProducts = mapJsonToList(
        json['reviewedProducts'], UserReviewRaw.fromJson,
        growable: true);
    final List<NoGoRaw> noGo =
        mapJsonToList(json['noGo'], NoGoRaw.fromJson, growable: true);
    return UserData(
        historic: List<int>.from(json['historic']),
        ingredientsToPurchase: List<int>.from(json['ingredientsToPurchase']),
        nextToTest: List<int>.from(json['nextToTest']),
        ownedIngredients: List<int>.from(json['ownedIngredients']),
        productsToPurchase: List<int>.from(json['productsToPurchase']),
        noGo: noGo,
        reviewedProducts: reviewedProducts);
  }

  factory UserData.empty() {
    return UserData(
        historic: [],
        ingredientsToPurchase: [],
        nextToTest: [],
        ownedIngredients: [],
        productsToPurchase: [],
        noGo: [],
        reviewedProducts: []);
  }

  Map<String, dynamic> toJson() {
    return {
      'historic': historic,
      'ingredientsToPurchase': ingredientsToPurchase,
      'nextToTest': nextToTest,
      'ownedIngredients': ownedIngredients,
      'productsToPurchase': productsToPurchase,
      'noGo': noGo,
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

enum DisplayMode { Detailed, Grid }

class AppModel extends ChangeNotifier {
  static const USER_PREF_KEY = 'userData';

  List<Product> _products;
  List<Product> products;
  List<Ingredient> _ingredients;
  List<Ingredient> ingredients;

  UserData _userData;
  List<Ingredient> ownedIngredients;
  List<Product> _productsToPurchase;
  List<Ingredient> _ingredientsToPurchase;
  List<Product> nextToTest;
  List<Product> historic;
  List<NoGo> noGo;
  List<UserReview> reviewedProducts;
  DisplayMode _displayMode = DisplayMode.Grid;

  AppModel(BuildContext context) {
    _initData(context);
  }

  set displayMode(DisplayMode mode) {
    _displayMode = mode;
    notifyListeners();
  }

  DisplayMode get displayMode {
    return _displayMode;
  }

  void addOwnedIngredient(Ingredient ingredient) {
    _userData.ownedIngredients.add(ingredient.id);
    ownedIngredients.add(ingredient);
    ingredient.isOwned = true;
    ownedIngredients = ownedIngredients.toList();
    ingredients = ingredients.toList();
    _saveUserData();
    notifyListeners();
  }

  void addNoGoIngredient(Ingredient ingredient) {
    _userData.noGo.add(NoGoRaw(ingredientId: ingredient.id));
    _saveUserData();
    final noGo = NoGo(ingredient: ingredient);
    this.noGo = this.noGo + [noGo];
    _filterFromNoGoIngredient([noGo], products, ingredients);
    notifyListeners();
  }

  void addNoGoTagExclusive(String tag) {
    _userData.noGo.add(NoGoRaw(tag: tag, type: TagType.without));
    _saveUserData();
    final noGo = NoGo(tag: tag, type: TagType.without);
    this.noGo = this.noGo + [noGo];
    _filterFromNoGoIngredient([noGo], products, ingredients);
    notifyListeners();
  }

  void removeNoGo(NoGo noGo) {
    _userData.noGo.removeWhere((noGoRaw) => noGoRaw.ingredientId == noGo.ingredient?.id && noGoRaw.tag == noGo.tag && noGoRaw.type == noGo.type);
    _saveUserData();
    final noGos = this.noGo.toList(growable: true);
    noGos.remove(noGo);
    this.noGo = noGos.toList(growable: false);
    _filterFromNoGoIngredient(this.noGo, _products, _ingredients);
    notifyListeners();
  }

  void removeOwnedIngredient(Ingredient ingredient) {
    _userData.ownedIngredients.remove(ingredient.id);
    ownedIngredients.remove(ingredient);
    ingredient.isOwned = false;
    ownedIngredients = ownedIngredients.toList();
    _saveUserData();
    notifyListeners();
  }

  void _filterFromNoGoIngredient(List<NoGo> noGos,
      Iterable<Product> productSource, Iterable<Ingredient> ingredientSource) {
    Iterable<Product> productsTemp = productSource.toList(growable: false);
    Iterable<Ingredient> ingredientsTemp = ingredientSource.toList(growable: false);
    for (final noGo in noGos) {
      if (noGo.ingredient != null) {
        productsTemp = productsTemp.where((productTemp) => productTemp.composition.every((cp) => cp.ingredient != noGo.ingredient));
        ingredientsTemp = ingredientsTemp.where((ingredientTemp) => ingredientTemp != noGo.ingredient);
      } else if (noGo.tag != null) {
        if (noGo.type == TagType.without) {
          productsTemp = productsTemp.where((productTemp) => productTemp.composition.every((cp) => cp.ingredient.tags.every((tag) => tag != noGo.tag)));
          ingredientsTemp = ingredientsTemp.where((ingredientTemp) => ingredientTemp.tags.every((tag) => tag != noGo.tag));
        } else {
          productsTemp = productsTemp.where((productTemp) => productTemp.composition.any((cp) => cp.ingredient.tags.any((tag) => tag == noGo.tag)));
          ingredientsTemp = ingredientsTemp.where((ingredientTemp) => ingredientTemp.tags.any((tag) => tag == noGo.tag));
        }
      }
    }
    this.products = productsTemp.toList(growable: false);
    this.ingredients = ingredientsTemp.toList(growable: false);
  }

  void _initData(BuildContext context) async {
    await _loadGraph(context);
    await _loadUserData();
    _resetDataView();
    notifyListeners();
  }

  void _resetDataView() {
    _filterFromNoGoIngredient(
        noGo,
        _products,
        _ingredients);
  }

  _debugGraph() {
    final List<GlassInfo> glassList = [];
    for (var product in _products) {
      final glassInfo = glassList.firstWhere((g) => g.id == product.glass,
          orElse: () => null);
      if (glassInfo == null) {
        glassList.add(GlassInfo(id: product.glass, count: 1));
        continue;
      }
      glassInfo.count += 1;
    }
    glassList.sort((a, b) => b.count.compareTo(a.count));
    return glassList;
  }

  Future<void> _loadGraph(BuildContext context) async {
    final graph = await DefaultAssetBundle.of(context)
        .loadStructuredData('assets/graph.json', (s) async => jsonDecode(s));
    final Iterable<ProductRaw> productsRaw =
        mapJsonToList(graph['products'], ProductRaw.fromJson, toList: false);
    final Iterable<IngredientRaw> ingredientsRaw = mapJsonToList(
        graph['ingredients'], IngredientRaw.fromJson,
        toList: false);
    _products = productsRaw
        .map((productRaw) => Product(
            name: productRaw.name,
            id: productRaw.id,
            link: productRaw.link,
            capacity: productRaw.capacity,
            glass: productRaw.glass,
            tags: productRaw.tags,
            decoratedWith: productRaw.decoratedWith
                .map((decorateRaw) => Decoration(
                    ingredientId: decorateRaw.id, as: decorateRaw.as))
                .toList(growable: false),
            composition: productRaw.composition
                .map((compoRaw) => Composition(
                    unit: compoRaw.unit,
                    quantity: compoRaw.quantity,
                    eqQuantity: compoRaw.eqQuantity,
                    ingredientId: compoRaw.ingredientId))
                .toList(growable: false)))
        .toList(growable: false);
    _ingredients = ingredientsRaw
        .map((ingredientRaw) => Ingredient(
            id: ingredientRaw.id,
            name: ingredientRaw.name,
            color: ingredientRaw.color,
            tags: ingredientRaw.tags,
            decorates: _objectifyIdList<Product>(
                ingredientRaw.decorates, _products, growable: false),
            usedBy: _objectifyIdList<Product>(ingredientRaw.usedBy, _products,
                growable: false)))
        .toList(growable: false);
    _products.forEach((product) {
      product.composition.forEach((compo) {
        compo.ingredient = _firstWithId(_ingredients)(compo.ingredientId);
      });
      product.decoratedWith.forEach((deco) {
        deco.ingredient = _firstWithId(_ingredients)(deco.ingredientId);
      });
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = jsonDecode(prefs.getString(AppModel.USER_PREF_KEY) ?? '{}');
    _userData = UserData.fromJson(rawJson);
    ownedIngredients = _userData.ownedIngredients.map((ingredientId) {
      final ingredient = _firstWithId(_ingredients)(ingredientId);
      ingredient.isOwned = true;
      return ingredient;
    }).toList();
    _productsToPurchase =
        _objectifyIdList(_userData.productsToPurchase, _products);
    _ingredientsToPurchase =
        _objectifyIdList(_userData.ingredientsToPurchase, _ingredients);
    nextToTest = _objectifyIdList(_userData.nextToTest, _products);
    historic = _objectifyIdList(_userData.historic, _products);
    noGo = _userData.noGo
        .map((noGo) => NoGo(
            ingredient: _firstWithId(_ingredients)(noGo.ingredientId),
            tag: noGo.tag,
            type: noGo.type))
        .toList(growable: false);
    reviewedProducts = _userData.reviewedProducts
        .map((rawReview) => UserReview(
              rating: rawReview.rating,
              product: _firstWithId(_products)(rawReview.productId),
            ))
        .toList();
  }

  List<int> _getDefaultOwnedIngredients() {
    return const <int>[
      27,
      32,
      41,
      222,
      83,
      35,
      139,
      87,
      40,
      60,
      243,
      227,
      114,
      136,
      325,
      180,
      313,
      205,
      184,
      30,
      153,
      188,
      181,
      303,
      166,
      278,
      242,
      328,
      113,
      33,
      151,
      69,
      145,
      491,
      135,
      71,
      320,
      140,
      536,
      269,
      202,
      212
    ];
  }

  void _saveUserData() async {
    final String userDataRaw = jsonEncode(_userData);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(AppModel.USER_PREF_KEY, userDataRaw);
  }
}

class GlassInfo {
  final int id;
  int count;

  GlassInfo({this.id, this.count});
}

List<U> _objectifyIdList<U extends Id>(List<int> listOfId, List<U> listOfObj,
    {growable = true}) {
  return listOfId.map(_firstWithId<U>(listOfObj)).toList(growable: growable);
}

U Function(int) _firstWithId<U extends Id>(Iterable<U> list) {
  return (int id) => list.firstWhere(_checkById<U>(id));
}

bool Function(T) _checkById<T extends Id>(int toCheck) {
  return (T against) => against.id == toCheck;
}
