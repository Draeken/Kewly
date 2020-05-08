import 'package:flutter/material.dart';
import 'package:kewly/app_model.dart';
import 'package:kewly/components/kewly_category.dart';
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

  SearchModel()
      : _productName = "",
        _ingredients = [],
        _mustHave = [],
        _mustNotHave = [];

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
 * user string should be used to search beverage by name;
 * when user focus textfield:
 * - show recent search (user input; ingredients)
 * - show all filters (chips)
 * - show all ingredients by usage
 * when user type, it should
 * - show relative filters (chips), eg: "alco" -> (With Alcohol) ; (Without Alcohol)
 * - when user validate, unfocus search and display results with selected chips
 * while searching, if user tap on a filter (chips):
 * - toggle on, duplicate below textfield.
 * - search screen closes
 */
class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  final GlobalKey<OverlayState> overlayKey;

  HomeAppBar({Key key, this.overlayKey}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeAppBar();

  @override
  Size get preferredSize => Size.fromHeight(56);
}

/**
 * states:
 * - unfocused (default) (after textfield send, after chip toggle)
 * - display search modal (after textfield focus)
 *
 * homeAppBar use overlay
 * textfield update -> call update on SearchModel (ChangeNotifier)
 * modalRoute
 * maybe use SearchModel to compute product set (which will be used by home categories)
 */
class _HomeAppBar extends State<HomeAppBar> {
  bool isSearchEnabled = false;
  final _inputController = TextEditingController();
  final _searchOverlay = OverlayEntry(
      builder: (BuildContext context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[SearchCharacteristics()],
        );
      },
      opaque: true);

  void _closeAndResetSearch(BuildContext context) {
    _closeSearch(context);
    _inputController.clear();
    Provider.of<SearchModel>(context, listen: false).reset();
  }

  void _closeSearch(BuildContext context) {
    if (!isSearchEnabled) {
      return;
    }
    FocusScopeNode currentFocus = FocusScope.of(context);
    // TODO: user may not be focusing textfield
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    _searchOverlay.remove();
    setState(() {
      isSearchEnabled = false;
    });
  }

  void _openSearch(BuildContext context) {
    if (isSearchEnabled) {
      return;
    }
    setState(() {
      isSearchEnabled = true;
    });
    widget.overlayKey.currentState.insert(_searchOverlay);
  }

  _getLeading(BuildContext context) {
    return isSearchEnabled
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
    return AppBar(
      leading: _getLeading(context),
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
            fillColor: Theme.of(context).backgroundColor.withAlpha(200)),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
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
      final List<FilterChip> tags = [
        FilterChip(
            label: Text('Avec Alcool'),
            selected: withAlcohol,
            onSelected: (_) =>
                model.updateTag(Tag.alcohol, !withAlcohol, TagKind.mustHave)),
        FilterChip(
            label: Text('Sans Alcool'),
            selected: withoutAlcohol,
            onSelected: (_) => model.updateTag(
                Tag.alcohol, !withoutAlcohol, TagKind.mustNotHave)),
        FilterChip(
            label: Text('Chaud'),
            selected: hot,
            onSelected: (_) => model.updateTagWithOpposed(
                Tag.hot, Tag.ice, !hot, TagKind.mustHave)),
        FilterChip(
            label: Text('Glacé'),
            selected: iced,
            onSelected: (_) => model.updateTagWithOpposed(
                Tag.ice, Tag.hot, !iced, TagKind.mustHave)),
        FilterChip(
            label: Text('Pétillant'),
            selected: sparkling,
            onSelected: (_) =>
                model.updateTag(Tag.sparkling, !sparkling, TagKind.mustHave))
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

class NavigationLink {
  final Widget icon;
  final String title;
  final String namedRoute;
  final Color backgroundColor;

  const NavigationLink(
      {this.icon,
      this.title,
      this.namedRoute,
      this.backgroundColor = Colors.amber});
}

const NavigationLinks = <NavigationLink>[
  NavigationLink(
      title: 'Les boissons',
      icon: const Icon(Icons.local_bar),
      namedRoute: '/'),
  NavigationLink(
      title: 'Vos produits',
      icon: const Icon(Icons.local_drink),
      namedRoute: '/ingredients'),
  NavigationLink(
      title: 'Votre panier',
      icon: const Icon(Icons.shopping_cart),
      namedRoute: '/cart'),
  NavigationLink(
      title: 'À goûter',
      icon: const Icon(Icons.bookmark_border),
      namedRoute: '/profile'),
];

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

/**
 * Is it still useful to be a stateless widget?
 */
class _HomePageState extends State<HomePage> {
  final _bottomNavIndex = 0;
  final _overlayKey = GlobalKey<OverlayState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => SearchModel(),
        child: Scaffold(
          appBar: HomeAppBar(overlayKey: _overlayKey),
          bottomNavigationBar: BottomNavigationBar(
              currentIndex: _bottomNavIndex,
              onTap: (index) => _bottomNavOnTap(context, index),
              items: _createBottomNavBarItem()),
          body: Overlay(key: _overlayKey, initialEntries: [
            OverlayEntry(
                builder: (BuildContext context) => Center(child:
                        Consumer2<AppModel, SearchModel>(
                            builder: (context, appModel, searchModel, _) {
                      final matchingProducts = _findMatchingProduct(
                          appModel, searchModel.searchResult);
                      return ListView(
                        scrollDirection: Axis.vertical,
                        children: <Widget>[
                          AllYourProducts(matchingProducts),
                          ForAFewDollarsMore(matchingProducts)
                        ],
                      );
                    })),
                opaque: true)
          ]),
          resizeToAvoidBottomInset: true,
        ));
  }

  List<Product> _findMatchingProduct(AppModel appModel, SearchResult search) {
    Iterable<Product> matchingProducts = appModel.products;

    if (search.ingredients.isNotEmpty) {
      matchingProducts = Set<Product>.from(
              search.ingredients.expand((ingredient) => ingredient.usedBy))
          .toList(growable: false);
    }
    if (search.productName != "") {
      matchingProducts = matchingProducts
          .where((product) => containsIgnoreCase(product.name, search.productName));
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

  List<BottomNavigationBarItem> _createBottomNavBarItem() {
    return NavigationLinks.map((navLink) => BottomNavigationBarItem(
        icon: navLink.icon,
        title: Text(navLink.title),
        backgroundColor: navLink.backgroundColor)).toList();
  }

  void _bottomNavOnTap(BuildContext context, int index) {
    if (_bottomNavIndex == index) {
      return;
    }
    String route = NavigationLinks.elementAt(index).namedRoute;
    Navigator.of(context).pushReplacementNamed(route);
  }
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
        title: 'Toutes vos boissons',
        itemCount: ownedProducts.length,
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
