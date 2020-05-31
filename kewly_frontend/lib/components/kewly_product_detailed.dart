import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kewly/util.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kewly/app_model.dart';

class KewlyProductDetailed extends StatefulWidget {
  final Product product;

  KewlyProductDetailed({Key key, this.product}) : super(key: key);

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
                  Text(
                    widget.product.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ] +
                widget.product.composition
                    .map((compo) => Row(
                          children: <Widget>[
                            Text(
                              '• ',
                              style: TextStyle(
                                fontSize: 18.0,
                                  color: Theme.of(context).primaryColor),
                            ),
                            Expanded(child: Text(
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
