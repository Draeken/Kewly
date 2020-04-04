const axios = require('axios');
const cheerio = require('cheerio');
const fs = require('fs');

const graph = {
  products: [],
  ingredients: [],
};
const toParse = [];

const fetchProducts = async (page = 1) => {
  axios(`https://www.monin.com/fr/toutes-les-recettes-monin.html?p=${page}&product_list_limit=100`)
    .then(async (response) => {
      const $ = cheerio.load(response.data);
      $('.products-grid')
        .find('.product-item')
        .each((i, product) => {
          const linkElem = $('.product-item-link', product);
          const link = linkElem.attr('href');
          const name = linkElem.text().slice(1, -1);
          const id = (i + 1) * page;
          const productObj = {
            id,
            link,
            name,
            composition: [],
          };
          graph.products.push(productObj);
        });
      console.log('finish products!', graph);
      // if (page < 13) {
      //   fetchProducts(page + 1);
      // }
      try {
        await graph.products.reduce(async (prevPromise, product) => {
          await prevPromise;
          return fetchComposition(product);
        }, Promise.resolve());
      } catch (e) {
        console.log('error', e);
      }
      console.log('finish composition!', graph);
      console.log('to parse', toParse);
      const jsonContent = JSON.stringify(graph);
      fs.writeFile('graph.json', jsonContent, 'utf-8', (err) => {
        if (!err) {
          return;
        }
        console.log('error writing graph.json', err);
      });
    })
    .catch((e) => console.log('something went wrong!', e));
};

const toMatch = `ml|morceau\(x\)|pincée de|g|grande\(s\) boule\(s\)|trait de|cuillère de|tranche\(s\)|branche\(s\)|pincé\(es\)|cuillère \(s\)|shot\(s\)|`;

const handleIngredientWithUnit = (product, content) => {
  const [quantity, unit, ingredientName] = content.split(
    /\s+(ml|morceau\(x\)|pincée de|g|grande\(s\) boule\(s\)|trait de|cuillère de|tranche\(s\)|branche\(s\)|pincé\(es\)|cuillère \(s\)|shot\(s\)|)\s+/
  );
  let ingredientObj = graph.ingredients.find((ingre) => ingre.name === ingredientName);
  if (ingredientObj == null) {
    ingredientObj = { name: ingredientName, id: graph.ingredients.length, usedBy: [] };
    graph.ingredients.push(ingredientObj);
  }
  ingredientObj.usedBy.push(product.id);
  product.composition.push({
    ingredientId: ingredientObj.id,
    quantity,
    unit,
  });
};

const fetchComposition = (product) => {
  return new Promise((resolve, reject) => {
    axios(product.link)
      .then((response) => {
        const $ = cheerio.load(response.data);
        $('.recipe_content_information')
          .find('li')
          .each((_i, ingredient) => {
            const content = $(ingredient).text();
            if (
              /\d+(\.\d+)? (ml|morceau\(x\)|pincée de|g|grande\(s\) boule\(s\)|trait de|cuillère de|tranche\(s\)|branche\(s\)|pincé\(es\)|cuillère \(s\)|shot\(s\)|) ([A-zÀ-ú]|\s)*/g.test(
                content
              )
            ) {
              handleIngredientWithUnit(product, content);
            } else {
              return toParse.push(content);
            }
            resolve();
          });
      })
      .catch((e) => reject(e));
  });
};

fetchProducts();
