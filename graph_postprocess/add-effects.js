const fs = require('fs'),
  path = require('path'),
  axios = require('axios'),
  cheerio = require('cheerio');

const graph = JSON.parse(fs.readFileSync(path.join(__dirname, 'graph.json')));
const products = graph.products;
const ingredients = graph.ingredients;
const instructions = [];

const main = async () => {
  for (let i = 200; i < products.length; i++) {
    await enrichProduct(products[i]);
  }
  graph.instructions = instructions;
  const jsonContent = JSON.stringify(graph);
  fs.writeFile('graph-with-decor-and-instructions.json', jsonContent, 'utf-8', (err) => {
    if (!err) {
      return;
    }
    console.log('error writing graph.json', err);
  });
};

const enrichProduct = async (product) => {
  return axios(product.link).then((response) => {
    const $ = cheerio.load(response.data);
    const decorationNode = $('span:contains("Décoration")', '.recipe_content_information')[0];
    if (decorationNode) {
      const decoration = decorationNode.nextSibling.nodeValue;
      const decorIngredients = decoration.trim().split(/,\s/);
      product.decoratedWith = [];
      decorIngredients.forEach((ingredientName) => linkDecoration(product, ingredientName));
    }
    const instructions = $('.product-info-main-content').find('ol');
    if (instructions.length) {
      product.instructions = [];
      instructions.find('li').each((_i, instruction) => {
        const instructionName = $(instruction).text().trim();
        linkInstruction(product, instructionName);
      });
    }
  }).catch(e => {
    console.log('error', e, product.link);
  });
};

const linkInstruction = (product, instructionName) => {
  let instructionObj = instructions.find((instr) => instr.name === instructionName);
  if (instructionObj == null) {
    instructionObj = { name: instructionName, id: instructions.length, usedBy: [] };
    instructions.push(instructionObj);
  }
  instructionObj.usedBy.push(product.id);
  product.instructions.push(instructionObj.id);
}

const linkDecoration = (product, ingredientName) => {
  let ingredientObj = ingredients.find((ingre) => ingre.name === ingredientName);
  if (ingredientObj == null) {
    ingredientObj = { name: ingredientName, id: ingredients.length, usedBy: [], decorates: [] };
    ingredients.push(ingredientObj);
  }
  if (!ingredientObj.decorates) {
    ingredientObj.decorates = [product.id];
  } else {
    ingredientObj.decorates.push(product.id);
  }
  product.decoratedWith.push(ingredientObj.id);
};

main();
