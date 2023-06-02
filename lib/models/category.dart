import 'package:flutter/material.dart';

class Category {
  const Category(this.label, this.color);

  final String label;
  final Color color;
}

enum Categories {
  vegetables,
  fruit,
  meat,
  dairy,
  carbs,
  sweets,
  spices,
  convenience,
  hygiene,
  other
}
