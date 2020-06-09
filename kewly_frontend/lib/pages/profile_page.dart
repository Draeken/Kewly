import 'package:flutter/material.dart';
import 'package:kewly/app_model.dart';
import 'package:kewly/pages/home_page.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<AppModel>();
    final List<Widget> listChildren = [
      NextToTry(model.nextToTest, model.displayMode)
    ];
    return Flexible(
        child: ListView(
      padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
      scrollDirection: Axis.vertical,
      children: listChildren,
    ));
  }
}

class NextToTry extends StatelessWidget with HandleDisplayMode {
  final List<Product> products;
  final DisplayMode displayMode;

  NextToTry(this.products, this.displayMode);

  @override
  Widget build(BuildContext context) {
    return getKewlyCategory(displayMode, 'Les prochains à tester', products);
  }
}
