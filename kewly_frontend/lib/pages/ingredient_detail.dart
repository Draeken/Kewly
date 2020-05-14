class IngredientDetail extend StatelessWidget {
  final Ingredient ingredient;

  IngredientDetail({Key key, @required this.ingredient}): super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(ingredient.name)
      ),
      body: Center(child: Text(ingredient.name)),
      resizeToAvoidBottomInset: false,
    )
  }

  List<Product> _getAllProducts() {
    return ingredient.usedBy;
  }

  Iterable<Product> _getAvailableProducts() {
    return ingredient.usedBy.where(
      (product) => product.composition.every(
        (compo) => compo.ingredient == ingredient || compo.ingredient.isOwned));
  }

}