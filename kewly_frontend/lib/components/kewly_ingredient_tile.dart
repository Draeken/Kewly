import 'package:flutter/material.dart';
import 'package:kewly/app_model.dart';

class KewlyIngredientTile extends StatelessWidget {
  final Ingredient ingredient;
  final Widget action;

  KewlyIngredientTile({@required this.ingredient, this.action});

  @override
  Widget build(BuildContext context) {
    var baseWidget = Container(
        padding: EdgeInsets.fromLTRB(12.5, 12.5, 12.5, 5),
        child: Container(
            decoration: BoxDecoration(
                border:
                    Border.all(width: 1, color: Theme.of(context).dividerColor),
                color: ingredient.color),
            height: 100.0,
            width: 100.0));
    var stackedWidgets = this.action != null
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
    return GestureDetector(
        onTapDown: (_) {},
        child: Column(
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: stackedWidgets,
              overflow: Overflow.visible,
            ),
            Text('${ingredient.name}'),
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
        ));
  }
}
