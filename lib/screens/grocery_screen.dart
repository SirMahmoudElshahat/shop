import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop/data/categories.dart';
import 'package:shop/models/category.dart';
import 'package:shop/models/grocery_item.dart';
import 'package:shop/widgets/grocery_list.dart';
import 'package:http/http.dart' as http;
import '../providers/grocery_items.dart';

class GroceryScreen extends ConsumerStatefulWidget {
  const GroceryScreen({super.key});

  @override
  ConsumerState<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends ConsumerState<GroceryScreen> {
  bool _isLoading = true;

  void _loadData() async {
    final Uri url = Uri.https(
        'flutter-test-932a2-default-rtdb.firebaseio.com', 'shopping-list.json');
    final http.Response res = await http.get(url);

    if (res.statusCode == 200) {
      final Map<String, dynamic> loadedData = json.decode(res.body);
      ref.read(groceryItemsProvider.notifier).clearItems();
      for (var item in loadedData.entries) {
        final Category category = categories.entries
            .firstWhere(
                (element) => element.value.title == item.value['category'])
            .value;

        final newItem = GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        );

        ref.read(groceryItemsProvider.notifier).addItem(newItem);
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final groceryItems = ref.watch(groceryItemsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Grocery"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/newItem');
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : groceryItems.isEmpty
              ? const Center(child: Text('No items'))
              : GroceryList(
                  groceryItemsList: groceryItems,
                ),
    );
  }
}
