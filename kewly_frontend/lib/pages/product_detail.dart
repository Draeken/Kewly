import 'dart:async';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kewly/app_model.dart';
import 'package:kewly/components/kewly_ingredient_tile.dart';
import 'package:kewly/components/product_paint.dart';

enum ProductAction { Available, Unavailable, Ban }

class HeroPainter extends CustomPainter {
  final Product product;

  HeroPainter(this.product);

  @override
  void paint(Canvas canvas, Size size) {
    final fillColor = ProductPaintHelper.getColor(product);
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
    canvas.drawPaint(myPaint);
    if (product.tags.contains(Tag.ice) &&
        !product.tags.contains(Tag.hot) &&
        !product.tags.contains(Tag.blended) &&
        !product.tags.contains(Tag.filtered)) {
      canvas.scale(size.longestSide / 100);
      _drawIceCubes(canvas, size);
    }
  }

  @override
  bool shouldRepaint(HeroPainter oldDelegate) {
    return false;
  }

  void _drawIceCubes(Canvas canvas, Size size) {
    canvas.drawPicture(GlassEffect.ice);
  }
}

class ProductDetail extends StatefulWidget {
  final Product product;
  final String heroKey;

  ProductDetail({Key key, @required this.product, this.heroKey})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  final _scrollController = ScrollController();
  var _isHeroExtended = true;
  var _drawHeroPainter = false;
  Timer _delayer;

  @override
  void initState() {
    super.initState();
    _delayer = Timer(Duration(milliseconds: 300), _enableHeroPainter);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels > 100) {
        // leave top
        if (_isHeroExtended) {
          setState(() {
            _isHeroExtended = false;
          });
        }
      } else {
        // reached top
        if (!_isHeroExtended) {
          setState(() {
            _isHeroExtended = true;
          });
        }
      }
    });
  }

  void _enableHeroPainter() {
    setState(() {
      _drawHeroPainter = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,

              collapseMode: CollapseMode.none,
              stretchModes: const [],
              title: Text(widget.product.name,
                  style: Theme.of(context)
                      .textTheme
                      .headline4
                      .copyWith(color: Colors.black54)),
              background: Hero(
                  tag: widget.product.heroTag + (widget.heroKey ?? ''),
                  child: AspectRatio(
                      aspectRatio: 1.618034,
                      child: _drawHeroPainter
                          ? CustomPaint(painter: HeroPainter(widget.product))
                          : Container(
                              color: ProductPaintHelper.getColor(widget.product)
                                  .withOpacity(0.8),
                            ))),
            ),
            actions: _getAppBarAction(context),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            Text('composition'),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 150),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: widget.product.composition
                    .map((e) => KewlyIngredientTile(
                          ingredient: e.ingredient,
                          heroKey: widget.product.heroTag,
                        ))
                    .toList(growable: false),
              ),
            ),
            Text('bouton : élaborer'),
          ]))
        ],
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  List<Widget> _getAppBarAction(BuildContext context) {
    return [];
  }

  List<dynamic> _actionToVisual(ProductAction action) {
    switch (action) {
      case ProductAction.Available:
        return ['en stock', Icons.add];
      case ProductAction.Unavailable:
        return ['épuisé', Icons.clear];
      case ProductAction.Ban:
        return ['banni', Icons.thumb_down];
      default:
        return ['error', Icons.error];
    }
  }

  void Function() _onAppBarAction(BuildContext context, ProductAction action) {
    return () {
      Navigator.of(context).pop();
    };
  }
}
