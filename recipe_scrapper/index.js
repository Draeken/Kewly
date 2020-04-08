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
          const id = i + 100 * (page - 1);
          const productObj = {
            id,
            link,
            name,
            composition: [],
          };
          graph.products.push(productObj);
        });
      console.log('finish products!');
      if (page < 13) {
        fetchProducts(page + 1);
        return;
      }
      try {
        await graph.products.reduce(async (prevPromise, product) => {
          await prevPromise;
          return fetchComposition(product);
        }, Promise.resolve());
      } catch (e) {
        console.log('error', e);
      }
      console.log('finish composition!');
      console.log('to parse', toParse);
      const jsonContent = JSON.stringify(graph);
      const jsonToParse = JSON.stringify(toParse);
      fs.writeFile('graph.json', jsonContent, 'utf-8', (err) => {
        if (!err) {
          return;
        }
        console.log('error writing graph.json', err);
      });
      fs.writeFile('toParse.json', jsonToParse, 'utf-8', (err) => {
        if (!err) {
          return;
        }
        console.log('error writing toParse.json', err);
      });
    })
    .catch((e) => console.log('something went wrong!', e));
};

const convertUnit = (unit) => {
  switch (unit) {
    case 'morceau(x)':
    case 'pièce':
    case 'petits morceaux de':
    case 'gros morceau(x)':
    case 'petit morceau(x)':
    case "cubes d'":
    case 'cube(s)':
      return 'bit';
    case 'pincée de':
    case 'pincé(es)':
      return 'pinch';
    case 'grande(s) boule(s)':
      return 'large-scoop';
    case 'feuilles':
    case 'feuilles de':
    case 'feuille(s) de':
    case 'leaf(ves)':
    case 'feuille(s)':
    case 'feuille de':
      return 'leaf';
    case 'cuillère de':
    case 'cuillère':
    case 'cuillères':
    case 'cuillères de':
    case 'cuillère (s)':
    case 'cuillère(s) à soupe':
    case 'cuillères à soupe de':
      return 'tbsp';
    case 'cuillère à café de':
    case 'cuillère(s) à café':
      return 'tsp';
    case 'sachet':
      return 'bag';
    case 'tranche(s)':
    case 'tranches de':
    case 'slice(s)':
    case 'rondelle(s)':
      return 'slice';
    case 'branche(s)':
    case 'branches':
      return 'sprig';
    case 'shot(s)':
    case 'shot':
      return 'shot';
    case 'double shot':
      return 'double-shot';
    case 'trait de':
    case 'trait':
    case 'trait(s)':
    case "traits d'":
    case 'traits de':
    case 'traits':
      return 'dash';
    case 'litre(s)':
      return 'l';
    case 'gramme(s)':
      return 'g';
    case 'verre de':
    case 'verre':
      return 'glass';
    case 'spray':
      return 'spray';
    case 'ml de':
    case "ml d'":
      return 'ml';
    default:
      return unit;
  }
};

const convertNb = (nb) => {
  if (/^\d+$/.test(nb)) {
    return +nb;
  }
  let nbSplitted = nb.split(',');
  if (nbSplitted.length > 1) {
    return +`${nbSplitted[0]}.${nbSplitted[1]}`;
  }
  nbSplitted = nb.split('/');
  if (nbSplitted.length > 1) {
    return nbSplitted[0] / nbSplitted[1];
  }
  return +nb;
};

const splitContent = (content) => {
  if (/^\d+((\.|,|\/)\d+)?\s(ml d'|cubes d'|traits d')([A-zÀ-ú]|\s)*/g.test(content)) {
    return content.split(/\s?(ml d'|cubes d'|traits d')\s?/);
  }
  return content.split(
    /\s?(ml de|ml d'|gramme\(s\)|spray|slice\(s\)|feuille\(s\) de|feuilles de|feuille de|leaf\(ves\)|tranche\(s\)|tranches de|sachet|pièce|rondelle\(s\)|verre de|verre|double shot|cuillère\(s\) à café|gros morceau\(x\)|petit morceau\(x\)|petits morceaux de|cuillères à soupe de|cuillère à café de|cuillères de|cuillères|cube\(s\)|cubes d'|litre\(s\)|cuillère\(s\) à soupe|morceau\(x\)|pincée de|grande\(s\) boule\(s\)|feuille\(s\)|feuilles|traits d'|traits de|trait de|trait\(s\)|traits|trait|cuillère de|branche\(s\)|branches|pincé\(es\)|cuillère \(s\)|cuillère|shot\(s\)|shot|g|cl|bag|ml)\s/
  );
}

const handleIngredientWithUnit = (product, content) => {  
  const [quantity, unit, ingredientNameToTrim] = splitContent(content);
  const ingredientName = ingredientNameToTrim.trim();  
  let ingredientObj = graph.ingredients.find((ingre) => ingre.name === ingredientName);
  if (ingredientObj == null) {
    ingredientObj = { name: ingredientName, id: graph.ingredients.length, usedBy: [] };
    graph.ingredients.push(ingredientObj);
  }
  ingredientObj.usedBy.push(product.id);
  product.composition.push({
    ingredientId: ingredientObj.id,
    quantity: convertNb(quantity),
    unit: convertUnit(unit),
  });
};

const handleIngredientWithoutUnit = (product, content) => {
  const [quantity, ingredientNameToTrim] = content.split(/\s+(.+)/);
  const ingredientName = ingredientNameToTrim.trim();
  let ingredientObj = graph.ingredients.find((ingre) => ingre.name === ingredientName);
  if (ingredientObj == null) {
    ingredientObj = { name: ingredientName, id: graph.ingredients.length, usedBy: [] };
    graph.ingredients.push(ingredientObj);
  }
  ingredientObj.usedBy.push(product.id);
  product.composition.push({
    ingredientId: ingredientObj.id,
    quantity: convertNb(quantity),
  });
};

const handleComplementIngredient = (product, content) => {
  const ingredientName = ` ${content}`.split(/\s+compléter\s+/i)[1].trim();
  let ingredientObj = graph.ingredients.find((ingre) => ingre.name === ingredientName);
  if (ingredientObj == null) {
    ingredientObj = { name: ingredientName, id: graph.ingredients.length, usedBy: [] };
    graph.ingredients.push(ingredientObj);
  }
  ingredientObj.usedBy.push(product.id);
  product.composition.push({
    ingredientId: ingredientObj.id,
    quantity: 0,
  });
};

const fetchComposition = (product) => {
  return new Promise((resolve, reject) => {
    axios(product.link).then((response) => {
      const $ = cheerio.load(response.data);
      $('.recipe_content_information')
        .find('li')
        .each((_i, ingredient) => {
          const content = $(ingredient).text().trim();
          if (/^\d+((\.|,|\/)\d+)?\s(ml d'|cubes d'|traits d')([A-zÀ-ú]|\s)*/g.test(content)) {
            handleIngredientWithUnit(product, content);
          }
          if (
            /^\d+((\.|,|\/)\d+)?\s(ml de|gramme\(s\)|spray|slice\(s\)|feuille\(s\) de|feuilles de|feuille de|leaf\(ves\)|tranche\(s\)|tranches de|sachet|pièce|rondelle\(s\)|verre de|verre|double shot|cuillère\(s\) à café|gros morceau\(x\)|petit morceau\(x\)|petits morceaux de|cuillères à soupe de|cuillère à café de|cuillères de|cuillères|cube\(s\)|litre\(s\)|cuillère\(s\) à soupe|morceau\(x\)|pincée de|grande\(s\) boule\(s\)|feuille\(s\)|feuilles|traits de|trait de|trait\(s\)|traits|trait|cuillère de|branche\(s\)|branches|pincé\(es\)|cuillère \(s\)|cuillère|shot\(s\)|shot|ml|bag|cl|g)\s([A-zÀ-ú]|\s)*/g.test(
              content
            )
          ) {
            handleIngredientWithUnit(product, content);
          } else if (/compléter\s([A-zÀ-ú]|\s)*/gi.test(content)) {
            handleComplementIngredient(product, content);
          } else if (/^\d+((\.|\/)\d+)?\s([A-zÀ-ú]|\s)*/g.test(content)) {
            toParse.push(content);
            handleIngredientWithoutUnit(product, content);
          } else {
            return toParse.push(content);
          }
        });
      try {
        const recipeSpan = $('.recipe_content_information').find('span');
        const capacity = +recipeSpan[Math.max(recipeSpan.length - 2, 0)].next.data.split(' ')[0];
        product.capacity = capacity;
      } catch (e) {
        console.log('following product does not have capcity:', product.link);
      }
      resolve();
    });
  });
};

fetchProducts();
