import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kewly/components/kewly_product_badge.dart';
import 'package:kewly/util.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kewly/app_model.dart';

class KewlyProductTile extends StatefulWidget {
  final Product product;
  final bool displayBadge;

  KewlyProductTile({Key key, this.product, this.displayBadge = false})
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
        onTapDown: _launchDrinkURL,
        child: Column(children: [
          Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor),
              child: CustomPaint(
                size: Size(100, 100),
                painter: ProductPainter(widget.product, _drawGlassDecor),
              ),
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

  void _launchDrinkURL(_) async {
    var url = widget.product.link;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class ProductPainter extends CustomPainter {
  final Product product;
  final bool drawGlassDeco;

  static final rand = Random();

  ProductPainter(this.product, this.drawGlassDeco);

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
    if (drawGlassDeco &&
        product.tags.contains(Tag.ice) &&
        !product.tags.contains(Tag.hot) &&
        !product.tags.contains(Tag.blended) &&
        !product.tags.contains(Tag.filtered)) {
      _drawIceCubes(canvas);
    }
  }

  @override
  bool shouldRepaint(ProductPainter oldDelegate) {
    return drawGlassDeco != oldDelegate.drawGlassDeco;
  }

  void _drawIceCubes(Canvas canvas) {
    canvas.drawPicture(GlassEffect.ice);
  }

  Color _getColor() {
    final compos = product.composition
        .where((compo) => compo.eqQuantity != null || compo.unit == 'ml')
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

  /**
   * issue: chocolate 99 & milk 1 -> would result in chocolate being blended with white 50%
   * colorConcentration * quantity should asymptotic to sum value?
   * maybe use a custom color.alphaBlend
   */
  List<Color> _getAdjustedColors(List<Composition> compos) {
    final sum = compos.fold(
        0, (acc, Composition cur) => acc + (cur.eqQuantity ?? cur.quantity));
    return compos.map((compo) {
      final quantity = compo.eqQuantity ?? compo.quantity;
      assert(quantity > 0);
      final hslColor = compo.ingredient.color;
      final quantityFactor =
          min<double>(sum, quantity * compo.ingredient.colorConcentration) /
              sum;
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
        const Offset(30, 32),
        const Offset(30, 99),
        const Offset(70, 99),
        const Offset(70, 32)
      ], false),
    Path()
      ..moveTo(33, 35)
      ..lineTo(33, 91)
      ..arcToPoint(const Offset(38, 96),
          radius: Radius.circular(5), clockwise: false)
      ..lineTo(63, 96)
      ..arcToPoint(const Offset(67, 91),
          radius: Radius.circular(5), clockwise: false)
      ..lineTo(67, 35)
  ];

  static final glass20 = [
    Path()
      ..moveTo(30, 24)
      ..lineTo(33, 99 - 5.0)
      ..arcToPoint(const Offset(38, 99),
          radius: Radius.circular(5), clockwise: false)
      ..lineTo(67 - 4.0, 99)
      ..arcToPoint(const Offset(68, 99 - 5.0),
          radius: Radius.circular(5), clockwise: false)
      ..lineTo(71, 24),
    Path()
      ..moveTo(33, 25)
      ..lineTo(36, 95 - 5.0)
      ..arcToPoint(const Offset(41, 95),
          radius: Radius.circular(5), clockwise: false)
      ..lineTo(64 - 4.0, 95)
      ..arcToPoint(const Offset(65, 95 - 5.0),
          radius: Radius.circular(5), clockwise: false)
      ..lineTo(68, 25)
  ];

  static final glass26_glass_left = Path()
    ..moveTo(27, 47)
    ..cubicTo(27, 63.5, 29.13, 88, 31, 92.5)
    ..lineTo(31.3, 94.32)
    ..arcToPoint(const Offset(36.24, 98.5),
        radius: Radius.circular(5), clockwise: false)
    ..lineTo(50, 98.5);

  static final glass26 = [
    glass26_glass_left
      ..addPath(glass26_glass_left, const Offset(100, 0),
          matrix4: Mtransform.mirrorX),
    Path()
      ..moveTo(30, 49.5)
      ..cubicTo(30, 69, 32.6, 90.5, 35, 92.5)
      ..lineTo(65, 92.5)
      ..cubicTo(67.4, 90.5, 70, 69, 70, 49.5)
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

  static final glass17_glass_left = Path()
    ..moveTo(16, 48)
    ..lineTo(45.5, 94.5)
    ..cubicTo(46.5, 96, 47, 98, 47, 100);

  static final glass17 = [
    glass17_glass_left
      ..addPath(glass17_glass_left, const Offset(100, 0),
          matrix4: Mtransform.mirrorX),
    Path()
      ..moveTo(24, 56)
      ..lineTo(45.5 - 2, 90 - 3.5)
      ..arcToPoint(const Offset(50, 90),
          radius: Radius.circular(8), clockwise: false)
      ..arcToPoint(const Offset(55.0 + 2, 90 - 3.5),
          radius: Radius.circular(8), clockwise: false)
      ..lineTo(76, 56)
  ];

  static final glass04 = [
    Path()
      ..moveTo(34, 16)
      ..lineTo(40, 99 - 5.0)
      ..arcToPoint(const Offset(45, 99),
          radius: Radius.circular(5), clockwise: false)
      ..lineTo(58 - 4.0, 99)
      ..arcToPoint(const Offset(59, 99 - 5.0),
          radius: Radius.circular(5), clockwise: false)
      ..lineTo(65, 16),
    Path()
      ..moveTo(37, 17)
      ..lineTo(42, 97 - 5.0)
      ..arcToPoint(const Offset(47, 97),
          radius: Radius.circular(5), clockwise: false)
      ..lineTo(56 - 4.0, 97)
      ..arcToPoint(const Offset(57, 97 - 5.0),
          radius: Radius.circular(5), clockwise: false)
      ..lineTo(62, 17)
  ];

  static List<Path> getGlass(int glassId) {
    switch (glassId) {
      case 1:
        return GlassPath.glass1;
      case 4:
        return GlassPath.glass04;
      case 11:
        return GlassPath.glass11;
      case 17:
        return GlassPath.glass17;
      case 20:
        return GlassPath.glass20;
      case 26:
        return GlassPath.glass26;
      case 30:
        return GlassPath.glass30;
      default:
        return GlassPath.glass17;
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
