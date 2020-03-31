import 'package:flutter/material.dart';
import 'package:kewly/app_model.dart';
import 'package:kewly/components/kewly_search.dart';
import 'package:provider/provider.dart';

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
          children: <Widget>[
            DrawerHeader(
              child: Text('Kewly'),
            ),
            ListTile(
              title: Text('Mes ingrédients'),
              onTap: () => Navigator.pushNamed(context, '/ingredients'),
            ),
            ListTile(title: Text('Mes courses'))
          ],
        ),
      ),
      body: Center(
        child: Consumer<AppModel>(
          builder: (_, appModel, __) {
            return ListView(
              children: appModel.products
                  .map((product) => Text("product: ${product.name}"))
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}
