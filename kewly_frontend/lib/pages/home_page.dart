import 'package:flutter/material.dart';
import 'package:kewly/app_model.dart';
import 'package:kewly/components/kewly_category.dart';
import 'package:kewly/components/kewly_product_tile.dart';
import 'package:kewly/util.dart';
import 'package:provider/provider.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  final ValueChanged<String> onSearchChanged;

  HomeAppBar({Key key, this.onSearchChanged}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeAppBar();

  @override
  Size get preferredSize => Size.fromHeight(56);
}

class _HomeAppBar extends State<HomeAppBar> {
  bool isSearchEnabled = false;
  final _inputController = TextEditingController();

  void _closeSearch(BuildContext context) {
    if (!isSearchEnabled) {
      return;
    }
    _inputController.clear();
    this.widget.onSearchChanged("");
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    setState(() {
      isSearchEnabled = !isSearchEnabled;
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

  _getLeading() {
    return isSearchEnabled
        ? IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Close search',
            onPressed: () => _closeSearch(context),
          )
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: _getLeading(),
      title: TextField(
        controller: _inputController,
        onTap: _openSearch,
        onChanged: widget.onSearchChanged,
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
