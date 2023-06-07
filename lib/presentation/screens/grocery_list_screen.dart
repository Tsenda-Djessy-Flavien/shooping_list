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

  void _onRemoveItem(GroceryModel groceryItem) {
    final checkGroceryItem = _groceryItems.contains(groceryItem);
    if (checkGroceryItem) {
      setState(() {
        _groceryItems.remove(groceryItem);
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('delete'),
          action: SnackBarAction(
            label: 'undo',
            onPressed: () {
              setState(() {
                _groceryItems.add(groceryItem);
              });
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget buildMain = const Center(
      child: Text('No items added yet.'),
    );

    if (_groceryItems.isNotEmpty) {
      buildMain = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) => Dismissible(
          key: ValueKey(_groceryItems[index].id),
          background: Container(
            color: Theme.of(context).colorScheme.error.withOpacity(0.75),
            margin: Theme.of(context).cardTheme.margin,
          ),
          child: GroceryItem(
            color: _groceryItems[index].category.color,
            title: _groceryItems[index].name,
            quantity: '${_groceryItems[index].quantity}',
          ),
          onDismissed: (direction) {
            _onRemoveItem(_groceryItems[index]);
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body: buildMain,
    );
  }
}
