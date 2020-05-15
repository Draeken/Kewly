class IngredientDetail extend StatelessWidget {
  final Ingredient ingredient;

  IngredientDetail({Key key, @required this.ingredient}): super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(ingredient.name),
        backgroundColor: Colors.transparent,
      ),
      body: Center(child: ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          Text(ingredient.name),
          KewlyCategory(
            title: 'Vous permet de préparer',
            children: _getAvailableProducts()),
          KewlyCategory(
            title: 'Est utilisé dans',
            children: _getAllProducts()),
        ])),
      resizeToAvoidBottomInset: false,
    )
  }

  List<KewlyProductTile> _getAllProducts() {
    return ingredient.usedBy.map((product) => KewlyProductTile(product: product)).toList(growable: false);
  }

  Iterable<KewlyProductTile> _getAvailableProducts() {
    return ingredient.usedBy.where(
      (product) => product.composition.every(
        (compo) => compo.ingredient == ingredient || compo.ingredient.isOwned)).map((product) => KewlyProductTile(product: product)).toList(growable: false);
  }

}