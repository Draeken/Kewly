import 'package:flutter/material.dart';
import 'package:kewly/app_model.dart';

class KewlyIngredientTile extends StatelessWidget {
  final Ingredient ingredient;

  KewlyIngredientTile(this.ingredient);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTapDown: (_) {},
        child: Column(children: [
          Container(
              decoration: BoxDecoration(
                  border: Border.all(
                      width: 1, color: Theme.of(context).dividerColor),
                  color: ingredient.color),
              height: 100.0,
              width: 100.0),
          Text('${ingredient.name}'),
        ]));
  }
}
