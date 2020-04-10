import 'package:flutter/material.dart';
import 'package:kewly/app_model.dart';
import 'package:kewly/components/kewly_app_bar.dart';
import 'package:kewly/components/kewly_button_badge.dart';
import 'package:kewly/components/kewly_category.dart';
import 'package:kewly/components/kewly_ingredient_tile.dart';
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
}

class OwnedIngredientCategory extends StatelessWidget {
  final String searchInput;

  OwnedIngredientCategory(this.searchInput);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(
      builder: (context, appModel, _) {
        var ownedIngredients =
            appModel.userData.getOwnedIngredientObj(appModel.ingredients);
        var filteredIngredients = searchInput == ''
            ? ownedIngredients
            : ownedIngredients.where((ingredient) =>
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
        var ownedIngredients =
            appModel.userData.getOwnedIngredientObj(appModel.ingredients);
        List<Ingredient> notOwnedIngredients = appModel.ingredients
            .where((ingredient) => !ownedIngredients.contains(ingredient))
            .toList();
        notOwnedIngredients
            .sort((a, b) => b.usedBy.length.compareTo(a.usedBy.length));
        var filteredIngredients = searchInput == ''
            ? notOwnedIngredients.take(10).toList()
            : notOwnedIngredients
                .where((ingredient) =>
                    containsIgnoreCase(ingredient.name, searchInput))
                .toList();
        var children = filteredIngredients
            .map<KewlyIngredientTile>((ingredient) => KewlyIngredientTile(
                  ingredient: ingredient,
                  action: KewlyButtonBadge(
                    onTap: _onTap(ingredient, appModel),
                    icon: Icon(Icons.add),
                  ),
                ))
            .toList();
        return KewlyCategory(title: 'Plus de choix avec', children: children);
      },
    );
  }

  _onTap(Ingredient ingredient, AppModel appModel) {
    return (TapDownDetails _) => appModel.addOwnedIngredient(ingredient);
  }
}
