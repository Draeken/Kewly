import 'package:flutter/material.dart';

class KewlyCategoryTitle extends StatelessWidget {
  final String text;

  KewlyCategoryTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 12, top: 8, end: 8, bottom: 4),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
    );

  }
}
