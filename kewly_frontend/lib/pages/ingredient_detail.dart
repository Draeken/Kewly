import 'package:flutter/material.dart';
import 'package:kewly/app_model.dart';
import 'package:kewly/components/kewly_category.dart';
import 'package:kewly/components/kewly_ingredient_tile.dart';
import 'package:kewly/components/kewly_product_tile.dart';
import 'package:provider/provider.dart';

enum IngredientAction { Available, Unavailable, Ban }

class IngredientDetail extends StatelessWidget {
  final Ingredient ingredient;
  final String heroKey;

  IngredientDetail({Key key, @required this.ingredient, this.heroKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: _getAppBarAction(context),
      ),
      body: Center(
          child: ListView(scrollDirection: Axis.vertical, children: <Widget>[
        Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Hero(
                tag: ingredient.heroTag + (heroKey ?? ''),
                child: AspectRatio(
                    aspectRatio: 1.618034,
                    child: KewlyIngredientVisual(
                      ingredient,
                      width: null,
                      height: null,
                    ))),
            FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  ingredient.name,
                  style: Theme.of(context)
                      .textTheme
                      .headline4
                      .copyWith(color: _getHeroTitleColor()),
                ))
          ],
        ),
        KewlyCategory(
            title: 'Vous permet de préparer',
            children: _getAvailableProducts()),
        KewlyCategory(title: 'Est utilisé dans', children: _getAllProducts()),
      ])),
      resizeToAvoidBottomInset: false,
    );
  }

  List<Widget> _getAppBarAction(BuildContext context) {
    return ingredient.isOwned
        ? <Widget>[
            ActionChip(
                label: Text('épuisé', style: TextStyle(color: Colors.white),),
                backgroundColor: Theme.of(context).accentColor,
                avatar: Icon(Icons.clear, color: Colors.white,),
                onPressed:
                    _onAppBarAction(context, IngredientAction.Unavailable))
          ]
        : <Widget>[
            ActionChip(

                label: Text('en stock', style: TextStyle(color: Colors.white),),
                backgroundColor: Theme.of(context).accentColor,
                avatar: Icon(Icons.add, color: Colors.white,),
                onPressed:
                    _onAppBarAction(context, IngredientAction.Available)),
            ActionChip(
                label: Text('banni', style: TextStyle(color: Colors.white),),
                backgroundColor: Theme.of(context).accentColor,
                avatar: Icon(Icons.thumb_down, color: Colors.white,),
                onPressed: _onAppBarAction(context, IngredientAction.Ban))
          ];
  }

  void Function() _onAppBarAction(
      BuildContext context, IngredientAction action) {
    return () {
      final appModel = Provider.of<AppModel>(context, listen: false);
      switch (action) {
        case IngredientAction.Available:
          appModel.addOwnedIngredient(ingredient);
          break;
        case IngredientAction.Ban:
          appModel.addNoGoIngredient(ingredient);
          break;
        case IngredientAction.Unavailable:
          appModel.removeOwnedIngredient(ingredient);
      }
      Navigator.of(context).pop();
    };
  }

  Color _getHeroTitleColor() {
    final luminance = ingredient.color.toColor().computeLuminance();
    return luminance > 0.14 || luminance == 0.0
        ? Colors.black54
        : Colors.white70;
  }

  List<KewlyProductTile> _getAllProducts() {
    return ingredient.usedBy
        .map((product) => KewlyProductTile(product: product))
        .toList(growable: false);
  }

  List<KewlyProductTile> _getAvailableProducts() {
    return ingredient.usedBy
        .where((product) => product.composition.every((compo) =>
            compo.ingredient == ingredient || compo.ingredient.isOwned))
        .map((product) => KewlyProductTile(product: product))
        .toList(growable: false);
  }
}
