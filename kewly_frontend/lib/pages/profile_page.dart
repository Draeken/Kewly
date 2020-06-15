import 'package:flutter/material.dart';
import 'package:kewly/app_model.dart';
import 'package:kewly/components/kewly_filter_chip.dart';
import 'package:kewly/components/kewly_wrap_category.dart';
import 'package:kewly/pages/home_page.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<AppModel>();
    final Set<Product> triedProducts = model.historic.toSet();
    final List<Product> toReview = triedProducts
        .where((tried) => model.reviewedProducts.every((reviewed) => reviewed.product != tried))
        .toList(growable: false);
    final List<Widget> listChildren = [
      ProfileCategory(
        model.nextToTest,
        model.displayMode,
        'Les prochains à tester',
        maxCrossAxisCount: 2,
      ),
      ProfileCategory(
        triedProducts.toList(growable: false),
        model.displayMode,
        'Mes expériences',
        maxCrossAxisCount: 2,
      ),
      ProfileCategory(
        toReview,
        model.displayMode,
        'À noter',
        maxCrossAxisCount: 1,
      ),
      ProfileCategory(
        model.historic,
        model.displayMode,
        'Historique',
        maxCrossAxisCount: 1,
      ),
      KewlyWrapCategory(
          title: 'Vos bannis',
          children: model.noGo
              .map((e) => KewlyFilterChip(e.ingredient.name, false, () => {}))
              .toList(growable: false))
    ];
    return ListView(
      padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
      scrollDirection: Axis.vertical,
      children: listChildren,
    );
  }
}

class NoGoCategory extends StatelessWidget {
  final List<NoGo> noGos;

  NoGoCategory(this.noGos);

  @override
  Widget build(BuildContext context) {
    final List<NoGo> noGoTags = [];
    final List<NoGo> noGoIngredients = [];
    for (final noGo in this.noGos) {
      if (noGo.ingredient != null) {
        noGoIngredients.add(noGo);
      } else {
        noGoTags.add(noGo);
      }
    }

    final List<KewlyFilterChip> tags = [
      KewlyFilterChip(
          'Alcool', false, () => context.read<AppModel>().addNoGoTagExclusive(Tag.alcohol)),
      KewlyFilterChip('Chaud', false, () => context.read<AppModel>().addNoGoTagExclusive(Tag.hot)),
      KewlyFilterChip('Glacé', false, () => context.read<AppModel>().addNoGoTagExclusive(Tag.ice)),
      KewlyFilterChip(
          'Pétillant', false, () => context.read<AppModel>().addNoGoTagExclusive(Tag.sparkling)),
    ];
    for (final noGo in noGoTags) {
      final label = _tagToString(noGo.tag);
      tags.removeWhere((element) => element.label == label);
      tags.add(KewlyFilterChip(label, true, () => context.read<AppModel>().removeNoGo(noGo)));
    }
    final List<Widget> ingredients = noGoIngredients
        .map((e) => Chip(
            label: Text(e.ingredient.name),
            backgroundColor: Colors.white,
            onDeleted: () => context.read<AppModel>().removeNoGo(e),
            shape: _getChipShape()))
        .toList(growable: false);

    return KewlyWrapCategory(title: 'Vos bannis', children: tags + ingredients);
  }

  String _tagToString(String tag) {
    switch (tag) {
      case Tag.alcohol:
        return 'Alcool';
      case Tag.hot:
        return 'Chaud';
      case Tag.ice:
        return 'Glacé';
      case Tag.sparkling:
        return 'Pétillant';
      default:
        return '$tag is unknown';
    }
  }

  ShapeBorder _getChipShape() => RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15), side: BorderSide(width: 1.5, color: Colors.black38));
}

class ProfileCategory extends StatelessWidget with HandleDisplayMode {
  final List<Product> products;
  final DisplayMode displayMode;
  final String title;
  final int maxCrossAxisCount;

  ProfileCategory(this.products, this.displayMode, this.title, {this.maxCrossAxisCount});

  @override
  Widget build(BuildContext context) {
    return getKewlyCategory(displayMode, this.title, products,
        maxCrossAxisCount: maxCrossAxisCount);
  }
}
