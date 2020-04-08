import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class KewlyButtonBadge extends StatelessWidget {
  final Icon icon;
  final void Function(TapDownDetails) onTap;

  KewlyButtonBadge({@required this.icon, @required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTapDown: onTap,
        behavior: HitTestBehavior.translucent,
        child: Container(
            child: icon,
            decoration: ShapeDecoration(
                shape: CircleBorder(side: BorderSide(width: 1)),
                color: Colors.white)));
  }
}
