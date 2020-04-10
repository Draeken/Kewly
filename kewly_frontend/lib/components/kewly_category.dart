import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kewly/components/kewly_category_title.dart';

class KewlyCategory extends StatelessWidget {
  final List<Widget> children;
  final String title;

  KewlyCategory({ @required this.title, @required this.children });

  @override
  Widget build(BuildContext context) {
    var crossAxisCount = min(3, (children.length / 3).ceil());
    double maxHeight = crossAxisCount * 150.0;
    if (children.length == 0) {
      return SizedBox(
        height: 0,
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        KewlyCategoryTitle(title),
        LimitedBox(
            maxHeight: maxHeight,
            child: GridView.count(
              primary: false,
              scrollDirection: Axis.horizontal,
              crossAxisCount: crossAxisCount,
              children: children,
            )),
      ],
    );
  }
}