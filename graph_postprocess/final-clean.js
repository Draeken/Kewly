const fs = require('fs'),
  path = require('path');

const graph = JSON.parse(fs.readFileSync(path.join(__dirname, 'graph.json')));
const products = graph.products;
const ingredients = graph.ingredients;

const main = () => {
  graph.instructions = undefined;
  products.forEach(product => {
    product.instructions = undefined
    if (!product.decoratedWith) {
      product.decoratedWith = [];
    }
    if (!product.tags) {
      product.tags = [];
    }    
  });
  ingredients.forEach(ingredient => {
    if (!ingredient.decorates) {
      ingredient.decorates = [];
    }
    if (!ingredient.tags) {
      ingredient.tags = [];
    }
  });
  writeFile();
};
const writeFile = () => {  
  ingredients.sort((a, b) => b.usedBy.length - a.usedBy.length);
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
