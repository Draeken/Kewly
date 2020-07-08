import 'package:flutter/material.dart';
import 'package:kewly/app_model.dart';
import 'package:kewly/components/kewly_category.dart';
import 'package:kewly/components/kewly_ingredient_tile.dart';
import 'package:kewly/components/kewly_product_detailed.dart';
import 'package:kewly/components/kewly_product_tile.dart';
import 'package:provider/provider.dart';

enum IngredientAction { Available, Unavailable, Ban }

class IngredientDetail extends StatefulWidget {
  final Ingredient ingredient;
  final String heroKey;

  IngredientDetail({Key key, @required this.ingredient, this.heroKey})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _IngredientDetailState();
}

class _IngredientDetailState extends State<IngredientDetail> {
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
    final List<IngredientAction> actions = [
      if (widget.ingredient.isOwned)
        IngredientAction.Unavailable
      else ...[IngredientAction.Available, IngredientAction.Ban]
    ];
    final List<Widget> widgets = [];
    if (_isHeroExtended) {
      for (var i = 0; i < actions.length; i++) {
        final action = actions[i];
        final visual = _ingredientActionToVisual(action);
        widgets.addAll([
          ActionChip(
            label: Text(visual[0], style: TextStyle(color: Colors.black87)),
            onPressed: _onAppBarAction(context, action),
            backgroundColor: Colors.black26,
            avatar: Icon(
              visual[1],
              color: Colors.black87,
            ),
          ),
          if (i < actions.length - 1)
            SizedBox(
              width: 8,
            )
        ]);
      }
    } else {
      widgets.add(PopupMenuButton<IngredientAction>(
          onSelected: (action) => _onAppBarAction(context, action)(),
          itemBuilder: (BuildContext context) => actions.map((action) {
                final visual = _ingredientActionToVisual(action);
                return PopupMenuItem<IngredientAction>(
                    value: action,
                    child: ListTile(
                      leading: Icon(visual[1]),
                      title: visual[0],
                    ));
              }).toList(growable: false)));
    }
    return widgets;
  }

  List<dynamic> _ingredientActionToVisual(IngredientAction action) {
    switch (action) {
      case IngredientAction.Available:
        return ['en stock', Icons.add];
      case IngredientAction.Unavailable:
        return ['épuisé', Icons.clear];
      case IngredientAction.Ban:
        return ['banni', Icons.thumb_down];
      default:
        return ['error', Icons.error];
    }
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
                heroKey: widget.ingredient.heroTag + 'all',
                product: product,
                displayBadge: true,
              )
            : KewlyProductTile(
                heroKey: widget.ingredient.heroTag + 'all',
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
                heroKey: widget.ingredient.heroTag + 'available',
                product: product,
              )
            : KewlyProductTile(
                heroKey: widget.ingredient.heroTag + 'available',
                product: product))
        .toList(growable: false);
  }
}
