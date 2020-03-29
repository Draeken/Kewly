import 'package:flutter/material.dart';

class KewlySearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTapDown: (_) { Navigator.pushNamed(context, '/search'); },
        child: Container(
      decoration: BoxDecoration(
          border: Border.all(width: 1, color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Colors.white),
      child: Text('Search a cocktail'),
    ));
  }
}
