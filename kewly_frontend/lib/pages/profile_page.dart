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
          children: model.noGo.map((e) => KewlyFilterChip(e.ingredient.name, false, () => {})).toList(growable: false))
    ];
    return Flexible(
        child: ListView(
      padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
      scrollDirection: Axis.vertical,
      children: listChildren,
    ));
  }
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
