const fs = require('fs'),
  path = require('path');

const graph = JSON.parse(fs.readFileSync(path.join(__dirname, 'graph.json')));
const products = graph.products;

const main = () => {
  normalizeQuantites();
  graph.ingredients = graph.ingredients.filter((ingre) => !ingre.markObsolete);
  writeFile();
};

const normalizeQuantites = () => {
  products.forEach(product => {
    product.composition.forEach(compo => {
      if (compo.unit === 'ml') {
        return;
      }
      if (compo.unit === 'pinch' || compo.unit === 'dash') {
        compo._quantity = compo.quantity * 0.62;
        return
      }
      if (compo.unit === 'large-scoop') {
        compo._quantity = compo.quantity * 130;
        return;
      }
      if (compo.unit === 'tbsp') {
        compo._quantity = compo.quantity * 15;
        return;
      }
      if (compo.unit == undefined && compo.quantity === 0) {
        compo._quantity = completeWith(product);
        return;
      }
      if (compo.unit === 'shot') {
        compo._quantity = compo.quantity * 45;
        return;
      }
      if (compo.unit === 'tsp') {
        compo._quantity = compo.quantity * 5;
        return;
      }
      if (compo.unit === 'double-shot') {
        compo._quantity = compo.quantity * 45 * 2;
        return;
      }
      if (compo.unit === 'glass') {
        compo._quantity = compo.quantity * 240;
        return;
      }
    });
  });
};

const completeWith = (product) => {
  return product.capacity / 2 - product.composition.reduce((acc, cur) => cur.unit === 'ml' ? acc + cur.quantity : acc, 0);
}

const writeFile = () => {
  const jsonContent = JSON.stringify(graph);
  // const toReview = JSON.stringify(ingredientToReview);

  fs.writeFile('graphPostProcessed.json', jsonContent, 'utf-8', (err) => {
    if (!err) {
      return;
    }
    console.log('error writing graph.json', err);
  });
  // fs.writeFile('ingredientToReview.json', toReview, 'utf-8', (err) => {
  //   if (!err) {
  //     return;
  //   }
  //   console.log('error writing graph.json', err);
  // });
};

main();
