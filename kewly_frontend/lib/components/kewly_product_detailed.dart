import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kewly/components/kewly_product_badge.dart';
import 'package:kewly/app_model.dart';
import 'package:url_launcher/url_launcher.dart';

class KewlyProductDetailed extends StatefulWidget {
  final Product product;
  final bool displayBadge;

  KewlyProductDetailed({Key key, this.product, this.displayBadge = false})
      : super(key: key);

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
        onTap: _launchDrinkURL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                  Row(
                    children: [
                      Flexible(
                          child: Text(
                        '${widget.product.name}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )),
                      if (widget.displayBadge)
                        KewlyProductBadge(product: widget.product)
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                ] +
                widget.product.composition
                    .map((compo) => Row(
                          children: <Widget>[
                            Text(
                              '• ',
                              style: TextStyle(
                                  fontSize: 18.0,
                                  color: compo.ingredient.isOwned ? Theme.of(context).primaryColor : Theme.of(context).dividerColor),
                            ),
                            Expanded(
                                child: Text(
                              compo.ingredient.name,
                              style: _getTextStyle(context, compo),
                            ))
                          ],
                        ))
                    .toList(growable: false)));
  }

  TextStyle _getTextStyle(BuildContext context, Composition compo) {
    if (compo.ingredient.isOwned) {
      return TextStyle(fontWeight: FontWeight.w300);
    }
    return TextStyle(fontWeight: FontWeight.w100, color: Colors.black87);
  }

  void _launchDrinkURL() async {
    var url = widget.product.link;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
