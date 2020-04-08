import 'package:flutter/material.dart';
import 'package:kewly/app_model.dart';
import 'package:kewly/components/kewly_app_bar.dart';
import 'package:kewly/components/kewly_button_badge.dart';
import 'package:kewly/components/kewly_category_title.dart';
import 'package:kewly/components/kewly_ingredient_tile.dart';
import 'package:kewly/util.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;

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
        child: Consumer<AppModel>(
          builder: (_, appModel, __) {
            var ownedIngredients =
                appModel.userData.getOwnedIngredientObj(appModel.ingredients);
            var ownedCatIngredients = searchInput == ''
                ? ownedIngredients
                : ownedIngredients
                    .where((ingredient) =>
                        containsIgnoreCase(ingredient.name, searchInput))
                    .toList();
            List<Ingredient> notOwnedIngredients = appModel.ingredients
                .where((ingredient) => !ownedIngredients.contains(ingredient))
                .toList();
            notOwnedIngredients
                .sort((a, b) => b.usedBy.length.compareTo(a.usedBy.length));
            var otherCatIngredients = searchInput == ''
                ? notOwnedIngredients.take(10).toList()
                : notOwnedIngredients
                    .where((ingredient) =>
                        containsIgnoreCase(ingredient.name, searchInput))
                    .toList();
            return ListView(
              scrollDirection: Axis.vertical,
              children: <Widget>[
                IngredientCategory(
                  ingredients: ownedCatIngredients,
                  title: 'Vos produits',
                  areOwned: true,
                ),
                IngredientCategory(
                  ingredients: otherCatIngredients,
                  title: 'Plus de choix avec',
                )
              ],
            );
          },
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}

class IngredientCategory extends StatelessWidget {
  final List<Ingredient> ingredients;
  final String title;
  final bool areOwned;

  IngredientCategory(
      {@required this.ingredients,
      @required this.title,
      this.areOwned = false});

  @override
  Widget build(BuildContext context) {
    if (ingredients.length == 0) {
      return SizedBox(
        height: 0,
      );
    }
    var onTap = areOwned
        ? (Ingredient ingredient) => (TapDownDetails _) =>
            Provider.of<AppModel>(context, listen: false)
                .removeOwnedIngredient(ingredient)
        : (Ingredient ingredient) => (TapDownDetails _) {
              developer.log('tapped ! ${ingredient.name}');
              Provider.of<AppModel>(context, listen: false)
                  .addOwnedIngredient(ingredient);
            };
    var actionIcon = areOwned ? Icon(Icons.remove) : Icon(Icons.add);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        KewlyCategoryTitle(title),
        LimitedBox(
            maxHeight: 600,
            child: GridView.count(
              primary: false,
              shrinkWrap: true,
              crossAxisCount: 3,
              scrollDirection: Axis.horizontal,
              children: ingredients
                  .map<KewlyIngredientTile>((ingredient) => KewlyIngredientTile(
                        ingredient: ingredient,
                        action: KewlyButtonBadge(
                          onTap: onTap(ingredient),
                          icon: actionIcon,
                        ),
                      ))
                  .toList(),
            )),
      ],
    );
  }
}
