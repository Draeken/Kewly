import 'dart:math';
import 'dart:ui' as ui;
import 'dart:developer' as dev;

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
                  color: Colors.white),
              child: CustomPaint(
                size: Size(100, 100),
                painter: ProductPainter(product),
              ),
              height: 104.0,
              width: 104.0),
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

class GlassPath {
  static final glass1 = [
    Path()
      ..moveTo(15, 15)
      ..lineTo(25, 85)
      ..lineTo(100.0 - 25, 85)
      ..lineTo(100.0 - 15, 15)
      ..fillType = PathFillType.evenOdd,
    Path()
      ..moveTo(15, 15)
      ..lineTo(25, 85)
      ..lineTo(100.0 - 25, 85)
      ..lineTo(100.0 - 15, 15)
      ..fillType = PathFillType.evenOdd
  ];

  static final glass11 = [
    Path()
      ..addPolygon(const [
        const Offset(22, 8),
        const Offset(22, 93),
        const Offset(78, 93),
        const Offset(78, 8)
      ], false)
      ..fillType = PathFillType.evenOdd,
    Path()
      ..moveTo(27, 14)
      ..lineTo(27, 83)
      ..arcToPoint(const Offset(32, 88), radius: Radius.circular(5), clockwise: false)
      ..lineTo(68, 88)
      ..arcToPoint(const Offset(73, 83), radius: Radius.circular(5), clockwise: false)
      ..lineTo(73, 14)
      ..fillType = PathFillType.evenOdd
  ];

  static List<Path> getGlass(int glassId) {
    switch (glassId) {
      case 1:
        return GlassPath.glass1;
      default:
        return GlassPath.glass11;
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
      ..color = _getColor()
      ..strokeWidth = 2;

    final glassPaths = GlassPath.getGlass(product.glass);
    canvas.drawPath(glassPaths[1], myPaint);
    canvas.drawPath(
        glassPaths[0],
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }

  Color _getColor() {
    final compos = product.composition
        .where((compo) => compo.unit == 'ml')
        .toList(growable: false);
    final colors = _getAdjustedColors(compos);
    if (colors.isEmpty) {
      return Colors.transparent;
    }
    return colors.reduce((acc, cur) => Color.alphaBlend(acc, cur));
  }

  _getGradient() {
    final compos = product.composition
        .where((compo) => compo.unit == 'ml')
        .toList(growable: false);
    final colors = compos
        .map((compo) => compo.ingredient.color.toColor())
        .toList(growable: false);
    final colorStops = _getColorStops(compos);
    return ui.Gradient.linear(Offset(0, 85), Offset(0, 15), colors, colorStops);
  }

  List<double> _getColorStops(List<Composition> compos) {
    final sum = compos.fold(0, (acc, cur) => acc + cur.quantity);
    final capacity = ((product.capacity ?? 0) > sum) ? product.capacity : sum;
    final quantities =
        compos.map((compo) => compo.quantity / capacity).toList();

    for (var i = 1; i < quantities.length; i++) {
      quantities[i] = quantities[i] + quantities[i - 1];
    }
    return quantities;
  }

  List<Color> _getAdjustedColors(List<Composition> compos) {
    final sum = compos.fold(0, (acc, cur) => acc + cur.quantity);
    return compos.map((compo) {
      final hslColor = compo.ingredient.color;
      final quantityFactor = min<double>(sum, compo.quantity * 1.5) / sum;
      final maxLightness = 1 - hslColor.lightness;
      final newLightness = maxLightness * quantityFactor;
      return hslColor.withLightness(1 - newLightness).toColor();
    }).toList();
  }
}
