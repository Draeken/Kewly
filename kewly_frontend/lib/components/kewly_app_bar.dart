import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class KewlyAppBar extends StatelessWidget implements PreferredSizeWidget {

  KewlyAppBar({ Key key }): preferredSize = Size.fromHeight(56), super(key: key);

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    // TODO: implement build
    return Container(
      color: theme.primaryColor,
    );
  }
}