import 'package:flutter/material.dart';
import 'package:kewly/components/kewly_category_title.dart';

class KewlyWrapCategory extends StatelessWidget {
  final List<Widget> children;
  final String title;

  KewlyWrapCategory({@required this.title, @required this.children});

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return SizedBox(
        height: 0,
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        KewlyCategoryTitle(title),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Wrap(children: children, spacing: 8, alignment: WrapAlignment.start,),
        )
      ],
    );
  }
}
