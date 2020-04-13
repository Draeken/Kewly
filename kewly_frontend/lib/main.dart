import 'package:flutter/material.dart';
import 'package:kewly/app_model.dart';
import 'package:kewly/pages/home_page.dart';
import 'package:kewly/pages/ingredient_page.dart';
import 'package:provider/provider.dart';

import './theme.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => AppModel(context),
        child: MaterialApp(
            title: 'Kewly',
            theme: appTheme,
            initialRoute: '/',
            routes: {
              '/': (BuildContext context) => HomePage(),
              '/ingredients': (BuildContext context) => IngredientPage(),
              '/cart': (BuildContext context) => HomePage(),
              '/profile': (BuildContext context) => HomePage(),
            }));
  }
}
