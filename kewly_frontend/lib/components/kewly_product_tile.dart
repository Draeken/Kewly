import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kewly/util.dart';
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
              decoration: BoxDecoration(color: Colors.white),
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

class ProductPainter extends CustomPainter {
  final Product product;

  static final rand = Random();

  ProductPainter(this.product);

  @override
  void paint(Canvas canvas, Size size) {
    final fillColor = _getColor();
    final myPaint = Paint()..style = PaintingStyle.fill;

    if (fillColor.alpha < 255) {
      final hslColor = HSLColor.fromColor(fillColor);
      myPaint.shader = ui.Gradient.linear(Offset(0, 85), Offset(0, 15), [
        fillColor,
        hslColor.withLightness(max(0, hslColor.lightness - 0.15)).toColor()
      ]);
    } else {
      myPaint.color = fillColor;
    }

    final glassPaths = GlassPath.getGlass(product.glass);
    canvas.drawPath(glassPaths[1], myPaint);
    canvas.drawPath(
        glassPaths[0],
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..color = Colors.black26
          ..strokeWidth = 2);

    canvas.clipPath(glassPaths[1]);
    if (product.tags.contains(Tag.ice) &&
        !product.tags.contains(Tag.hot) &&
        !product.tags.contains(Tag.blended) &&
        !product.tags.contains(Tag.filtered)) {
      _drawIceCubes(canvas);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }

  void _drawIceCubes(Canvas canvas) {
    canvas.drawPicture(GlassEffect.ice);
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
    final sum =
        compos.fold(0, (acc, cur) => acc + (cur.eqQuantity ?? cur.quantity));
    final capacity = ((product.capacity ?? 0) > sum) ? product.capacity : sum;
    final quantities = compos
        .map((compo) => (compo.eqQuantity ?? compo.quantity) / capacity)
        .toList();

    for (var i = 1; i < quantities.length; i++) {
      quantities[i] = quantities[i] + quantities[i - 1];
    }
    return quantities;
  }

  List<Color> _getAdjustedColors(List<Composition> compos) {
    final sum = compos.fold(
        0, (acc, Composition cur) => acc + (cur.eqQuantity ?? cur.quantity));
    return compos.map((compo) {
      final quantity = compo.eqQuantity ?? compo.quantity;
      final hslColor = compo.ingredient.color;
      final quantityFactor = min<double>(sum, quantity * 1.5) / sum;
      final maxLightness = 1 - hslColor.lightness;
      final newLightness = maxLightness * quantityFactor;
      return hslColor.withLightness(1 - newLightness).toColor();
    }).toList();
  }
}

class GlassPath {
  // could use Path.transform to scale up/down
  static final glass1 = [
    Path()
      ..moveTo(15, 15)
      ..lineTo(25, 85)
      ..lineTo(100.0 - 25, 85)
      ..lineTo(100.0 - 15, 15),
    Path()
      ..moveTo(15, 15)
      ..lineTo(25, 85)
      ..lineTo(100.0 - 25, 85)
      ..lineTo(100.0 - 15, 15)
  ];

  static final glass11 = [
    Path()
      ..addPolygon(const [
        const Offset(22, 8),
        const Offset(22, 93),
        const Offset(78, 93),
        const Offset(78, 8)
      ], false),
    Path()
      ..moveTo(27, 14)
      ..lineTo(27, 83)
      ..arcToPoint(const Offset(32, 88),
          radius: Radius.circular(5), clockwise: false)
      ..lineTo(68, 88)
      ..arcToPoint(const Offset(73, 83),
          radius: Radius.circular(5), clockwise: false)
      ..lineTo(73, 14)
  ];

  static final glass20 = [
    Path()
      ..moveTo(25, 4)
      ..lineTo(29, 93 - 5.0)
      ..arcToPoint(const Offset(34, 93),
          radius: Radius.circular(5), clockwise: false)
      ..lineTo(69 - 4.0, 93)
      ..arcToPoint(const Offset(70, 93 - 5.0),
          radius: Radius.circular(5), clockwise: false)
      ..lineTo(74, 4),
    Path()
      ..moveTo(28, 6)
      ..lineTo(32, 88 - 5.0)
      ..arcToPoint(const Offset(37, 88),
          radius: Radius.circular(5), clockwise: false)
      ..lineTo(66 - 4.0, 88)
      ..arcToPoint(const Offset(67, 88 - 5.0),
          radius: Radius.circular(5), clockwise: false)
      ..lineTo(71, 6)
  ];

  static final glass26_glass_left = Path()
    ..moveTo(27, 23.5)
    ..cubicTo(27, 40, 29.13, 64.5, 31, 69)
    ..lineTo(31.3, 70.82)
    ..arcToPoint(const Offset(36.24, 75),
        radius: Radius.circular(5), clockwise: false)
    ..lineTo(50, 75);

  static final glass26 = [
    glass26_glass_left
      ..addPath(glass26_glass_left, const Offset(100, 0),
          matrix4: Mtransform.mirrorX),
    Path()
      ..moveTo(30, 26)
      ..cubicTo(29, 45.5, 32.6, 67, 35, 69)
      ..lineTo(65, 69)
      ..cubicTo(67.4, 67, 70, 45.5, 70, 26)
  ];

  static final glass30_glass_left = Path()
    ..moveTo(24, 28.5)
    ..cubicTo(-13, 79.5, 47, 87, 47, 100);

  static final glass30 = [
    glass30_glass_left
      ..addPath(glass30_glass_left, const Offset(100, 0),
          matrix4: Mtransform.mirrorX),
    Path()
      ..moveTo(27, 31)
      ..cubicTo(-7, 70.5, 44.5, 91, 50, 91)
      ..cubicTo(56, 91, 107.5, 71.5, 72.5, 31)
  ];

  static List<Path> getGlass(int glassId) {
    switch (glassId) {
      case 1:
        return GlassPath.glass1;
      case 11:
        return GlassPath.glass11;
      case 20:
        return GlassPath.glass20;
      case 26:
        return GlassPath.glass26;
      case 30:
        return GlassPath.glass30;
      default:
        return GlassPath.glass30;
    }
  }
}

class GlassEffect {
  static _getEffectIce() {
    final pictureRecorded = ui.PictureRecorder();
    final canvas = ui.Canvas(pictureRecorded);
    final bounds = Rect.fromLTWH(0, 0, 100, 100);
    final rand = Random();
    final iceCubeTemplate = Path()
      ..moveTo(-8, -6)
      ..lineTo(-7.5, 8)
      ..lineTo(6.5, 7.5)
      ..lineTo(7.5, -7)
      ..close();

    final boundOffset = bounds.topLeft + Offset(7.75, 7.5);
    final maxOnX = (bounds.width / 15.5).ceil();
    final maxOnY = (bounds.height / 15).ceil();
    for (var i = 0; i < maxOnY; i++) {
      final xOffset = rand.nextDouble() * 15 - 7.5;
      for (var j = 0; j < maxOnX; j++) {
        final yOffset = rand.nextDouble() * 3 - 1.5;
        final position =
            boundOffset + Offset(16.0 * j + xOffset, 16.0 * i + yOffset);
        final iceCube = iceCubeTemplate
            .transform(Matrix4.rotationZ(rand.nextDouble() * 2 * pi).storage)
            .shift(position);
        canvas.drawPath(
            iceCube,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeJoin = StrokeJoin.round
              ..color = Colors.black
              ..strokeWidth = 0.03);
        canvas.drawPath(
            iceCube,
            Paint()
              ..style = PaintingStyle.fill
              ..shader = ui.Gradient.linear(
                  position, position.translate(16, 16), [
                Colors.white.withOpacity(rand.nextDouble()),
                Colors.transparent
              ])
              ..blendMode = BlendMode.softLight
              ..maskFilter = MaskFilter.blur(BlurStyle.inner, 3));
      }
    }
    return pictureRecorded.endRecording();
  }

  static final ui.Picture ice = _getEffectIce();
}
