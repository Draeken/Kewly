import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:kewly/app_model.dart';
import 'package:kewly/components/kewly_button_badge.dart';
import 'package:kewly/components/kewly_category.dart';
import 'package:kewly/components/kewly_ingredient_tile.dart';
import 'package:kewly/util.dart';
import 'package:provider/provider.dart';

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
            floatingLabelBehavior: FloatingLabelBehavior.never,
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

class IngredientPage extends StatefulWidget {
  @override
  _IngredientPageState createState() {
    return _IngredientPageState();
  }
}

class _IngredientPageState extends State<IngredientPage> {
  String searchInput = "";
  Func2<List<Ingredient>, String, List<Ingredient>> _getAllIngredients;
  Func2<List<Ingredient>, String, List<Ingredient>> _getOwnedIngredients;

  void _updateSearchInput(newVal) {
    setState(() {
      searchInput = newVal;
    });
  }

  List<Ingredient> _filterIngredients(List<Ingredient> ingre, String input) {
    return ingre
        .where((ingredient) => containsIgnoreCase(ingredient.name, searchInput))
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    _getAllIngredients = imemo2(_filterIngredients);
    _getOwnedIngredients = imemo2(_filterIngredients);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProductAppBar(
          onSearchChanged: _updateSearchInput,
        ),
        Flexible(
          child: Consumer<AppModel>(builder: (context, appModel, _) {
            final allIngredients = _getAllIngredients(appModel.ingredients, searchInput);
            final ownedIngredients = _getOwnedIngredients(appModel.ownedIngredients, searchInput);
            return ListView(
              scrollDirection: Axis.vertical,
              children: <Widget>[
                OwnedIngredientCategory(
                  ownedIngredients,
                ),
                ExpandWithCategory(
                  products: appModel.products,
                  ownedIngredients: appModel.ownedIngredients,
                  searchInput: searchInput),
                MoreChoiceWithCategory(allIngredients)
              ],
            );
          }),
        )
      ]);
  }
}

class OwnedIngredientCategory extends StatelessWidget {
  final List<Ingredient> ingredients;
  static final heroKey = 'owned';

  OwnedIngredientCategory(this.ingredients);

  @override
  Widget build(BuildContext context) {
    final children = ingredients
        .map<KewlyIngredientTile>((ingredient) => KewlyIngredientTile(
              ingredient: ingredient,
              heroKey: heroKey,
              action: KewlyButtonBadge(
                onTap: _onTap(context, ingredient),
                icon: Icon(Icons.remove),
              ),
            ))
        .toList();
    return KewlyCategory(title: 'Vos produits', children: children);
  }

  _onTap(BuildContext context, Ingredient ingredient) {
    return (TapDownDetails _) => Provider.of<AppModel>(context, listen: false)
        .removeOwnedIngredient(ingredient);
  }
}

class ExpanderInfo {
  final Ingredient ingredient;
  final int expandCount;

  ExpanderInfo(this.ingredient, this.expandCount);
}

class ExpandWithCategory extends StatefulWidget {
  final List<Product> products;
  final List<Ingredient> ownedIngredients;
  final String searchInput;

  ExpandWithCategory(
      {Key key, this.products, this.ownedIngredients, this.searchInput})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ExpandWithCategory();
  }
}

class _ExpandWithCategory extends State<ExpandWithCategory> {
  static final heroKey = 'expand';

  Func2<List<Product>, List<Ingredient>, List<ExpanderInfo>> _getExpanders;

  List<ExpanderInfo> _expandersFunc(
      List<Product> products, List<Ingredient> _ownedIngredients) {
    final hashExpander = HashMap<int, ExpanderInfo>();
    for (var product in widget.products) {
      final expanders =
          product.composition.where((compo) => !compo.ingredient.isOwned);
      if (expanders.length != 1) {
        continue;
      }
      final expander = expanders.first.ingredient;
      hashExpander.update(expander.id, _incrementExpander,
          ifAbsent: () => ExpanderInfo(expander, 1));
    }
    return hashExpander.values.toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    _getExpanders = imemo2(_expandersFunc);
  }

  @override
  Widget build(BuildContext context) {
    final expanders = _getExpanders(widget.products, widget.ownedIngredients)
        .where((expander) =>
            containsIgnoreCase(expander.ingredient.name, widget.searchInput))
        .toList(growable: false);
    expanders.sort((a, b) => b.expandCount.compareTo(a.expandCount));

    return KewlyCategory(
        title: 'Plus de choix avec',
        itemCount: expanders.length,
        builder: _getBuilder(context, expanders));
  }

  ExpanderInfo _incrementExpander(ExpanderInfo expander) {
    final count = expander.expandCount + 1;
    return ExpanderInfo(expander.ingredient, count);
  }

  KewlyIngredientTile Function(BuildContext, int) _getBuilder(
          BuildContext context, List<ExpanderInfo> expanders) =>
      (BuildContext context, int index) {
        final ingredient = expanders[index].ingredient;
        return KewlyIngredientTile(
          ingredient: ingredient,
          heroKey: heroKey,
          action: KewlyButtonBadge(
            onTap: _onTap(context, ingredient),
            icon: Icon(Icons.add),
          ),
        );
      };

  _onTap(BuildContext context, Ingredient ingredient) {
    return (TapDownDetails _) => Provider.of<AppModel>(context, listen: false)
        .addOwnedIngredient(ingredient);
  }
}

class MoreChoiceWithCategory extends StatelessWidget {
  final List<Ingredient> ingredients;
  static final heroKey = 'more';

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

  KewlyIngredientTile Function(BuildContext, int) _getBuilder(
          BuildContext context, List<Ingredient> ingredients) =>
      (BuildContext context, int index) {
        final ingredient = ingredients[index];
        return KewlyIngredientTile(
          ingredient: ingredient,
          heroKey: heroKey,
          action: KewlyButtonBadge(
            onTap: _onTap(context, ingredient),
            icon: Icon(Icons.add),
          ),
        );
      };

  _onTap(BuildContext context, Ingredient ingredient) {
    return (TapDownDetails _) => Provider.of<AppModel>(context, listen: false)
        .addOwnedIngredient(ingredient);
  }
}
