import 'package:flutter/material.dart';
import 'package:kewly/app_model.dart';
import 'package:kewly/components/kewly_app_bar.dart';
import 'package:kewly/components/kewly_button_badge.dart';
import 'package:kewly/components/kewly_category.dart';
import 'package:kewly/components/kewly_ingredient_tile.dart';
import 'package:kewly/pages/home_page.dart';
import 'package:kewly/util.dart';
import 'package:provider/provider.dart';

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
      appBar: KewlyAppBar(
        title: 'Produits',
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
        child: ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[
            OwnedIngredientCategory(
              searchInput,
            ),
            MoreChoiceWithCategory(searchInput)
          ],
        ),
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
  final String searchInput;

  OwnedIngredientCategory(this.searchInput);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(
      builder: (context, appModel, _) {
        var filteredIngredients = searchInput == ''
            ? appModel.ownedIngredients
            : appModel.ownedIngredients.where((ingredient) =>
                containsIgnoreCase(ingredient.name, searchInput));
        var children = filteredIngredients
            .map<KewlyIngredientTile>((ingredient) => KewlyIngredientTile(
                  ingredient: ingredient,
                  action: KewlyButtonBadge(
                    onTap: _onTap(ingredient, appModel),
                    icon: Icon(Icons.remove),
                  ),
                ))
            .toList();
        return KewlyCategory(title: 'Vos produits', children: children);
      },
    );
  }

  _onTap(Ingredient ingredient, AppModel appModel) {
    return (TapDownDetails _) => appModel.removeOwnedIngredient(ingredient);
  }
}

class MoreChoiceWithCategory extends StatelessWidget {
  final String searchInput;

  MoreChoiceWithCategory(this.searchInput);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(
      builder: (context, appModel, _) {
        List<Ingredient> notOwnedIngredients = appModel.ingredients
            .where((ingredient) => !ingredient.isOwned)
            .toList();
        notOwnedIngredients
            .sort((a, b) => b.usedBy.length.compareTo(a.usedBy.length));
        var filteredIngredients = (searchInput == ''
            ? notOwnedIngredients
            : notOwnedIngredients.where((ingredient) =>
                containsIgnoreCase(ingredient.name, searchInput))).toList(growable: false);
        return KewlyCategory(
            title: 'Plus de choix avec',
            itemCount: filteredIngredients.length,
            builder: _getBuilder(filteredIngredients, appModel));
      },
    );
  }

  KewlyIngredientTile Function(BuildContext, int) _getBuilder(
          List<Ingredient> ingredients, AppModel appModel) =>
      (BuildContext context, int index) {
        final ingredient = ingredients[index];
        return KewlyIngredientTile(
          ingredient: ingredient,
          action: KewlyButtonBadge(
            onTap: _onTap(ingredient, appModel),
            icon: Icon(Icons.add),
          ),
        );
      };

  _onTap(Ingredient ingredient, AppModel appModel) {
    return (TapDownDetails _) => appModel.addOwnedIngredient(ingredient);
  }
}
