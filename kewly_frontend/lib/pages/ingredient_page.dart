import 'package:flutter/material.dart';
import 'package:kewly/app_model.dart';
import 'package:kewly/components/kewly_ingredient_tile.dart';
import 'package:provider/provider.dart';

class IngredientPage extends StatelessWidget {
  Future<void> _addIngredientDialog(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('Ajouter un ingrédient'),
              content: SingleChildScrollView(child: Consumer<AppModel>(
                builder: (_, appModel, __) {
                  return ListBody(
                    children: appModel.ingredients
                        .map((ingredient) => ListTile(
                            title: Text("product: ${ingredient.name}"),
                            onTap: () =>
                                appModel.addOwnedIngredient(ingredient)))
                        .toList(),
                  );
                },
              )));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes ingredients'),
      ),
      body: Center(
        child: Consumer<AppModel>(
          builder: (_, appModel, __) {
            return ListView(
              children: appModel.userData
                  .getOwnedIngredientObj(appModel.ingredients)
                  .map<KewlyIngredientTile>((Ingredient ingredient) =>
                      KewlyIngredientTile(ingredient))
                  .toList(),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _addIngredientDialog(context),
          child: Icon(Icons.add)),
    );
  }
}
