import 'package:flutter/material.dart';
import 'package:kewly/components/kewly_search.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: KewlySearch(),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Go to your profile',
            onPressed: () {},
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: const <Widget>[
            DrawerHeader(
              child: Text('Kewly'),
            ),
            ListTile(
              title: Text('Mes ingrédients'),
            ),
            ListTile(
                title: Text('Mes courses')
            )
          ],
        ),
      ),
    );
  }
}