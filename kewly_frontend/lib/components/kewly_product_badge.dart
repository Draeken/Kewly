import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:kewly/app_model.dart';

class KewlyProductBadge extends StatelessWidget {
  final Product product;

  KewlyProductBadge({this.product});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: ProductBadgePainter(product), size: Size(20, 20),);
  }
}

class ProductBadgePainter extends CustomPainter {
  final Product product;

  ProductBadgePainter(this.product);

  @override
  void paint(Canvas canvas, Size size) {
    final missingIngredients = _getMissingIngredientCount();
    if (missingIngredients == "0") {
      return;
    }
    final myPaint = Paint()..style = PaintingStyle.fill;
    myPaint.color = Colors.red[700];
    canvas.drawPath(computeBadgePath(size), myPaint);

    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: missingIngredients, style: TextStyle(color: Colors.white.withOpacity(0.9))),
          textAlign: TextAlign.center,
      textDirection: TextDirection.ltr
    )..layout(maxWidth: size.width / 1.5);
    textPainter.paint(canvas, Offset(size.width / 2 - textPainter.width / 2, size.height - textPainter.height));
  }

  @override
  bool shouldRepaint(ProductBadgePainter oldDelegate) {
    return false;
  }

  Path computeBadgePath(Size size) {
    return Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();
  }

  String _getMissingIngredientCount() {
    return product.composition
        .fold(0, (prev, cur) => prev + (cur.ingredient.isOwned ? 0 : 1))
        .toString();
  }
}
