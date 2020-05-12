import 'package:flutter/material.dart';
import 'package:kewly/app_model.dart';
import 'package:kewly/components/kewly_app_bar.dart';
import 'package:kewly/components/kewly_button_badge.dart';
import 'package:kewly/components/kewly_category.dart';
import 'package:kewly/components/kewly_ingredient_tile.dart';
import 'package:kewly/pages/home_page.dart';
import 'package:kewly/util.dart';
import 'package:provider/provider.dart';

/**
  Search Result Category:
  - Products that expand available drinks (eg: with this product, you can mixe 3 new drinks)
 */
class ProductAppBar extends StatefulWidget implements PreferredSizeWidget {
  final ValueChanged<String> onSearchChanged;

  ProductAppBar({Key key, this.onSearchChanged}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProductAppBar();

  @override
  Size get preferredSize => Size.fromHeight(56);
}

class _ProductAppBar extends State<ProductAppBar> {
  bool isSearchEnabled = false;
  final _inputController = TextEditingController();

  void _closeAndResetSearch(BuildContext context) {
    _unfocus(context);
    _inputController.clear();
    setState(() {
      isSearchEnabled = false;
    });
    widget.onSearchChanged("");
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
    setState(() {
      isSearchEnabled = false;
    });
  }

  void _openSearch(BuildContext context) {
    setState(() {
      isSearchEnabled = true;
    });
  }

  _getLeading(BuildContext context) {
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
  }

  void _updateSearch(BuildContext context) {
    widget.onSearchChanged(_inputController.text);
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
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
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

class IngredientPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _IngredientPageState();
  }
}

class _IngredientPageState extends State<IngredientPage> {
  String searchInput = "";
  final _bottomNavIndex = 1;

  void _updateSearchInput(newVal) {
    setState(() {
      searchInput = newVal;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: ProductAppBar(
        onSearchChanged: _updateSearchInput,
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
        child: return Consumer<AppModel>(
        builder: (context, appModel, _) {
          final allIngredients = appModel.ingredients.where((ingredient) =>
                containsIgnoreCase(ingredient.name, searchInput)).toList(growable: false);
          final ownedIngredients = appModel.ownedIngredients.where((ingredient) =>
                containsIgnoreCase(ingredient.name, searchInput)).toList(growable: false);
          return ListView(
            scrollDirection: Axis.vertical,
            children: <Widget>[
              OwnedIngredientCategory(
                ownedIngredients,
              ),
              MoreChoiceWithCategory(allIngredients)
            ],
          );
        }),
      ),
      resizeToAvoidBottomInset: false,
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

class OwnedIngredientCategory extends StatelessWidget {
  final List<Ingredient> ingredients;

  OwnedIngredientCategory(this.ingredients);

  @override
  Widget build(BuildContext context) {
    final children = ingredients
        .map<KewlyIngredientTile>((ingredient) => KewlyIngredientTile(
              ingredient: ingredient,
              action: KewlyButtonBadge(
                onTap: _onTap(context, ingredient),
                icon: Icon(Icons.remove),
              ),
            ))
        .toList();
    return KewlyCategory(title: 'Vos produits', children: children);
  }

  _onTap(BuildContext context, Ingredient ingredient) {
    return (TapDownDetails _) => Provider.of<AppModel>(context, listen: false).removeOwnedIngredient(ingredient);
  }
}

class ExpanderInfo {
  final Ingredient ingredient;
  final int expandCount;

  ExpanderInfo(ingredient, expandCount);
}

class ExpandWithCategory extends StatelessWidget {
  final List<Ingredient> ingredients;

  ExpandWithCategory(this.ingredients);

  @override
  Widget build(BuildContext context) {
    List<ExpanderInfo> expander = ingredients.where((ingredient) => ingredient.usedBy.length > 1).map(_ingredientToExpander).toList(growable: false);
    expander.sort((a, b) => b.expandCount.compareTo(a.expandCount));

    return KewlyCategory(
        title: 'Plus de choix avec',
        itemCount: filteredIngredients.length,
        builder: _getBuilder(context, expander));
  }

  ExpanderInfo _ingredientToExpander(Ingredient ingredient) {
    final expandCount = ingredient.usedBy.reduce(0, (int acc, Product product) {
      final notOwned = product.composition.reduce(0, (int acc2, Composition compo) => compo.ingredient.isOwned ? acc2 : acc2 + 1);
      return notOwned > 1 ? acc : acc + 1;
    }
    return ExpanderInfo(ingredient, expandCount);
  }

  KewlyIngredientTile Function(BuildContext, int) _getBuilder(BuildContext context, List<Ingredient> ingredients) =>
    (BuildContext context, int index) {
      final ingredient = ingredients[index];
      return KewlyIngredientTile(
        ingredient: ingredient,
        action: KewlyButtonBadge(
          onTap: _onTap(context, ingredient),
          icon: Icon(Icons.add),
        ),
      );
    };

  _onTap(BuildContext context, Ingredient ingredient) {
    return (TapDownDetails _) => Provider.of<AppModel>(context, listen: false).addOwnedIngredient(ingredient);
  }
}

class MoreChoiceWithCategory extends StatelessWidget {
  final List<Ingredient> ingredients;

  MoreChoiceWithCategory(this.ingredients);

  @override
  Widget build(BuildContext context) {
    List<Ingredient> filteredIngredients = ingredients
        .where((ingredient) => !ingredient.isOwned)
        .toList(growable: false);
    filteredIngredients
        .sort((a, b) => b.usedBy.length.compareTo(a.usedBy.length));
    return KewlyCategory(
        title: 'Les plus utilisés',
        itemCount: filteredIngredients.length,
        builder: _getBuilder(context, filteredIngredients));
  }

  KewlyIngredientTile Function(BuildContext, int) _getBuilder(BuildContext context, List<Ingredient> ingredients) =>
      (BuildContext context, int index) {
        final ingredient = ingredients[index];
        return KewlyIngredientTile(
          ingredient: ingredient,
          action: KewlyButtonBadge(
            onTap: _onTap(context, ingredient),
            icon: Icon(Icons.add),
          ),
        );
      };

  _onTap(BuildContext context, Ingredient ingredient) {
    return (TapDownDetails _) => Provider.of<AppModel>(context, listen: false).addOwnedIngredient(ingredient);
  }
}
