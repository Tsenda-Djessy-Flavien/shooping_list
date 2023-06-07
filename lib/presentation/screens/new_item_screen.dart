import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/domain/models/category_model.dart';
// import 'package:shopping_list/domain/models/grocery_model.dart';

class NewItemScreen extends StatefulWidget {
  const NewItemScreen({super.key});

  @override
  State<NewItemScreen> createState() => _NewItemScreenState();
}

class _NewItemScreenState extends State<NewItemScreen> {
  // verification supplementaire des types
  // et des suggestions d'autocompletion
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.fruit]!;

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // print(_enteredName);
      // print(_enteredQuantity);
      // print(_selectedCategory);

      final url = Uri.https(
        'flutter-prep-ca082-default-rtdb.firebaseio.com',
        'shooping-list.json',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // the data will be formatted
        },
        // convertir la data en text formaté Json
        body: json.encode({
          // 'id': DateTime.now().toString(), // generer par firebase
          'name': _enteredName,
          'quantity': _enteredQuantity,
          'category': _selectedCategory.label,
        }),
      );

      print(response.body);
      print(response.statusCode);

      if (!context.mounted) {
        return;
      }
      // ce code sera executé si le context existe (est monté)
      Navigator.of(context).pop();

      // Navigator.of(context).pop(
      //   GroceryModel(
      //     id: DateTime.now().toString(),
      //     name: _enteredName,
      //     quantity: _enteredQuantity,
      //     category: _selectedCategory,
      //   ),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          // cette key nous permet de savoir s'il faut afficher les erreurs de validations du formulaire ou pas
          key: _formKey,
          child: Column(
            children: [
              // TextFormField -> instead of TextField()
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('Name'),
                ),
                validator: (value) {
                  // value -> cette value sera fournie par flutter lors de l'execution de la fnc
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length == 50) {
                    return "Must be between 1 and 50 caractères.";
                  }
                  return null; // if le champ à été bien rempli
                },
                onSaved: (newValue) {
                  _enteredName = newValue!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(label: Text('Quantity')),
                      initialValue: _enteredQuantity.toString(),
                      validator: (value) {
                        //  int.tryParse -> convertir la value en nombre
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return "Must be valid, positive number.";
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        _enteredQuantity = int.parse(newValue!);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 6),
                                Text(category.value.label)
                              ],
                            ),
                          )
                      ],
                      onChanged: (newVaule) {
                        setState(() {
                          _selectedCategory = newVaule!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _formKey.currentState!.reset();
                    },
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: _saveItem,
                    child: const Text('Add Item'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
