const fs = require('fs'),
      path = require('path');    

const graph = JSON.parse(fs.readFileSync(path.join(__dirname, 'graph.json')));
const products = graph.products;
const ingredients = graph.ingredients;

const other = 'o';
const daiquiri = 'daïquiri';
const beer = 'bière';
const tea = 'thé';
const lemonade = 'limonade';
const mojito = 'mojito';
const margarita = 'margarita';
const chocolate = 'chocolat';
const cappuccino = 'cappuccino';

const stabilizator = 'aquafaba';
const milk = 'lait';
const wine = 'vin';
const expresso = 'expreso';

const glasses = (() => {
  const data = [
    {
      id: 1,
      from: 150,
      to: 200,
      usedBy: [
        { by: daiquiri, count: 1 },
        { by: stabilizator, count: 1 },
      ],
    },
    {
      id: 2,
      from: 150,
      to: 200,
      usedBy: [
        { by: daiquiri, count: 1 },
        { by: stabilizator, count: 1 },
      ],
    },
    {
      id: 3,
      from: 300,
      to: 300,
      usedBy: [{ by: stabilizator, count: 6 }],
    },
    {
      id: 4,
      from: 300,
      to: 400,
      usedBy: [
        { by: beer, count: 4 },
        { by: milk, count: 6 },
      ],
    },
    {
      id: 5,
      from: 300,
      to: 450,
      usedBy: [{ by: wine, count: 10 }],
    },
    {
      id: 6,
      from: 220,
      to: 250,
      usedBy: [{ by: stabilizator, count: 1 }],
    },
    {
      id: 7,
      from: 310,
      to: 400,
      usedBy: [{ by: milk, count: 8 }],
    },
    {
      id: 8,
      from: 360,
      to: 420,
      usedBy: [
        { by: beer, count: 3 },
        { by: tea, count: 2 },
        { by: lemonade, count: 8 },
      ],
    },
    {
      id: 10,
      from: 360,
      to: 400,
      usedBy: [{ by: milk, count: 8 }],
    },
    {
      id: 11,
      from: 360,
      to: 360,
      usedBy: [{ by: tea, count: 3 }],
    },
    {
      id: 12,
      from: 120,
      to: 250,
      usedBy: [
        { by: daiquiri, count: 9 },
        { by: stabilizator, count: 10 },
      ],
    },
    {
      id: 13,
      from: 110,
      to: 200,
      usedBy: [{ by: daiquiri, count: 1 }],
    },
    {
      id: 15,
      from: 150,
      to: 200,
      usedBy: [
        { by: expresso, count: 5 },
        { by: cappuccino, count: 5 },
      ],
    },
    {
      id: 16,
      from: 140,
      to: 250,
      usedBy: [{ by: margarita, count: 10 }],
    },
    {
      id: 17,
      from: 80,
      to: 150,
      usedBy: [
        { by: daiquiri, count: 9 },
        { by: stabilizator, count: 2 },
      ],
    },
    {
      id: 18,
      from: 250,
      to: 450,
      usedBy: [{ by: beer, count: 10 }],
    },
    {
      id: 19,
      from: 360,
      to: 400,
      usedBy: [
        { by: beer, count: 3 },
        { by: mojito, count: 1 },
      ],
    },
    {
      id: 20,
      from: 350,
      to: 450,
      usedBy: [
        { by: lemonade, count: 10 },
        { by: mojito, count: 10 },
        { by: expresso, count: 3 },
        { by: chocolate, count: 4 },
      ],
    },
    {
      id: 21,
      from: 180,
      to: 200,
      usedBy: [{ by: cappuccino, count: 5 }],
    },
    {
      id: 22,
      from: 350,
      to: 420,
      usedBy: [{ by: tea, count: 1 }],
    },
    {
      id: 23,
      from: 300,
      to: 360,
      usedBy: [
        { by: tea, count: 2 },
        { by: mojito, count: 1 },
        { by: milk, count: 3 },
        { by: chocolate, count: 2 },
      ],
    },
    {
      id: 24,
      from: 300,
      to: 300,
      usedBy: [],
    },
    {
      id: 25,
      from: 200,
      to: 400,
      usedBy: [{ by: tea, count: 1 }],
    },
    {
      id: 26,
      from: 250,
      to: 300,
      usedBy: [
        { by: expresso, count: 1 },
        { by: chocolate, count: 11 },
      ],
    },
    {
      id: 27,
      from: 360,
      to: 400,
      usedBy: [{ by: tea, count: 5 }],
    },
    {
      id: 28,
      from: 140,
      to: 140,
      usedBy: [{ by: daiquiri, count: 1 }],
    },
    {
      id: 29,
      from: 250,
      to: 360,
      usedBy: [{ by: tea, count: 3 }],
    },
    {
      id: 30,
      from: 400,
      to: 500,
      usedBy: [{ by: wine, count: 10 }],
    },
  ];

  return data.map((d) => ({...d, mean: (d.to + d.from) /2 }));
})();

const main = () => {
  products.forEach((product) => {
    product.glass = mapTypeWithGlass(productToType(product), product.capacity)
  });
  writeFile();
};

const productToType = (product) => {
  const name = product.name
  if (/da[ïi]quiri/gi.test(name)) {
    return daiquiri;
  }
  if (/bière/gi.test(name)) {
    return beer;
  }
  if (/thé/gi.test(name)) {
    return tea;
  }
  if (/lemonade/gi.test(name)) {
    return lemonade;
  }
  if (/mojito/gi.test(name)) {
    return mojito;
  }
  if (/margarita/gi.test(name)) {
    return margarita;
  }
  if (/chocolate/gi.test(name)) {
    return chocolate;
  }
  if (/cappuccino/gi.test(name)) {
    return cappuccino;
  }
  const compoName = product.composition.map((compo) => {
    const ingredient = ingredients.find(ingre => ingre.id === compo.ingredientId);
    return ingredient.name;
  });
  for (const ingredient of compoName) {
    if (/^lait/gi.test(ingredient)) {
      return milk;
    }
    if (/expresso/gi.test(ingredient)) {
      return expresso;      
    }
    if (/limonade/gi.test(ingredient)) {
      return lemonade;
    }
    if (/bière/gi.test(ingredient)) {
      return beer;
    }
    if (/vin\s/gi.test(ingredient)) {
      return wine;
    }
    if (/aquafaba/gi.test(ingredient) || /blanc d'/gi.test(ingredient)) {
      return stabilizator;
    }
  }
  return other;
}

const writeFile = () => {
  const jsonContent = JSON.stringify(graph);
  fs.writeFile('graphPostProcessed.json', jsonContent, 'utf-8', (err) => {
    if (!err) {
      return;
    }
    console.log('error writing graph.json', err);
  });
}

const mapTypeWithGlass = (type, capacity) => {
  if (!capacity) {
    console.log('no capacity');
    return 11;
  }
  const matches = glasses.filter(glass => capacity >= glass.from && capacity <= glass.to);
  const prefered = matches.filter(glass => glass.usedBy.some(usedBy => usedBy.by === type));
  if (prefered.length > 0) {
    const glasseCount = prefered.map(glass => glass.usedBy.find(usedBy => usedBy.by === type).count);
    const maxCount = glasseCount.reduce((acc, cur) => acc + cur, 0);
    let selection = Math.ceil(Math.random() * maxCount);
    let i = 0;
    while (selection > 0) {
      selection = selection - glasseCount[i];
      i++;
    }
    console.log('prefered', prefered[i - 1].id, ' type', type);
    return prefered[i - 1].id;
  }
  if (matches.length > 0) {
    let bestMean = Number.POSITIVE_INFINITY;
    let bestGlass = [];
    matches.forEach(glass => {
      const diff = Math.abs(glass.mean - capacity);
      if (diff < bestMean) {
        bestMean = diff;
        bestGlass = [glass];
      } else if (diff === bestMean) {
        bestGlass.push(glass);        
      }
    });
    const selection = Math.floor(Math.random() * bestGlass.length);
    console.log('best fit', bestGlass[selection].id, type !== other ? type : '');
    return bestGlass[selection].id;
  }
  console.log('no match for this capacity', capacity);
  return 11; //big bucket
};

main();
