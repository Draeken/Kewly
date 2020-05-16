import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kewly/app_model.dart';
import 'package:kewly/pages/ingredient_detail.dart';

class KewlyIngredientTile extends StatelessWidget {
  final Ingredient ingredient;
  final Widget action;

  KewlyIngredientTile({@required this.ingredient, this.action});

  @override
  Widget build(BuildContext context) {
    final baseWidget = Container(
        padding: EdgeInsets.fromLTRB(12.5, 12.5, 12.5, 5),
        child: GestureDetector(
          onTap: _viewDetail(context),
          child: Container(
              decoration: BoxDecoration(
                  border:
                      Border.all(width: 1, color: Theme.of(context).dividerColor),
                  color: _getIngredientColor()),
              height: 100.0,
              width: 100.0)));
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
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => IngredientDetail(ingredient: ingredient),
    ));
  };

  _getIngredientColor() {
    return ingredient.color.withLightness(min(ingredient.color.lightness + 0.2, 1.0)).toColor();
  }
}
