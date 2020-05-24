import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kewly/app_model.dart';
import 'package:kewly/pages/ingredient_detail.dart';

class KewlyIngredientVisual extends StatelessWidget {
  final Ingredient ingredient;
  final height;
  final width;

  KewlyIngredientVisual(this.ingredient,
      {this.height = 100.0, this.width = 100.0});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: Theme.of(context).dividerColor),
            color: _getIngredientColor()),
        height: height,
        width: width);
  }

  _getIngredientColor() {
    return ingredient.color
        .withLightness(min(ingredient.color.lightness + 0.2, 1.0))
        .toColor();
  }
}

class KewlyIngredientTile extends StatelessWidget {
  final Ingredient ingredient;
  final Widget action;
  final String heroKey;

  KewlyIngredientTile({@required this.ingredient, this.action, this.heroKey});

  @override
  Widget build(BuildContext context) {
    final baseWidget = Container(
        padding: EdgeInsets.fromLTRB(12.5, 12.5, 12.5, 5),
        child: GestureDetector(
            onTap: _viewDetail(context),
            child: Hero(
                tag: ingredient.heroTag + (heroKey ?? ''),
                child: KewlyIngredientVisual(ingredient))));
    final stackedWidgets = this.action != null
        ? [
            baseWidget,
            Positioned(
              top: 0,
              right: 0,
              width: 25,
              height: 25,
              child: action,
            )
          ]
        : [baseWidget];
    return Column(
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: stackedWidgets,
          overflow: Overflow.visible,
        ),
        Text('${ingredient.name}', textAlign: TextAlign.center),
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
    );
  }

  _viewDetail(BuildContext context) => () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  IngredientDetail(ingredient: ingredient, heroKey: heroKey),
            ));
      };
}
