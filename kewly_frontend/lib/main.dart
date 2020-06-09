import 'package:flutter/material.dart';
import 'package:kewly/app_model.dart';
import 'package:kewly/pages/home_page.dart';
import 'package:kewly/pages/ingredient_page.dart';
import 'package:kewly/pages/profile_page.dart';
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
            home: KewlyHome(),
          )
    );
  }
}

class KewlyHome extends StatefulWidget {
  KewlyHome({Key key}) : super(key: key);

  @override
  _KewlyHomeState createState() => _KewlyHomeState();
}

class _KewlyHomeState extends State<KewlyHome> {
  int _navIndex = 0;
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  static List<Widget> _pages = <Widget>[
    HomePage(),
    IngredientPage(),
    ProfilePage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Theme.of(context).primaryColor,
          selectedItemColor: Colors.white,
          currentIndex: _navIndex,
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              title: Text('Les boissons'),
              icon: Icon(Icons.local_bar),
            ),
            BottomNavigationBarItem(
              title: Text('Vos produits'),
              icon: Icon(Icons.local_drink),
            ),
            BottomNavigationBarItem(
              title: Text('Votre panier'),
              icon: Icon(Icons.shopping_cart),
            ),
            BottomNavigationBarItem(
              title: Text('À goûter'),
              icon: Icon(Icons.bookmark_border),
            ),
          ]),
      body: PageView(
        controller: _pageController,
        children: _pages
      ),
      resizeToAvoidBottomInset: true,
    );
  }

  void _onItemTapped(int index) {
    if (index > 2 || index == _navIndex) {
      return;
    }
    setState(() {
      _navIndex = index;
      _pageController.animateToPage(index, duration: Duration(milliseconds: 230), curve: Curves.easeOut);
    });
  }
}
