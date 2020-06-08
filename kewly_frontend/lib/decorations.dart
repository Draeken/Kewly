import 'package:flutter/material.dart';

const searchDecoration = InputDecoration(
    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 25),
    isDense: true,
    labelText: 'Recherche',
    filled: true,
    floatingLabelBehavior: FloatingLabelBehavior.never,
    border: OutlineInputBorder(
        borderRadius: BorderRadius.all(const Radius.circular(25)), borderSide: BorderSide.none),
    fillColor: Colors.black12);