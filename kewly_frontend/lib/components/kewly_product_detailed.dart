import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kewly/components/kewly_product_badge.dart';
import 'package:kewly/app_model.dart';
import 'package:url_launcher/url_launcher.dart';

class KewlyProductDetailed extends StatefulWidget {
  final Product product;
  final bool displayBadge;

  KewlyProductDetailed({Key key, this.product, this.displayBadge = false}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _KewlyProductDetailed();
}

class _KewlyProductDetailed extends State<KewlyProductDetailed> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTapDown: _launchDrinkURL,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                  Row(children: [
                    Text(
                      widget.product.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (widget.displayBadge)
                      KewlyProductBadge(product: widget.product)
                  ],)
                ] +
                widget.product.composition
                    .map((compo) => Row(
                          children: <Widget>[
                            Text(
                              '• ',
                              style:
                                  TextStyle(fontSize: 18.0, color: Theme.of(context).primaryColor),
                            ),
                            Expanded(
                                child: Text(
                              compo.ingredient.name,
                              style: TextStyle(fontWeight: FontWeight.w300),
                            ))
                          ],
                        ))
                    .toList(growable: false)));
  }

  void _launchDrinkURL(_) async {
    var url = widget.product.link;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
