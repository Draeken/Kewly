import 'dart:ui' as ui;

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
                      width: 2, color: Theme.of(context).dividerColor),
                  color: Theme.of(context).primaryColor),
              child: CustomPaint(
                size: Size(100, 100),
                painter: ProductPainter(product),
              ),
              height: 100.0,
              width: 100.0),
          Text(
            '${product.name}',
            textAlign: TextAlign.center,
          ),
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

class ProductPainter extends CustomPainter {
  final Product product;

  ProductPainter(this.product);

  @override
  void paint(Canvas canvas, Size size) {
    final myPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.linear(Offset(0, 85), Offset(0, 15),
          const <Color>[Colors.cyanAccent, Colors.amberAccent])
      ..strokeWidth = 2;
    final myPath = Path()
      ..moveTo(15, 15)
      ..lineTo(25, 85)
      ..lineTo(100.0 - 25, 85)
      ..lineTo(100.0 - 15, 15)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(myPath, myPaint);
    canvas.drawPath(myPath, Paint()..style = PaintingStyle.stroke..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}
