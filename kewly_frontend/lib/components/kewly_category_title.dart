import 'package:flutter/material.dart';

class KewlyCategoryTitle extends StatelessWidget {
  final String text;

  KewlyCategoryTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 12, top: 10, end: 8, bottom: 8),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Theme.of(context).accentColor)),
    );

  }
}
