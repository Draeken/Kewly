import 'package:flutter/material.dart';
import 'package:kewly/app_model.dart';
import 'package:kewly/components/kewly_category.dart';
import 'package:kewly/components/kewly_product_tile.dart';
import 'package:kewly/util.dart';
import 'package:provider/provider.dart';

class SearchModal extends ModalRoute<void> {
  @override
  Duration get transitionDuration => Duration(milliseconds: 128);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.5);

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      ) {
    // This makes sure that text and other content follows the material style
    return Material(
      type: MaterialType.transparency,
      // make sure that the overlay content is not cut off
      child: SafeArea(
        child: _buildOverlayContent(context),
      ),
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'This is a nice overlay',
            style: TextStyle(color: Colors.white, fontSize: 30.0),
          ),
          RaisedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Dismiss'),
          )
        ],
      ),
    );
  }

  @override
  Widget buildTransitions(
      BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    // You can add your own animations for the overlay content
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  }
}

class SearchModel extends ChangeNotifier {
  SearchResult _searchResult;

  SearchModel() _searchInput: SearchResult.empty();
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
  final ValueChanged<SearchResult> onSearchChanged;

  HomeAppBar({Key key, this.onSearchChanged}) : super(key: key);

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
 * homeAppBar call Navigator.push(modalRoute)/pop
 * textfield update -> call update on SearchModel (ChangeNotifier)
 * modalRoute
 * maybe use SearchModel to compute product set (which will be used by home categories)
 */
class _HomeAppBar extends State<HomeAppBar> {
  bool isSearchEnabled = false;
  final _inputController = TextEditingController();

  void _closeAndResetSearch(BuildContext context) {
    _closeSearch(context);
    _inputController.clear();
    this.widget.onSearchChanged(SearchResult.empty());
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
    setState(() {
      isSearchEnabled = false;
    });
  }

  void _openSearch() {
    if (isSearchEnabled) {
      return;
    }
    setState(() {
      isSearchEnabled = true;
    });
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
    this.widget.onSearchChanged(SearchResult(
      productName: _inputController.text,
      ingredients: const [],
      mustHave: const [],
      mustNotHave: const []
    ));
    _closeSearch(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: _getLeading(context),
      title: TextField(
        controller: _inputController,
        onTap: _openSearch,
        onSubmitted (_) => _submitSearchResult(context), // should emit a new SearchResult
        onChanged: // should filter out chips widget.onSearchChanged,
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

class SearchResult {
  final String productName;
  final List<Ingredient> ingredients;
  final List<Tag> mustHave;
  final List<Tag> mustNotHave;

  SearchResult({this.productName, this.ingredients, this.mustHave, this.mustNotHave});

  static SearchResult empty() {
    return SearchResult(
      productName: "",
      ingredients: const [];
      mustHave: const [];
      mustNotHave: const [];
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

class _HomePageState extends State<HomePage> {
  final _bottomNavIndex = 0;
  String _searchInput = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(
        onSearchChanged: _updateSearchInput,
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _bottomNavIndex,
          onTap: (index) => _bottomNavOnTap(context, index),
          items: _createBottomNavBarItem()),
      body: Center(
          child: ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          AllYourProducts(_searchInput),
          ForAFewDollarsMore(_searchInput)
        ],
      )),
      resizeToAvoidBottomInset: true,
    );
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

  void _updateSearchInput(newVal) {
    setState(() {
      _searchInput = newVal;
    });
  }
}

class AllYourProducts extends StatelessWidget {
  final String searchInput;

  AllYourProducts(this.searchInput);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(
      builder: (_, appModel, __) {
        var eligibleProducts = appModel.products.toList(growable: false);
        if (searchInput.isNotEmpty) {
          var eligibleIngredient = appModel.ingredients.where(
              (ingredient) => containsIgnoreCase(ingredient.name, searchInput));
          eligibleProducts = Set<Product>.from(
                  eligibleIngredient.expand((ingredient) => ingredient.usedBy))
              .toList(growable: false);
        }
        var products = eligibleProducts
            .where((product) =>
                product.composition.every((compo) => compo.ingredient.isOwned))
            .toList(growable: false);
        final builder = (BuildContext context, int index) {
          return KewlyProductTile(products[index]);
        };
        return KewlyCategory(title: 'Toutes vos boissons', itemCount: products.length, builder: builder);
      },
    );
  }
}

class ProductWithMissing {
  final Product product;
  final List<Ingredient> missing;

  ProductWithMissing({this.product, this.missing});
}

class ForAFewDollarsMore extends StatelessWidget {
  final String searchInput;

  ForAFewDollarsMore(this.searchInput);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(
      builder: (_, appModel, __) {
        var eligibleProducts = appModel.products.toList(growable: false);
        if (searchInput.isNotEmpty) {
          var eligibleIngredient = appModel.ingredients.where(
                  (ingredient) => containsIgnoreCase(ingredient.name, searchInput));
          eligibleProducts = Set<Product>.from(
              eligibleIngredient.expand((ingredient) => ingredient.usedBy))
              .toList(growable: false);
        }
        List<ProductWithMissing> productWithMissing = eligibleProducts
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
          return b.missing[0].usedBy.length
              .compareTo(a.missing[0].usedBy.length);
        });
        final builder = (BuildContext _context, int index) {
          return KewlyProductTile(productWithMissing[index].product);
        };
        return KewlyCategory(
            title: 'Pour quelques \$ de plus', builder: builder, itemCount: productWithMissing.length);
      },
    );
  }
}
