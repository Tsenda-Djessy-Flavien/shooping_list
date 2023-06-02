import 'package:flutter/material.dart';
import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/presentation/widgets/grocery_item.dart';

class GroceryListScreen extends StatelessWidget {
  const GroceryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
      ),
      body: ListView.builder(
        itemCount: groceryItems.length,
        itemBuilder: (context, index) => GroceryItem(
          color: groceryItems[index].category.color,
          title: groceryItems[index].name,
          quantity: '${groceryItems[index].quantity}',
        ),
      ),
    );
  }
}
