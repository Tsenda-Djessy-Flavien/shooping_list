import 'package:flutter/material.dart';
// import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/domain/models/grocery_model.dart';
import 'package:shopping_list/presentation/screens/new_item_screen.dart';
import 'package:shopping_list/presentation/widgets/grocery_item.dart';

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key});

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  final List<GroceryModel> _groceryItems = [];

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryModel>(
      MaterialPageRoute(builder: (ctx) => const NewItemScreen()),
    );

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body: ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) => GroceryItem(
          color: _groceryItems[index].category.color,
          title: _groceryItems[index].name,
          quantity: '${_groceryItems[index].quantity}',
        ),
      ),
    );
  }
}
