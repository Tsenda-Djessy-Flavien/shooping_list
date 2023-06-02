import 'package:flutter/material.dart';

class CategoryModel {
  const CategoryModel(this.label, this.color);

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
