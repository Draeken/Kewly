const fs = require('fs'),
  path = require('path');

const graph = JSON.parse(fs.readFileSync(path.join(__dirname, 'graph.json')));
const products = graph.products;
const ingredients = graph.ingredients;
const ingredientToReview = [];

// products.forEach((product) => {
//   if (product.decoratedWith) {
//     product.decoratedWith = product.decoratedWith.map((id) => ({ id }));
//   }
// });

ingredients.forEach((ingredient) => {
  if (!ingredient.decorates) {
    ingredient.decorates = [];
  }
});

const main = () => {
  normalizeIngredients();
  graph.ingredients = graph.ingredients.filter((ingre) => !ingre.markObsolete);
  writeFile();
};

const normalizeIngredients = () => {
  const withoutMonin = [];
  const withMonin = [];
  ingredients.forEach((ingre) => {
    const targetArr = /monin/i.test(ingre.name) ? withMonin : withoutMonin;
    targetArr.push(ingre);
  });
  const withoutDe = [];
  const withDe = [];
  withMonin.forEach((ingre) => {
    const targetArr = /de monin/i.test(ingre.name) ? withDe : withoutDe;
    targetArr.push(ingre);
  });

  withoutDe.forEach((ingreToReplace) => {
    const correspondance = searchCorrespondance(withoutMonin, ingreToReplace, ' monin') || searchCorrespondance(withoutMonin, ingreToReplace, 'monin ');
    if (!correspondance) {
      return ingredientToReview.push(ingreToReplace.name);
    }
    mergeIngredients(correspondance, ingreToReplace);
  });

  withDe.forEach((ingreToReplace) => {
    let correspondance = searchCorrespondance(withoutMonin, ingreToReplace, ' de monin') || searchCorrespondance(withoutMonin, ingreToReplace, ' monin');
    if (!correspondance) {
      return ingredientToReview.push(ingreToReplace.name);
    }
    mergeIngredients(correspondance, ingreToReplace);
  });

  const manualMerge = [
    ['sirop Saveur Cannelle MONIN', 192],
    ['MONIN® Sirop de Fraise', 81],
    ['MONIN® Rantcho Citron Vert', 1],
    ['Rantcho MONIN Citron Verte', 1],
    ['MONIN® Le Frappé Neutre', 314],
    ['MONIN topping Caramel', 193],
    ['MONIN topping Chocolat Blanc', 183],
    ['MONIN topping Chocolat Noir', 188],
    ['Sirop de Curaçao Bleu MONIN 1 trait', 112],
    ['Sirop saveur Curaçao Bleu', 112], //
    ['Topping Sauce Caramel Salé MONIN', 25],
    ['Sirop de MONIN Agave', 230],
    ['sirop de Cloudy Lemonade MONIN', 220],
    ['Sirop de MONIN Pina-Colada', 69],
    ['Sirop de Pina Colada', 69],
    ['Sirop de MONIN saveur Estragon', 14],
    ['Sirop de MONIN Spéculoos', 166],
    ['Sirop de MONIN Orgeat', 2],
    ['La Sauce de MONIN Chocolat Noir', 188],
    ['Mojito Mint syrup', 313],
    ["d'eau gazeuse", 146],
    ['eau gazeuse', 146],
    ['Fruit de MONIN Fraise', 122],
    ['rhum blanc des Caraïbes', 281],
    ['Té de Chai', 390],
    ['d’eau', 222],
    ['crème liquide légère 15% MG', 309],
    ['Sirop Hibiscus', 307],
    ['framboises', 380],
    ['Framboises', 380],
    ['Noix de Muscade', 298],
    ['espresso', 142],
    ['water', 222],
    ['mint', 139],
    ['lemon', 227],
    ['lait écrémé 2% chauffé au bec vapeur', 27],
    ['de tonic', 13],
    ['fruits rouges surgelés', 572],
    ['batôn(s) citronnelle', 597],
    ['Creme Chantilly', 198],
    ['crème chantilly', 198],
    ['cookies ', 614],
    ['Bonbons guimauve', 579],
    ['Menthe', 139],
    ['Fraise fraîche', 236],
    ['Fraises', 236],
    ['mini billes de sucre', 556],
    ['une boule de glace à la vanille', 270],
    ['nappage caramel', 653],
    ['Sel', 501],
    ['estragon', 534],
    ['Mûres', 389],
    ['mûres', 389],
  ];
  manualMerge.forEach((tuple) => {
    const [a, b] = findTwoIngredients(tuple);
    mergeIngredients(b, a);
  });

  const alias = [
    ['jus de citron frais', 227],
    ['Zeste citron', 227],
    ['zeste de citron', 227],
    ['jus de citron vert frais', 83],
    ['Zeste de Citron Vert', 83],
    ['Tranche de citron vert', 83],
    ['rondelle de citron vert', 83],
    ['quart citron vert', 83],
    ['quartier de citron vert', 83],
    ['jus de pamplemousse frais', 513],
    ["jus d'orange pressée", 267],
    ['eau chaude', 222],
    ["cubes d'ananas", 244],
    ['lait froid', 27],
    ['glace brisée', 87],
    ['thé glacé', 325],
    ['thé fraichement infusé', 325],
    ['Thé noir glacé', 491],
    ['Tranche de Citron / Morceaux', 227],
    ['Tranche de citron', 227],
    ['tranche de citron', 227],
    ['Eventail de pommes', 421],
    ['tranche de pomme', 421],
    ["Tranche d'Ananas", 244],
    ['Tranche de Citron Vert/Morceaux', 83],
    ["rondelle d'orange", 267],
    ["Tranche d'Orange / Morceaux", 267],
    ['rondelle de citron', 227],
    ["Feuilles d'ananas", 244],
    ["feuille d'ananas", 244],
    ["tranches d'ananas", 244],
    ["zeste d'orange", 267],
    ['Tranche de Pamplemousse/Morceaux', 513],
    ['feuille de menthe', 139],
    ['feuilles de menthe', 139],
    ['Feuilles de menthe', 139],
    ['Poudre de Cannelle', 352],
    ['cookies émiettés', 614],
    ['Morceaux de Cookie en poudre pour givrer le verre', 614],
    ['Tranche de Kiwi', 216],
    ['morceau de poire', 642],
    ['tranche de concombre', 253],
    ['tranches de concombre', 253],
    ['Tranche(s) de concombre', 253],
    ['Quartier de pamplemousse rose', 513],
    ['Branche de Menthe', 139],
    ['Feuille de combava', 499],
    ['Tranche(s) de mandarine', 466],
  ];

  const aliasWithNew = [
    { alias: ['chocolat liquide', 'chocolat noir râpé', 'chocolat pour givrer le verre', 'Copeaux de Chocolat', 'filet de chocolat'], name: 'chocolat' },
    {
      alias: ['Eclats de Banane', 'rondelle de banane'],
      name: 'banane',
    },
  ];

  aliasWithNew.forEach((obj) => {
    const id = ingredients.length;
    ingredients.push({ id, name: obj.name, usedBy: [], decorates: [] });
    obj.alias.forEach((alia) => {
      alias.push([alia, id]);
    });
  });

  alias.forEach((tuple) => {
    const [aliased, origin] = findTwoIngredients(tuple);
    aliased.markObsolete = true;
    aliased.usedBy.forEach((productId) => {
      const product = products.find((p) => p.id === productId);
      const compo = product.composition.find((comp) => comp.ingredientId == aliased.id);
      compo.ingredientId = origin.id;
      compo.as = aliased.name;
      origin.usedBy.push(productId);
      console.log(' - aliased composition of ', product.name, ' for ', aliased.name);
    });
    if (!aliased.decorates) {
      return;
    }
    aliased.decorates.forEach((productId) => {
      const product = products.find((p) => p.id === productId);
      const deco = product.decoratedWith.find((dec) => dec.id === aliased.id);
      deco.id = origin.id;
      deco.as = aliased.name;
      origin.decorates.push(productId);
      console.log('  -- aliased decoration of ', product.name, ' for ', aliased.name);
    });
  });
};

const findTwoIngredients = (tuple) => {
  let a, b;
  for (let i = 0; i < ingredients.length; i++) {
    const curr = ingredients[i];
    if (curr.name === tuple[0]) {
      a = curr;
      if (b) {
        break;
      }
      continue;
    }
    if (curr.id === tuple[1]) {
      b = curr;
      if (a) {
        break;
      }
      continue;
    }
  }
  return [a, b];
};

const searchCorrespondance = (searachIn, ingredient, toRemove) => {
  const searchFor = ingredient.name.replace(new RegExp(toRemove, 'i'), '').trim();
  return searachIn.find((ingre) => new RegExp(`^${searchFor}$`, 'i').test(ingre.name));
};

const mergeIngredients = (a, b) => {
  a.usedBy = a.usedBy.concat(b.usedBy);
  console.log(`${a.name} merged with ${b.name}`);
  b.markObsolete = true;
  b.usedBy.forEach((productId) => {
    const product = products.find((p) => p.id === productId);
    const compo = product.composition.find((compo) => compo.ingredientId === b.id);
    compo.ingredientId = a.id;
  });
  if (!b.decorates) {
    return a;
  }
  b.decorates.forEach((productId) => {
    const product = products.find((p) => p.id === productId);
    const compo = product.decoratedWith.find((compo) => compo.id === b.id);
    compo.id = a.id;
  });
  if (a.decorates) {
    a.decorates.concat(b.decorates);
    return a;
  }
  a.decorates = b.decorates;
  return a;
};

const writeFile = () => {
  const jsonContent = JSON.stringify(graph);
  // const toReview = JSON.stringify(ingredientToReview);

  fs.writeFile('graph-without-doublons.json', jsonContent, 'utf-8', (err) => {
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
