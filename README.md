# Kewly
Cocktail recipe finder

[link to Figma](https://www.figma.com/file/f47Y5JSzxOvpCuUnlxyW3Z/Kewly?node-id=0%3A1)

## Home
user can long press any product to trigger selection mode.
### All your cocktails
All available products, sorted by user's appreciation. (or random)
### Recommended
Recommended should list available products based on:
- could takes 100 products randomly on app launch and rates then sorts
- user tastes - based on reviewed drinks (similarity of composition - also could compute distance between two ingredients)
- hour: 16h30 -> fruit / chocolate with low alcohol - before dining, after dining...
### For a few dollars more
Same as recommended but with near available products (1 missing ingredient)

question: `Recommended` and `For a few $ more` are pretty similars. It may be better to have only one `Recommended` category and a filter for "max missing ingredient" => chips from 1 to 4.

#### Products tile
May be represented as icon with label, or label and composition. In eather case, if using only one `Recommended` category, include a badge to indicate the number of missing ingredients.

#### Product page
Display users shared photo of this product from social networks (eg: insta).
Button to display instructions "conceive it" -> button to share a photo of the drink to social networks (eg: insta)

## Home - selection mode
user can tap product to toggle selection. Then, user can add selection to "pin cocktails" or "add to shopping list".

## Search
Allow search of family product, eg: fruit juice, alcohol, frappé, Le Fruit. (these family are ingredient's tags)
Combine chips to compute a score for each product, order by most revelant (use the quantity of each product to compute score). Apply OR operator to all chips.

list chip by most frequently used. ~~Each ingredient had tag, that generate two chip : with / without.~~
Chip list is filtered by user search

## Shopping List
Product grouped by ~~family (all siryp, all alcohol, all fruit juice)~~ drink composition. Product already owned are listed last and scrimmed. User can tap to toggle state (owned/to buy).

## Ingrédient page
Inform all the product the user can perform (with the ingredients he owns and those he has to buy).
Inform all the product that needs this ingredient. (minus those listed above)

## Profil
### No-go
default filter, that apply to all sections. These filter aren't visible on search page. And they are the only way to filter out products with specific ingredient. To ban ingredient, usre must go to the ingredient detail page and tap "ban" button. To ban a tag, user must do it in this section (all tags are displayed). To un-ban, user have to tap on the chip's cross button.
### Pinned
Pinned product to try later, ~~they automatically disappear when user scroll down to the cocktail page and had viewed it for more than 1min (that also add the cocktail to "to be rated" list)~~ pinned products should be "unpinned" when user conceived it, through an user action (eg. button "conceive it" that display instructions)
### Historic
List all viewed product, ordered by last time seen.

## Glass priority
- 11
- 20
- 26
- 30
- 4
- 17
- 16
- 6
- 25
- 23
- 7
- 3
- 13
- 12
- 24
- 18
- 5
- 10
- 8
- 15
- 29
- 27
- 1 (< 10)