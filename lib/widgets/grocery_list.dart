import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/grocery_item.dart';
import '../providers/grocery_items.dart';
import 'package:http/http.dart' as http;

class GroceryList extends ConsumerWidget {
  const GroceryList({
    super.key,
    required this.groceryItemsList,
  });

  final List<GroceryItem> groceryItemsList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: groceryItemsList.length,
      itemBuilder: (context, index) {
        final item = groceryItemsList[index];

        return Dismissible(
          key: ValueKey(item.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          secondaryBackground: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            final Uri deleteUrl = Uri.https(
              'flutter-test-932a2-default-rtdb.firebaseio.com',
              'shopping-list/${item.id}.json',
            );

            http.delete(deleteUrl).then((res) {
              if (res.statusCode == 200) {
                ref.read(groceryItemsProvider.notifier).removeItem(item);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${item.name} deleted!',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete item.')),
                );
              }
            });
          },
          child: ListTile(
            title: Text(item.name),
            leading: Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                color: item.category.color,
                borderRadius: const BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
            ),
            trailing: Text(item.quantity.toString()),
          ),
        );
      },
    );
  }
}
