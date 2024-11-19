import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/grocery_item.dart';

class GroceryItemsNotifier extends StateNotifier<List<GroceryItem>> {
  GroceryItemsNotifier() : super([]);

  void addItem(GroceryItem item) {
    state = [...state, item];
  }

  void removeItem(GroceryItem item) {
    state = state.where((i) => i != item).toList();
  }

  void updateItem(GroceryItem oldItem, GroceryItem newItem) {
    final index = state.indexOf(oldItem);
    if (index != -1) {
      final updatedList = [...state];
      updatedList[index] = newItem;
      state = updatedList;
    }
  }

  void clearItems() {
    state = [];
  }
}

final groceryItemsProvider =
    StateNotifierProvider<GroceryItemsNotifier, List<GroceryItem>>(
  (ref) => GroceryItemsNotifier(),
);
