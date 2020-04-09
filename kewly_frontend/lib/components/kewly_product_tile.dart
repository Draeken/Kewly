import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kewly/app_model.dart';

class KewlyProductTile extends StatelessWidget {
  final Product product;

  KewlyProductTile(this.product);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTapDown: _launchDrinkURL,
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

  void _launchDrinkURL(_) async {
    var url = product.link;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
