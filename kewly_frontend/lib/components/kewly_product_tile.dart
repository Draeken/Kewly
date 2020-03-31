import 'package:flutter/material.dart';
import 'package:kewly/app_model.dart';

class KewlyProductTile extends StatelessWidget {
  final Product product;

  KewlyProductTile({this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTapDown: (_) {},
        child: Column(children: [
          Container(
              decoration: BoxDecoration(
                  border: Border.all(
                      width: 1, color: Theme.of(context).dividerColor),
                  color: Theme.of(context).accentColor),
              height: 100.0,
              width: 100.0),
          Text('${product.name}'),
        ]));
  }
}
