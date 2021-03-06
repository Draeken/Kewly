import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kewly/app_model.dart';
import 'package:kewly/components/kewly_category.dart';
import 'package:kewly/components/kewly_filter_chip.dart';
import 'package:kewly/components/kewly_product_detailed.dart';
import 'package:kewly/components/kewly_product_tile.dart';
import 'package:kewly/components/kewly_wrap_category.dart';
import 'package:kewly/decorations.dart';
import 'package:kewly/util.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

enum TagKind { mustHave, mustNotHave }

class SearchModel extends ChangeNotifier {
  SearchResult searchResult;

  // String _productName;
  // List<Ingredient> _ingredients;
  // List<String> _mustHave;
  // List<String> _mustNotHave;
  bool _isSearchActive = false;

  SearchModel()
      : searchResult = SearchResult.empty();

  void reset() {
    searchResult = SearchResult.empty();
    notifyListeners();
  }

  get isDirty {
    return searchResult.isDirty;
  }

  void updateSearchState(bool isActive) {
    _isSearchActive = isActive;
    notifyListeners();
  }

  void updateProductName(String productName) {
    this.searchResult = searchResult.copyWith(productName: productName);
    notifyListeners();
  }

  void updateTag(String tag, bool add, TagKind kind) {
    _updateTag(tag, add, kind);
    notifyListeners();
  }

  void updateTagWithOpposed(String mainTag, String opposedTag, bool add,
      TagKind kind) {
    _updateTag(mainTag, add, kind);
    if (add) {
      _updateTag(opposedTag, !add, kind);
    }
    notifyListeners();
  }

  bool containTag(String tag) {
    return searchResult.mustNotHave.contains(tag) || searchResult.mustHave.contains(tag);
  }

  void updateIngredient(Ingredient ingredient, bool add) {
    final ingredients = searchResult.ingredients;
    String productName = searchResult.productName;

    if (add) {
      ingredients.add(ingredient);

      // user searched for an ingredient, not a product name
      if (containsIgnoreCase(ingredient.name, productName)) {
        productName = "";
      }
    } else {
      ingredients.remove(ingredient);
    }
    this.searchResult = searchResult.copyWith(ingredients: ingredients, productName: productName);
    notifyListeners();
  }

  void _updateTag(String tag, bool add, TagKind kind) {
    final mustHave = searchResult.mustHave;
    final mustNotHave = searchResult.mustNotHave;
    if (kind == TagKind.mustHave) {
      if (add) {
        mustHave.add(tag);
        mustNotHave.remove(tag);
      } else {
        mustHave.remove(tag);
      }
    } else {
      if (add) {
        mustNotHave.add(tag);
        mustHave.remove(tag);
      } else {
        mustNotHave.remove(tag);
      }
    }
    this.searchResult = searchResult.copyWith(mustHave: mustHave, mustNotHave: mustNotHave);
  }
}

/**
    Other search filter:
    - by colors
    Other result category:
    - by easy grocery (ingredients tagged with "easy to get")
    -
 */

class HomeAppBar extends StatefulWidget {
  const HomeAppBar({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeAppBar();
}

class _HomeAppBar extends State<HomeAppBar> {
  final _inputController = TextEditingController();

  void _closeAndResetSearch(BuildContext context) {
    _unfocus(context);
    // _inputController.clear();
    Provider.of<SearchModel>(context, listen: false).reset();
  }

  void _unfocus(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  void _closeSearch(BuildContext context) {
    _unfocus(context);
    Provider.of<SearchModel>(context, listen: false).updateSearchState(false);
  }

  void _openSearch(BuildContext context) {
    Provider.of<SearchModel>(context, listen: false).updateSearchState(true);
  }

  _getLeading(BuildContext context, bool isSearchActive) {
    return isSearchActive
        ? IconButton(
      icon: const Icon(Icons.close),
      tooltip: 'Close search',
      onPressed: () => _closeAndResetSearch(context),
    )
        : null;
  }

  void _submitSearchResult(BuildContext context) {
    _closeSearch(context);
    Provider.of<SearchModel>(context, listen: false)
        .updateProductName(_inputController.text);
  }

  void _updateSearch(BuildContext context) {
    Provider.of<SearchModel>(context, listen: false)
        .updateProductName(_inputController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchModel>(builder: (context, search, _) {
      if (search.searchResult.productName.isEmpty) {
        _inputController.clear();
      }
      return SliverAppBar(
        leading: _getLeading(context, search._isSearchActive),
        actions: _getActions(context),
        pinned: true,
        title: TextField(
          controller: _inputController,
          onTap: () => _openSearch(context),
          onSubmitted: (_) => _submitSearchResult(context),
          onChanged: (_) => _updateSearch(context),
          textInputAction: TextInputAction.search,
          decoration: searchDecoration,
        ),
        backgroundColor: Colors.white,
      );
    });
  }

  _getActions(BuildContext context) {
    final appModel = Provider.of<AppModel>(context);
    final mode = appModel.displayMode;
    final Widget icon = () {
      switch (mode) {
        case DisplayMode.Grid:
          return Icon(
            Icons.view_list,
            color: Theme
                .of(context)
                .accentColor,
          );
        case DisplayMode.Detailed:
          return Icon(
            Icons.view_module,
            color: Theme
                .of(context)
                .accentColor,
          );
      }
    }();
    return [
      IconButton(
          icon: icon,
          onPressed: () =>
          appModel.displayMode = mode == DisplayMode.Detailed
              ? DisplayMode.Grid
              : DisplayMode.Detailed)
    ];
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }
}

class SearchComposition extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<AppModel, SearchModel>(
        builder: (BuildContext context, AppModel app, SearchModel search, _) {
          final res = search.searchResult;
          final Iterable<KewlyFilterChip> selected = res.ingredients.map(
                  (ingredient) =>
                  KewlyFilterChip(ingredient.name, true,
                          () => search.updateIngredient(ingredient, false)));
          final Iterable<KewlyFilterChip> ingredients = app.ingredients
              .where((ingredient) =>
          containsIgnoreCase(ingredient.name, res.productName) &&
              !res.ingredients.contains(ingredient))
              .take(30)
              .map((ingredient) =>
              KewlyFilterChip(ingredient.name, false,
                      () => search.updateIngredient(ingredient, true)));
          return KewlyWrapCategory(
              title: 'Composition',
              children: selected.followedBy(ingredients).toList(
                  growable: false));
        });
  }
}

class SearchCharacteristics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SearchModel>(
        builder: (BuildContext context, SearchModel model, _) {
          final result = model.searchResult;
          final withAlcohol = result.mustHave.contains(Tag.alcohol);
          final withoutAlcohol = result.mustNotHave.contains(Tag.alcohol);
          final hot = result.mustHave.contains(Tag.hot);
          final iced = result.mustHave.contains(Tag.ice);
          final sparkling = result.mustHave.contains(Tag.sparkling);
          final List<KewlyFilterChip> tags = [
            KewlyFilterChip('Avec Alcool', withAlcohol,
                    () => model.updateTag(
                    Tag.alcohol, !withAlcohol, TagKind.mustHave)),
            KewlyFilterChip(
                'Sans Alcool',
                withoutAlcohol,
                    () =>
                    model.updateTag(
                        Tag.alcohol, !withoutAlcohol, TagKind.mustNotHave)),
            KewlyFilterChip(
                'Chaud',
                hot,
                    () =>
                    model.updateTagWithOpposed(
                        Tag.hot, Tag.ice, !hot, TagKind.mustHave)),
            KewlyFilterChip(
                'Glacé',
                iced,
                    () =>
                    model.updateTagWithOpposed(
                        Tag.ice, Tag.hot, !iced, TagKind.mustHave)),
            KewlyFilterChip('Pétillant', sparkling,
                    () => model.updateTag(
                    Tag.sparkling, !sparkling, TagKind.mustHave))
          ];
          return KewlyWrapCategory(title: 'Caractéristiques', children: tags);
        });
  }
}

class SearchResult {
  final String productName;
  final List<Ingredient> ingredients;
  final List<String> mustHave;
  final List<String> mustNotHave;

  const SearchResult(
      {this.productName, this.ingredients, this.mustHave, this.mustNotHave});

  static SearchResult empty() {
    return SearchResult(
      productName: "",
      ingredients: [],
      mustHave: [],
      mustNotHave: [],
    );
  }

  copyWith({ String productName, List<Ingredient> ingredients, List<String> mustHave, List<String> mustNotHave}) {
    return SearchResult(
      productName: productName ?? this.productName,
      ingredients: ingredients ?? this.ingredients,
      mustHave: mustHave ?? this.mustHave,
      mustNotHave: mustNotHave ?? this.mustNotHave
    );
  }

  get isDirty {
    return productName != "" ||
        ingredients.isNotEmpty ||
        mustHave.isNotEmpty ||
        mustNotHave.isNotEmpty;
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => SearchModel(),
        child: CustomScrollView(
          slivers: <Widget>[
            HomeAppBar(),
            Selector2<AppModel,
                SearchModel,
                Tuple2<Tuple2<DisplayMode, List<Product>>,
                    Tuple3<SearchResult, bool, bool>>>(
                selector: (_, appModel, searchModel) =>
                    Tuple2(
                        Tuple2(appModel.displayMode, appModel.products),
                        Tuple3(searchModel.searchResult,
                            searchModel._isSearchActive, searchModel.isDirty)),
                builder: (_, data, __) {
                  final matchingProducts = _findMatchingProduct(
                      data.item1.item2, data.item2.item1);
                  final children = <Widget>[
                    AllYourProducts(matchingProducts, data.item1.item1),
                    ForAFewDollarsMore(matchingProducts, data.item1.item1),
                  ];
                  if (data.item2.item2) {
                    children.insertAll(0, [
                      SearchCharacteristics(),
                      SearchComposition(),
                    ]);
                  }
                  if (data.item2.item3) {
                    if (!data.item2.item2) {
                      children.insert(0, FilterStrip(data.item2.item1));
                    }
                    children
                        .add(AllProducts(matchingProducts, data.item1.item1));
                  }
                  return SliverList(
                    delegate: SliverChildListDelegate(children),
                  );
                })
          ],
        ));
  }

  List<Product> _findMatchingProduct(List<Product> products,
      SearchResult search) {
    Iterable<Product> matchingProducts = products ?? const [];

    if (search.ingredients.isNotEmpty) {
      matchingProducts = Set<Product>.from(
          search.ingredients.expand((ingredient) => ingredient.usedBy))
          .toList(growable: false);
    }
    if (search.productName != "") {
      matchingProducts = matchingProducts.where(
              (product) =>
              containsIgnoreCase(product.name, search.productName));
    }
    if (search.mustHave.isNotEmpty) {
      matchingProducts = matchingProducts.where((product) =>
          search.mustHave.every((tag) => product.tags.contains(tag)));
    }
    if (search.mustNotHave.isNotEmpty) {
      matchingProducts = matchingProducts.where((product) =>
      !search.mustNotHave.any((tag) => product.tags.contains(tag)));
    }
    return matchingProducts.toList(growable: false);
  }
}

class UpdateTagObj {
  final String tag;
  final TagKind kind;

  UpdateTagObj(this.tag, this.kind);
}

class FilterStrip extends StatelessWidget {
  final SearchResult search;

  const FilterStrip(this.search);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Wrap(
        children: _getFilters(context),
        spacing: 8,
        alignment: WrapAlignment.start,
      ),
    );
  }

  List<Chip> _getFilters(BuildContext context) {
    final tags = search.mustHave
        .map((s) => UpdateTagObj(s, TagKind.mustHave))
        .followedBy(search.mustNotHave
        .map((s) => UpdateTagObj(s, TagKind.mustNotHave)));
    final compo = search.ingredients.map(_ingredientToChip(context));
    return tags
        .map(_tagToChip(context))
        .followedBy(compo)
        .toList(growable: false);
  }

  Chip Function(Ingredient) _ingredientToChip(BuildContext context) =>
          (Ingredient ingredient) =>
          Chip(
            label: Text(ingredient.name),
            onDeleted: () =>
                Provider.of<SearchModel>(context, listen: false)
                    .updateIngredient(ingredient, false),
            backgroundColor: Colors.white,
            shape: _getChipShape(),
          );

  Chip Function(UpdateTagObj) _tagToChip(BuildContext context) =>
          (UpdateTagObj tagObj) =>
          Chip(
              label: Text(
                  (tagObj.kind == TagKind.mustHave ? 'With ' : 'Without ') +
                      tagObj.tag),
              onDeleted: () =>
                  Provider.of<SearchModel>(context, listen: false)
                      .updateTag(tagObj.tag, false, tagObj.kind),
              backgroundColor: Colors.white,
              shape: _getChipShape());

  ShapeBorder _getChipShape() =>
      RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(width: 1.5, color: Colors.black38));
}

class AllYourProducts extends StatelessWidget with HandleDisplayMode {
  final List<Product> products;
  final DisplayMode displayMode;

  const AllYourProducts(this.products, this.displayMode);

  @override
  Widget build(BuildContext context) {
    var ownedProducts = products
        .where((product) =>
        product.composition.every((compo) => compo.ingredient.isOwned))
        .toList(growable: false);
    return getKewlyCategory(
        'yours', displayMode, 'Vos boissons', ownedProducts);
  }
}

class AllProducts extends StatelessWidget with HandleDisplayMode {
  final List<Product> products;
  final DisplayMode displayMode;

  AllProducts(this.products, this.displayMode);

  @override
  Widget build(BuildContext context) {
    return getKewlyCategory('all', displayMode, 'Toutes les boissons', products,
        displayBadge: true);
  }
}

class ProductWithMissing {
  final Product product;
  final List<Ingredient> missing;

  const ProductWithMissing({this.product, this.missing});
}

class ForAFewDollarsMore extends StatelessWidget {
  final List<Product> products;
  final DisplayMode displayMode;

  const ForAFewDollarsMore(this.products, this.displayMode);

  @override
  Widget build(BuildContext context) {
    List<ProductWithMissing> productWithMissing = products
        .map((product) {
      var missing = product.composition
          .where((compo) => !compo.ingredient.isOwned)
          .map((compo) => compo.ingredient)
          .toList(growable: false);
      return ProductWithMissing(missing: missing, product: product);
    })
        .where((ProductWithMissing pwm) => pwm.missing.length == 1)
        .toList(growable: false);
    productWithMissing.sort((a, b) {
      return b.missing[0].usedBy.length.compareTo(a.missing[0].usedBy.length);
    });
    final builderTile = (BuildContext _context, int index) {
      return KewlyProductTile(
        heroKey: 'missing',
        product: productWithMissing[index].product,
        displayBadge: true,
      );
    };
    final builderDetailled = (BuildContext _context, int index) {
      return KewlyProductDetailed(
        heroKey: 'missing',
        product: productWithMissing[index].product,
        displayBadge: true,
      );
    };
    return KewlyCategory(
        title: 'Pour quelques \$ de plus',
        builder: displayMode == DisplayMode.Detailed
            ? builderDetailled
            : builderTile,
        itemCount: productWithMissing.length);
  }
}

mixin HandleDisplayMode {
  KewlyCategory getKewlyCategory(String heroTag, DisplayMode displayMode,
      String title, List<Product> products,
      {int maxCrossAxisCount = 3, bool displayBadge = false}) {
    final builderTile = (BuildContext context, int index) {
      return KewlyProductTile(
        heroKey: heroTag,
        product: products[index],
        displayBadge: displayBadge,
      );
    };
    final builderDetailed = (BuildContext context, int index) {
      return KewlyProductDetailed(
          heroKey: heroTag,
          product: products[index],
          displayBadge: displayBadge);
    };
    return KewlyCategory(
      title: title,
      itemCount: products.length,
      builder:
      displayMode == DisplayMode.Detailed ? builderDetailed : builderTile,
      maxCrossAxisCount: maxCrossAxisCount,
    );
  }
}
