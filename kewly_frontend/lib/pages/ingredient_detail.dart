import 'package:flutter/material.dart';
import 'package:kewly/app_model.dart';
import 'package:kewly/components/kewly_category.dart';
import 'package:kewly/components/kewly_ingredient_tile.dart';
import 'package:kewly/components/kewly_product_detailed.dart';
import 'package:kewly/components/kewly_product_tile.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;

enum IngredientAction { Available, Unavailable, Ban }

class IngredientDetail extends StatefulWidget {
  final Ingredient ingredient;
  final String heroKey;

  IngredientDetail({Key key, @required this.ingredient, this.heroKey}): super(key: key);

  @override
  State<StatefulWidget> createState() => _IngredientDetailState();
}

class _IngredientDetailState extends State<IngredientDetail> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (!_scrollController.position.atEdge) {
        return;
      }
      if (_scrollController.position.pixels == 0) {
        developer.log('TO TOP');
      } else {
        developer.log('TO BOTTOM');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayMode =
        context.select<AppModel, DisplayMode>((AppModel a) => a.displayMode);
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
              title: Text(widget.ingredient.name,
                  style: Theme.of(context)
                      .textTheme
                      .headline4
                      .copyWith(color: _getHeroTitleColor())),
              background: Hero(
                  tag: widget.ingredient.heroTag + (widget.heroKey ?? ''),
                  child: AspectRatio(
                      aspectRatio: 1.618034,
                      child: KewlyIngredientVisual(
                        widget.ingredient,
                        width: null,
                        height: null,
                      ))),
            ),
            actions: _getAppBarAction(context),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            KewlyCategory(
                title: 'Vous permet de préparer',
                children: _getAvailableProducts(displayMode)),
            KewlyCategory(
                title: 'Est utilisé dans',
                children: _getAllProducts(displayMode)),
          ]))
        ],
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  List<Widget> _getAppBarAction(BuildContext context) {
    return widget.ingredient.isOwned
        ? <Widget>[
            ActionChip(
                label: Text(
                  'épuisé',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Theme.of(context).accentColor,
                avatar: Icon(
                  Icons.clear,
                  color: Colors.white,
                ),
                onPressed:
                    _onAppBarAction(context, IngredientAction.Unavailable))
          ]
        : <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ActionChip(
                    label: Text(
                      'en stock',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Theme.of(context).accentColor,
                    avatar: Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    onPressed:
                        _onAppBarAction(context, IngredientAction.Available)),
                SizedBox(
                  width: 8,
                ),
                ActionChip(
                    label: Text(
                      'banni',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Theme.of(context).accentColor,
                    avatar: Icon(
                      Icons.thumb_down,
                      color: Colors.white,
                    ),
                    onPressed: _onAppBarAction(context, IngredientAction.Ban))
              ],
            )
          ];
  }

  void Function() _onAppBarAction(
      BuildContext context, IngredientAction action) {
    return () {
      final appModel = context.read<AppModel>();
      switch (action) {
        case IngredientAction.Available:
          appModel.addOwnedIngredient(widget.ingredient);
          break;
        case IngredientAction.Ban:
          appModel.addNoGoIngredient(widget.ingredient);
          break;
        case IngredientAction.Unavailable:
          appModel.removeOwnedIngredient(widget.ingredient);
      }
      Navigator.of(context).pop();
    };
  }

  Color _getHeroTitleColor() {
    final luminance = widget.ingredient.color.toColor().computeLuminance();
    return luminance > 0.14 || luminance == 0.0
        ? Colors.black54
        : Colors.white70;
  }

  List<Widget> _getAllProducts(DisplayMode display) {
    return widget.ingredient.usedBy
        .map((product) => display == DisplayMode.Detailed
            ? KewlyProductDetailed(
                product: product,
                displayBadge: true,
              )
            : KewlyProductTile(
                product: product,
                displayBadge: true,
              ))
        .toList(growable: false);
  }

  List<Widget> _getAvailableProducts(DisplayMode display) {
    return widget.ingredient.usedBy
        .where((product) => product.composition.every((compo) =>
            compo.ingredient == widget.ingredient || compo.ingredient.isOwned))
        .map((product) => display == DisplayMode.Detailed
            ? KewlyProductDetailed(
                product: product,
              )
            : KewlyProductTile(product: product))
        .toList(growable: false);
  }
}
