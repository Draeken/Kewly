const fs = require('fs'),
  path = require('path');

const graph = JSON.parse(fs.readFileSync(path.join(__dirname, 'graph.json')));
const products = graph.products;
const ingredients = graph.ingredients;
const instructions = graph.instructions;

const syriup = 'syriup';
const alcool = 'alcool';
const ice = 'ice';
const hot = 'hot';
const sparkling = 'sparkling';
const blended = 'blended';
const mixed = 'mixed';
const filtred = 'filtered';

products.forEach((product) => product.tags = new Set());
ingredients.forEach((ingre) => (ingre.tags = []));
instructions.forEach((instru) => (instru.tags = []));

const main = () => {
  fixCompo();
  addTagsToIngredients();
  console.log('added tags to ingredients');
  addTagsFromIngredients();
  console.log('added tags from ingredients');
  addTagsToInstructions();
  console.log('added tags to instructions');
  addTagsFromInstructions();
  console.log('added tags from instructions');
  resolveConflict();
  console.log('conflicts resolved');
  writeFile();
};

const fixCompo = () => {
  const errors = [];
  products.forEach(product => product.composition.forEach(compo => {
    if (ingredients.find(ingr => ingr.id === compo.ingredientId)) {
      return;
    }
    errors.push({ product, compo });
  }));
  console.log(errors);
};

const resolveConflict = () => {
  products.forEach(product => {
    if (product.tags.has(hot) && product.tags.has(ice)) {
      product.tags.delete(hot);
    }
  });
}

const addTagsFromIngredients = () => {
  products.forEach((product) => {
    product.composition.forEach((compo) => {
      const ingredient = ingredients.find((ingre) => ingre.id === compo.ingredientId);
      if (!ingredient.tags) {
        return;
      }
      ingredient.tags.forEach((tag) => product.tags.add(tag));
    });
  });
};

const addTagsFromInstructions = () => {
  products.forEach((product) => {
    if (!product.instructions) {
      return;
    }
    product.instructions.forEach((id) => {
      const instruction = instructions.find((instr) => instr.id === id);
      if (!instruction.tags) {
        return;
      }
      instruction.tags.forEach((tag) => product.tags.add(tag));
    });
  });
};

const addTagsToInstructions = () => {
  instructions.filter((instr) => /((?<!sans )glaçon)|(glace pilée)|(froid)/i.test(instr.name)).forEach((instr) => instr.tags.push(ice));
  instructions.filter((instr) => /((?<!pas )mélanger)|(shaker)/i.test(instr.name)).forEach((instr) => instr.tags.push(mixed));
  instructions.filter((instr) => /(blender)|(mixer)/i.test(instr.name)).forEach((instr) => instr.tags.push(blended));
  instructions.filter((instr) => /(chauffer)/i.test(instr.name)).forEach((instr) => instr.tags.push(hot));
  withFiltre = [27, 38, 83, 85, 89, 110, 283];
  withFiltre.forEach(id => instructions.find(instr => instr.id === id).tags.push(filtred));
};

//should be merged: 407 with 370; eau de pois chiche ; Liqueur de Framboise
const addTagsToIngredients = () => {
  ingredients.filter((ingre) => /sirop/i.test(ingre.name)).forEach((ingre) => ingre.tags.push(syriup));
  const withAlcool = [
    3,
    4,
    6,
    8,
    12,
    16,
    33,
    35,
    38,
    46,
    48,
    59,
    60,
    63,
    66,
    68,
    72,
    84,
    99,
    102,
    116,
    117,
    118,
    125,
    135,
    138,
    145,
    164,
    167,
    179,
    197,
    209,
    210,
    214,
    231,
    233,
    238,
    242,
    243,
    254,
    259,
    261,
    264,
    265,
    276,
    281,
    296,
    299,
    304,
    332,
    333,
    337,
    338,
    340,
    341,
    348,
    355,
    356,
    359,
    360,
    361,
    362,
    364,
    367,
    370,
    371,
    372,
    373,
    374,
    375,
    376,
    378,
    379,
    382,
    384,
    393,
    407,
    409,
    413,
    414,
    423,
    424,
    427,
    445,
    446,
    447,
    448,
    449,
    452,
    453,
    455,
    457,
    458,
    459,
    462,
    467,
    468,
    469,
    470,
    471,
    474,
    477,
    478,
    498,
    500,
    512,
  ];
  const withSparks = [33, 46, 63, 66, 68, 70, 72, 84, 95, 146, 159, 160, 167, 214, 239, 471, 519];
  const withIce = [87];
  const withHot = [142, 144, 194, 213, 229, 325, 390, 434, 437, 475, 491, 503, 504, 506];
  withAlcool.forEach(id => ingredients.find(ingr => ingr.id === id).tags.push(alcool));
  withSparks.forEach(id => ingredients.find(ingr => ingr.id === id).tags.push(sparkling));
  withIce.forEach(id => ingredients.find(ingr => ingr.id === id).tags.push(ice));
  withHot.forEach(id => ingredients.find(ingr => ingr.id === id).tags.push(hot));
};

const writeFile = () => {
  products.forEach(product => product.tags = Array.from(product.tags));
  const jsonContent = JSON.stringify(graph);
  // const toReview = JSON.stringify(ingredientToReview);

  fs.writeFile('graph-with-tags.json', jsonContent, 'utf-8', (err) => {
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
