import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kewly/components/kewly_category_title.dart';

class KewlyCategory extends StatelessWidget {
  final List<Widget> children;
  final String title;
  final Widget Function(BuildContext context, int index) builder;
  final int itemCount;

  KewlyCategory({@required this.title, this.children, this.builder, this.itemCount});

  @override
  Widget build(BuildContext context) {
    final count = children != null ? children.length : itemCount;
    var crossAxisCount = min(3, (count / 3).ceil());
    double maxHeight = crossAxisCount * 150.0;
    if (count == 0) {
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
          child: children != null
              ? GridView.count(
                  crossAxisCount: crossAxisCount,
                  primary: false,
                  scrollDirection: Axis.horizontal,
                  children: children,
                )
              : GridView.builder(
                  itemCount: itemCount,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(

                      crossAxisCount: crossAxisCount),
                  itemBuilder: builder,
                  primary: false,
                  scrollDirection: Axis.horizontal,
                ),
        )
      ],
    );
  }
}
