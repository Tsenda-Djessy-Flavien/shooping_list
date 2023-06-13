import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';
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
  List<GroceryModel> _groceryItems = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    _loadItem();
    super.initState();
  }

  void _loadItem() async {
    final url = Uri.https(
      'flutter-prep-ca082-default-rtdb.firebaseio.com',
      'shooping-list.json',
    );

    try {
      // fetching data
      final response = await http.get(url);
      // checker si la request c'est bien passé
      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data, Please try again later.';
        });
      }
      // check data type
      print(response.body);

      // data is missing to backend
      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // convert data to Dart object
      final Map<String, dynamic> listData = json.decode(response.body);
      // stocker data
      final List<GroceryModel> listGroceryItem = [];

      for (final item in listData.entries) {
        // dans le backend on a juste stocker le label,
        // or la categories est constitué du label et de la color
        // d'ou en compare le label de la categories s'il est égale au label stocker dans le backend
        // si c'est true il return la categories complet (label, color)
        final category = categories.entries
            .firstWhere(
              (catItem) => catItem.value.label == item.value['category'],
            )
            .value;

        listGroceryItem.add(
          GroceryModel(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }

      setState(() {
        _groceryItems = listGroceryItem;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Something went wrong, Please Try again later.';
      });
    }
  }

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

  void _onRemoveItem(GroceryModel groceryItem) async {
    final index = _groceryItems.indexOf(groceryItem);

    setState(() {
      _groceryItems.remove(groceryItem);
    });

    final url = Uri.https(
      'flutter-prep-ca082-default-rtdb.firebaseio.com',
      'shooping-list/${groceryItem.id}.json',
    );

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        const snackBar = SnackBar(
          content: Text('An error has occurred'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        _groceryItems.insert(index, groceryItem);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget buildMain = const Center(
      child: Text('No items added yet.'),
    );

    if (_isLoading) {
      buildMain = const Center(
        child: CircularProgressIndicator(),
      );
    }

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

    if (_error != null) {
      buildMain = Center(child: Text(_error!));
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
