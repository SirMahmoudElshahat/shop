import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop/data/categories.dart';
import 'package:shop/models/category.dart';
import 'package:http/http.dart' as http;

import '../models/grocery_item.dart';
import '../providers/grocery_items.dart';

class NewItem extends ConsumerStatefulWidget {
  const NewItem({super.key});

  @override
  ConsumerState<NewItem> createState() => _NewItemState();
}

class _NewItemState extends ConsumerState<NewItem> {
  String _enteredName = '';
  int _enteredQuantity = 0;
  var _selectedCategory = categories[Categories.fruit]!;
  final _formkey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _saveItem() {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      final Uri url = Uri.https(
        'flutter-test-932a2-default-rtdb.firebaseio.com',
        'shopping-list.json',
      );

      http
          .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': _enteredName,
          'quantity': _enteredQuantity,
          'category': _selectedCategory.title,
        }),
      )
          .then((res) {
        if (res.statusCode == 200) {
          final responseData = json.decode(res.body);
          final newItem = GroceryItem(
            id: responseData['name'],
            name: _enteredName,
            quantity: _enteredQuantity,
            category: _selectedCategory,
          );

          ref.read(groceryItemsProvider.notifier).addItem(newItem);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Item added successfully!'),
              ),
            );
            Navigator.of(context).pop();
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to add item.'),
              ),
            );
          }
        }
      }).catchError((error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('An error occurred.'),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add new Item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(9),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
                validator: (String? value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1) {
                    return 'Must be between 1 and 50 chracters.';
                  }
                  return null;
                },
                onSaved: (newValue) {
                  _enteredName = newValue!;
                },
              ),
              Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: TextFormField(
                        initialValue: '1',
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                        ),
                        validator: (String? value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0) {
                            return 'Not valid';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _enteredQuantity = int.parse(newValue!);
                        },
                      )),
                  const SizedBox(width: 15),
                  Expanded(
                      flex: 6,
                      child: DropdownButtonFormField(
                        value: _selectedCategory,
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem(
                              value: category.value,
                              child: Row(
                                children: [
                                  Container(
                                    height: 18,
                                    width: 18,
                                    decoration: BoxDecoration(
                                      color: category.value.color,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(2.5),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(category.value.title)
                                ],
                              ),
                            )
                        ],
                        onChanged: (Category? value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ))
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            _formkey.currentState!.reset();
                          },
                    child: const Text("Reset"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveItem,
                    child: _isLoading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text("Add Item"),
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
