import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kewly/components/kewly_product_badge.dart';
import 'package:kewly/components/product_paint.dart';
import 'package:kewly/pages/product_detail.dart';
import 'package:kewly/app_model.dart';

class KewlyProductTile extends StatefulWidget {
  final Product product;
  final bool displayBadge;
  final String heroKey;

  KewlyProductTile({Key key, this.product, this.displayBadge = false, this.heroKey})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _KewlyProductTile();
}

class _KewlyProductTile extends State<KewlyProductTile> {
  bool _drawGlassDecor = false;
  Timer delayer;

  @override
  void initState() {
    super.initState();
    delayer = Timer(Duration(seconds: 1), _enableGlassDecor);
  }

  @override
  void dispose() {
    delayer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: _launchDrinkURL,
        child: Column(children: [
          Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor),
              child: Hero(tag: widget.product.heroTag + (widget.heroKey ?? ''), child: CustomPaint(
                size: Size(100, 100),
                painter: ProductPainter(widget.product, _drawGlassDecor),
              )),
              height: 104.0,
              width: 104.0),
          Row(
            children: [
              Flexible(
                  child: Text(
                '${widget.product.name}',
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
        ]));
  }

  void _enableGlassDecor() {
    setState(() {
      _drawGlassDecor = true;
    });
  }

  void _launchDrinkURL() async {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetail(product: widget.product, heroKey: widget.heroKey),
        ));
  }
}
