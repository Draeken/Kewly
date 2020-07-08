import 'package:flutter/material.dart';
import 'package:kewly/app_model.dart';
import 'package:kewly/components/kewly_ingredient_tile.dart';
import 'package:kewly/components/kewly_product_tile.dart';

enum ProductAction { Available, Unavailable, Ban }

class ProductDetail extends StatefulWidget {
  final Product product;
  final String heroKey;

  ProductDetail({Key key, @required this.product, this.heroKey}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  final _scrollController = ScrollController();
  var _isHeroExtended = true;

  @override
  void initState() {
    super.initState();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              collapseMode: CollapseMode.none,
              stretchModes: const [],
              title: Text(widget.product.name,
                  style: Theme.of(context).textTheme.headline4.copyWith(color: Colors.black54)),
              background: Hero(
                  tag: widget.product.heroTag + (widget.heroKey ?? ''),
                  child: AspectRatio(
                      aspectRatio: 1.618034,
                      child: CustomPaint(painter: ProductPainter(widget.product, true)))),
            ),
            actions: _getAppBarAction(context),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            Text('composition'),
            ListView(
              children: widget.product.composition
                  .map((e) => KewlyIngredientTile(
                        ingredient: e.ingredient,
                      ))
                  .toList(growable: false),
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
