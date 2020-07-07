import 'package:flutter/material.dart';
import 'package:kewly/app_model.dart';
import 'package:kewly/components/kewly_product_badge.dart';
import 'package:kewly/pages/product_detail.dart';

class ColumnWithOverflow extends StatelessWidget {
  final int maxItems;
  final List<Widget> children;

  ColumnWithOverflow({this.maxItems, this.children});

  @override
  Widget build(BuildContext context) {
    if (children.length > maxItems) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children.take(maxItems).toList(growable: false),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class KewlyProductDetailed extends StatefulWidget {
  final Product product;
  final bool displayBadge;
  final String heroKey;

  KewlyProductDetailed({Key key, this.product, this.displayBadge = false, this.heroKey})
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
    final List<Widget> composition = [];
    for (final compo in widget.product.composition) {
      if (!compo.ingredient.isOwned) {
        composition.insert(0, _compoToRow(compo, context));
      } else {
        composition.add(_compoToRow(compo, context));
      }
    }
    return GestureDetector(
        onTap: _launchDrinkURL,
        child: Hero(
            tag: widget.product.heroTag + (widget.heroKey ?? ''),
            child: ColumnWithOverflow(
                maxItems: 6,
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
                          if (widget.displayBadge) KewlyProductBadge(product: widget.product)
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                    ] +
                    composition)));
  }

  Row _compoToRow(Composition compo, BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          '• ',
          style: TextStyle(
              fontSize: 18.0,
              color: compo.ingredient.isOwned
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).dividerColor),
        ),
        Expanded(
            child: Text(
          compo.ingredient.name,
          style: _getTextStyle(context, compo),
        ))
      ],
    );
  }

  TextStyle _getTextStyle(BuildContext context, Composition compo) {
    if (compo.ingredient.isOwned) {
      return TextStyle(fontWeight: FontWeight.w300);
    }
    return TextStyle(fontWeight: FontWeight.w100, color: Colors.black87);
  }

  void _launchDrinkURL() async {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetail(product: widget.product, heroKey: widget.heroKey),
        ));
  }
}
