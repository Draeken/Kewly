import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kewly/app_model.dart';

class KewlyCompositionBar extends StatelessWidget {
  final Composition composition;

  KewlyCompositionBar({Key key, this.composition}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CompositionPainter(composition),
      child: Container(
        height: 30.0,
      ),
    );
  }
}

class CompositionPainter extends CustomPainter {
  final Composition composition;

  CompositionPainter(this.composition);

  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(CompositionPainter oldDelegate) {
    return false;
  }
}
