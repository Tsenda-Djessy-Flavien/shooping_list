import 'package:flutter/material.dart';

class GroceryItem extends StatelessWidget {
  const GroceryItem(
      {required this.color,
      required this.title,
      required this.quantity,
      super.key});

  final Color color;
  final String title;
  final String quantity;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        color: color,
        height: 24,
        width: 24,
      ),
      title: Text(title),
      trailing: Text(quantity),
    );
  }
}
