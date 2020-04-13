import 'package:flutter/material.dart';
import 'package:kewly/app_model.dart';
import 'package:kewly/components/kewly_category.dart';
import 'package:kewly/components/kewly_product_tile.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;

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

  _getActions() {
    return isSearchEnabled
        ? <Widget>[]
        : <Widget>[
            IconButton(
              icon: const Icon(Icons.account_circle),
              tooltip: 'Go to your profile',
              onPressed: () {},
            )
          ];
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
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
              fillColor: Theme.of(context).backgroundColor.withAlpha(200)),
        ),
        actions: _getActions());
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

class HomePage extends StatelessWidget {
  final _bottomNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(
        onSearchChanged: (String str) {
          developer.log(str);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) => _bottomNavOnTap(context, index),
        items: NavigationLinks.map((navLink) => BottomNavigationBarItem(
            icon: navLink.icon,
            title: Text(navLink.title),
            backgroundColor: navLink.backgroundColor)).toList(),
      ),
      body: Center(
          child: ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[AllYourProducts(), ForAFewDollarsMore()],
      )),
      resizeToAvoidBottomInset: true,
    );
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
  AllYourProducts();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(
      builder: (_, appModel, __) {
        var products = appModel.products
            .where((product) => product.composition.every((ingredient) =>
                appModel.userData.ownedIngredients
                    .contains(ingredient.ingredientId)))
            .toList();
        var children =
            products.map((product) => KewlyProductTile(product)).toList();
        return KewlyCategory(title: 'Toutes vos boissons', children: children);
      },
    );
  }
}

class ProductWithMissing {
  final Product product;
  final List<int> missing;

  ProductWithMissing({this.product, this.missing});
}

class ForAFewDollarsMore extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(
      builder: (_, appModel, __) {
        List<ProductWithMissing> productWithMissing = appModel.products
            .map((product) {
              var missing = product.composition
                  .where((compo) => !appModel.userData.ownedIngredients
                      .contains(compo.ingredientId))
                  .map((compo) => compo.ingredientId)
                  .toList(growable: false);
              return ProductWithMissing(missing: missing, product: product);
            })
            .where((ProductWithMissing pwm) => pwm.missing.length == 1)
            .toList();
        productWithMissing.sort((a, b) {
          var ingredientA = appModel.ingredients
              .firstWhere((ingredient) => ingredient.id == a.missing[0]);
          var ingredientB = appModel.ingredients
              .firstWhere((ingredient) => ingredient.id == b.missing[0]);
          return ingredientB.usedBy.length.compareTo(ingredientA.usedBy.length);
        });
        var children = productWithMissing
            .map((pwm) => KewlyProductTile(pwm.product))
            .toList();
        return KewlyCategory(
            title: 'Pour quelques \$ de plus', children: children);
      },
    );
  }
}
