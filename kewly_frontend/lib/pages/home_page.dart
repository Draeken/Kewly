import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kewly/app_model.dart';
import 'package:kewly/components/kewly_category_title.dart';
import 'package:kewly/components/kewly_product_tile.dart';
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
              onTap: () {
                Navigator.of(context).popAndPushNamed('/ingredients');
                // Navigator.pushNamed(context, '/ingredients')
              },
            ),
            ListTile(title: Text('Mes courses'))
          ],
        ),
      ),
      body: Center(
        child: Consumer<AppModel>(
          builder: (_, appModel, __) {
            /*var products = appModel.products.where((product) => product.composition.every(
                (ingredient) => appModel.userData.ownedIngredients
                    .contains(ingredient.ingredientId))).toList();*/
            var products = appModel.products.where((product) {
              var nbOfOwned = product.composition.fold(0, (acc, ingredient) => appModel.userData.ownedIngredients
                  .contains(ingredient.ingredientId) ? acc + 1 : acc);
              return nbOfOwned == product.composition.length - 1;
            }).toList();
            return AllYourProducts(products: products);
          },
        ),
      ),
    );
  }
}

class AllYourProducts extends StatelessWidget {
  final List<Product> products;

  AllYourProducts({this.products});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        KewlyCategoryTitle('Toutes vos boissons'),
        Flexible(
            child: GridView.count(
              primary: false,
              crossAxisCount: 4,
              scrollDirection: Axis.horizontal,
              children:
              products.map((product) => KewlyProductTile(product)).toList(),
            )),
      ],
    );
  }
}
