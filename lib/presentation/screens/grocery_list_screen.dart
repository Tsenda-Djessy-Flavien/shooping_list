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
  final List<GroceryModel> _groceryItems = [];
  // late -> pas de initial mais il aura une valeur quand il sera utilisé pour la première fois
  late Future<List<GroceryModel>> _loadedItems;

  @override
  void initState() {
    super.initState();
    _loadedItems = _loadItem();
  }

  Future<List<GroceryModel>> _loadItem() async {
    final url = Uri.https(
      'flutter-prep-ca082-default-rtdb.firebaseio.com',
      'shooping-list.json',
    );
    // fetching data
    final response = await http.get(url);
    // checker si la request c'est bien passé
    if (response.statusCode >= 400) {
      throw Exception('Failed to fetch grocery items. Please try again later.');
    }
    // check data type
    print(response.body);
    // data is missing to backend
    if (response.body == 'null') {
      return [];
    }
    // convert data to Dart object
    final Map<String, dynamic> listData = json.decode(response.body);
    // stocker data
    final List<GroceryModel> listGroceryItem = [];
    // display data
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

    return listGroceryItem;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body: FutureBuilder(
        future: _loadedItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          if (snapshot.data!.isEmpty) {
            return const Text('No items added yet.');
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) => Dismissible(
              key: ValueKey(snapshot.data![index].id),
              background: Container(
                color: Theme.of(context).colorScheme.error.withOpacity(0.75),
                margin: Theme.of(context).cardTheme.margin,
              ),
              child: GroceryItem(
                color: snapshot.data![index].category.color,
                title: snapshot.data![index].name,
                quantity: '${snapshot.data![index].quantity}',
              ),
              onDismissed: (direction) {
                _onRemoveItem(snapshot.data![index]);
              },
            ),
          );
        },
      ),
    );
  }
}
