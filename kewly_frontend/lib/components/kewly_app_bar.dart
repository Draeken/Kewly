import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class KewlyAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final ValueChanged<String> onSearchChanged;

  const KewlyAppBar({Key key, this.title, this.onSearchChanged})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _KewlyAppBar();

  @override
  Size get preferredSize => Size.fromHeight(56);
}

class _KewlyAppBar extends State<KewlyAppBar> {
  bool isSearchEnabled = false;

  void _toggleSearch() {
    if (isSearchEnabled) {
      widget.onSearchChanged("");
    }
    setState(() {
      isSearchEnabled = !isSearchEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isSearchEnabled) {
      return AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Close search',
            onPressed: _toggleSearch,
          ),
          title: TextField(autofocus: true, onChanged: widget.onSearchChanged));
    } else {
      return AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search a product',
            onPressed: _toggleSearch,
          )
        ],
      );
    }
  }
}
