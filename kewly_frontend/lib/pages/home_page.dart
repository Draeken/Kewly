import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kewly/app_model.dart';
import 'package:kewly/components/kewly_category.dart';
import 'package:kewly/components/kewly_filter_chip.dart';
import 'package:kewly/components/kewly_product_tile.dart';
import 'package:kewly/components/kewly_wrap_category.dart';
import 'package:kewly/util.dart';
import 'package:provider/provider.dart';

enum TagKind { mustHave, mustNotHave }

class SearchModel extends ChangeNotifier {
  String _productName;
  List<Ingredient> _ingredients;
  List<String> _mustHave;
  List<String> _mustNotHave;
  bool _isSearchActive;

  SearchModel()
      : _productName = "",
        _ingredients = [],
        _mustHave = [],
        _mustNotHave = [],
        _isSearchActive = false;

  SearchResult get searchResult => SearchResult(
      productName: _productName,
      ingredients: _ingredients,
      mustHave: _mustHave,
      mustNotHave: _mustNotHave);

  void reset() {
    _productName = "";
    _ingredients = [];
    _mustHave = [];
    _mustNotHave = [];
    _isSearchActive = false;
    notifyListeners();
  }

  get isDirty {
    return _productName != "" || _ingredients.isNotEmpty || _mustHave.isNotEmpty || _mustNotHave.isNotEmpty;
  }

  void updateSearchState(bool isActive) {
    _isSearchActive = isActive;
    notifyListeners();
  }

  void updateProductName(String productName) {
    _productName = productName;
    notifyListeners();
  }

  void updateTag(String tag, bool add, TagKind kind) {
    _updateTag(tag, add, kind);
    notifyListeners();
  }

  void updateTagWithOpposed(
      String mainTag, String opposedTag, bool add, TagKind kind) {
    _updateTag(mainTag, add, kind);
    if (add) {
      _updateTag(opposedTag, !add, kind);
    }
    notifyListeners();
  }

  bool containTag(String tag) {
    return _mustNotHave.contains(tag) || _mustHave.contains(tag);
  }

  void updateIngredient(Ingredient ingredient, bool add) {
    if (add) {
      _ingredients.add(ingredient);

      // user searched for an ingredient, not a product name
      if (containsIgnoreCase(ingredient.name, _productName)) {
        _productName = "";
      }
    } else {
      _ingredients.remove(ingredient);
    }
    notifyListeners();
  }

  void _updateTag(String tag, bool add, TagKind kind) {
    if (kind == TagKind.mustHave) {
      if (add) {
        _mustHave.add(tag);
        _mustNotHave.remove(tag);
      } else {
        _mustHave.remove(tag);
      }
    } else {
      if (add) {
        _mustNotHave.add(tag);
        _mustHave.remove(tag);
      } else {
        _mustNotHave.remove(tag);
      }
    }
  }
}

/**
  TODO:
  - change transition to a Top-level transitions


  Other search filter:
  - by colors
  Other result category:
  - by easy grocery (ingredients tagged with "easy to get")
  -
 */

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  HomeAppBar({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeAppBar();

  @override
  Size get preferredSize => Size.fromHeight(56);
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
    // TODO: user may not be focusing textfield
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
      if (search._productName.isEmpty) {
        _inputController.clear();
      }
      return AppBar(
        leading: _getLeading(context, search._isSearchActive),
        title: TextField(
          controller: _inputController,
          onTap: () => _openSearch(context),
          onSubmitted: (_) => _submitSearchResult(context),
          onChanged: (_) => _updateSearch(context),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 25),
              isDense: true,
              labelText: 'Recherche',
              filled: true,
              hasFloatingPlaceholder: false,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
              fillColor: Theme.of(context).backgroundColor.withAlpha(200)),
        ),
        backgroundColor: Colors.transparent,
      );
    });
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
      final Iterable<KewlyFilterChip> selected = search._ingredients.map(
          (ingredient) => KewlyFilterChip(ingredient.name, true,
              () => search.updateIngredient(ingredient, false)));
      final Iterable<KewlyFilterChip> ingredients = app.ingredients
          .where((ingredient) =>
              containsIgnoreCase(ingredient.name, search._productName) &&
              !search._ingredients.contains(ingredient))
          .take(30)
          .map((ingredient) => KewlyFilterChip(ingredient.name, false,
              () => search.updateIngredient(ingredient, true)));
      return KewlyWrapCategory(
          title: 'Composition',
          children: selected.followedBy(ingredients).toList(growable: false));
    });
  }
}

class SearchCharacteristics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SearchModel>(
        builder: (BuildContext context, SearchModel model, _) {
      final withAlcohol = model._mustHave.contains(Tag.alcohol);
      final withoutAlcohol = model._mustNotHave.contains(Tag.alcohol);
      final hot = model._mustHave.contains(Tag.hot);
      final iced = model._mustHave.contains(Tag.ice);
      final sparkling = model._mustHave.contains(Tag.sparkling);
      final List<KewlyFilterChip> tags = [
        KewlyFilterChip('Avec Alcool', withAlcohol,
            () => model.updateTag(Tag.alcohol, !withAlcohol, TagKind.mustHave)),
        KewlyFilterChip(
            'Sans Alcool',
            withoutAlcohol,
            () => model.updateTag(
                Tag.alcohol, !withoutAlcohol, TagKind.mustNotHave)),
        KewlyFilterChip(
            'Chaud',
            hot,
            () => model.updateTagWithOpposed(
                Tag.hot, Tag.ice, !hot, TagKind.mustHave)),
        KewlyFilterChip(
            'Glacé',
            iced,
            () => model.updateTagWithOpposed(
                Tag.ice, Tag.hot, !iced, TagKind.mustHave)),
        KewlyFilterChip('Pétillant', sparkling,
            () => model.updateTag(Tag.sparkling, !sparkling, TagKind.mustHave))
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

  SearchResult(
      {this.productName, this.ingredients, this.mustHave, this.mustNotHave});

  static SearchResult empty() {
    return SearchResult(
      productName: "",
      ingredients: const [],
      mustHave: const [],
      mustNotHave: const [],
    );
  }
}

class HomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => SearchModel(),
        child: Column(
          children: <Widget>[
          HomeAppBar(),
          Center(child: Consumer2<AppModel, SearchModel>(
              builder: (context, appModel, searchModel, _) {
              final searchResult = searchModel.searchResult;
              final matchingProducts =
                  _findMatchingProduct(appModel, searchResult);
              final listChildren = <Widget>[
                AllYourProducts(matchingProducts),
                ForAFewDollarsMore(matchingProducts),
              ];
              if (searchModel._isSearchActive) {
                listChildren.insertAll(0, [
                  SearchCharacteristics(),
                  SearchComposition(),
                ]);
              } else {
                listChildren.insert(0, FilterStrip(searchResult));
              }
              if (searchModel.isDirty) {
                listChildren.add(AllProducts(matchingProducts));
              }
              return ListView(
                scrollDirection: Axis.vertical,
                children: listChildren,
              );
            }))
          ]
        )
      );
  }

  List<Product> _findMatchingProduct(AppModel appModel, SearchResult search) {
    Iterable<Product> matchingProducts = appModel.products;

    if (search.ingredients.isNotEmpty) {
      matchingProducts = Set<Product>.from(
              search.ingredients.expand((ingredient) => ingredient.usedBy))
          .toList(growable: false);
    }
    if (search.productName != "") {
      matchingProducts = matchingProducts.where(
          (product) => containsIgnoreCase(product.name, search.productName));
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

  FilterStrip(this.search);

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
      (Ingredient ingredient) => Chip(
            label: Text(ingredient.name),
            onDeleted: () => Provider.of<SearchModel>(context, listen: false)
                .updateIngredient(ingredient, false),
            backgroundColor: Colors.white,
            shape: _getChipShape(),
          );

  Chip Function(UpdateTagObj) _tagToChip(BuildContext context) =>
      (UpdateTagObj tagObj) => Chip(
          label: Text((tagObj.kind == TagKind.mustHave ? 'With ' : 'Without ') +
              tagObj.tag),
          onDeleted: () => Provider.of<SearchModel>(context, listen: false)
              .updateTag(tagObj.tag, false, tagObj.kind),
          backgroundColor: Colors.white,
          shape: _getChipShape());

  ShapeBorder _getChipShape() => RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
      side: BorderSide(width: 1.5, color: Colors.black38));
}

class AllYourProducts extends StatelessWidget {
  final List<Product> products;

  AllYourProducts(this.products);

  @override
  Widget build(BuildContext context) {
    var ownedProducts = products
        .where((product) =>
            product.composition.every((compo) => compo.ingredient.isOwned))
        .toList(growable: false);
    final builder = (BuildContext context, int index) {
      return KewlyProductTile(product: ownedProducts[index]);
    };
    return KewlyCategory(
        title: 'Vos boissons',
        itemCount: ownedProducts.length,
        builder: builder);
  }
}

class AllProducts extends StatelessWidget {
  final List<Product> products;

  AllProducts(this.products);

  @override
  Widget build(BuildContext context) {
    final builder = (BuildContext context, int index) {
      return KewlyProductTile(product: products[index]);
    };
    return KewlyCategory(
        title: 'Toutes les boissons',
        itemCount: products.length,
        builder: builder);
  }
}

class ProductWithMissing {
  final Product product;
  final List<Ingredient> missing;

  ProductWithMissing({this.product, this.missing});
}

class ForAFewDollarsMore extends StatelessWidget {
  final List<Product> products;

  ForAFewDollarsMore(this.products);

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
    final builder = (BuildContext _context, int index) {
      return KewlyProductTile(product: productWithMissing[index].product);
    };
    return KewlyCategory(
        title: 'Pour quelques \$ de plus',
        builder: builder,
        itemCount: productWithMissing.length);
  }
}
