import 'package:flutter/material.dart';

class KewlyFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final void Function() onSelected;

  KewlyFilterChip(this.label, this.selected, this.onSelected);

  @override
  Widget build(BuildContext context) {
    return FilterChip(
        showCheckmark: false,
        autofocus: false,
        backgroundColor: Colors.white,
        selectedColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(side: BorderSide(width: 1.5, color: Colors.black38), borderRadius: BorderRadius.circular(20)),
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected());
  }
}
