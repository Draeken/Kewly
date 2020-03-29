import 'package:flutter/material.dart';
import 'package:kewly/pages/home_page.dart';
import 'package:kewly/pages/search_page.dart';

import './theme.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Kewly',
        theme: appTheme,
        home: HomePage(),
        routes: {'/search': (BuildContext context) => SearchPage()});
  }
}
