// lib/providers/grocery_provider.dart

import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/grocery_item.dart';
import '../services/notification_service.dart';

//Enum for sorting options
enum SortOption {
  expiryDate,
  name,
  quantity
}

class GroceryProvider with ChangeNotifier {
  List<GroceryItem> _items = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = false;
  SortOption _currentSort = SortOption.expiryDate; 

  List<GroceryItem> get items => _items;
  bool get isLoading => _isLoading;
  SortOption get currentSort => _currentSort;

  GroceryProvider() {
    _notificationService.init(); // Initialize notifications when the provider is created
    loadItems();
  }

  // Fetch all items from the database
  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();

    _items = await _dbHelper.getItems();
    sortItems(_currentSort);
    _isLoading = false;
    notifyListeners();
  }

  // Add a new item to the database and update the state
  Future<void> addItem(GroceryItem item) async {
    final id = await _dbHelper.insertItem(item);
    final newItem = item.copyWith(id: id);

    _items.add(newItem);
    sortItems(_currentSort);

    _notificationService.scheduleExpiryNotification(newItem); // SCHEDULE NOTIFICATION
    notifyListeners();
  }

  // Update an existing item
  Future<void> updateItem(GroceryItem item) async {
    await _dbHelper.updateItem(item);

    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = item;
      sortItems(_currentSort);

      _notificationService.scheduleExpiryNotification(item); // RESCHEDULE NOTIFICATION
      notifyListeners();
    }
  }

  // Delete an item
  Future<void> deleteItem(int id) async {
    await _dbHelper.deleteItem(id);

    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // Optional: Mark an item as used (reduces quantity)
  Future<void> markAsUsed(GroceryItem item, double amountUsed) async {
    double newQuantity = item.quantity - amountUsed;

    // Ensure quantity doesn't go negative
    if (newQuantity < 0) {
      newQuantity = 0;
    }

    final updatedItem = item.copyWith(quantity: newQuantity);
    if(newQuantity == 0) {
      // Delete item from DB and list
      await deleteItem(item.id!);
    } else {
      await updateItem(updatedItem); // This will update DB and notifyListeners
    }
  }

  //sort items based on selected option
  void sortItems(SortOption option) {
    _currentSort = option;
    switch (_currentSort) {
      case SortOption.expiryDate:
        _items.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
        break;
      case SortOption.name:
        _items.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case SortOption.quantity:
        _items.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
    }
    notifyListeners();
  }
  //  Delete all grocery items (used in SettingsScreen)
  Future<void> deleteAllItems() async {
    await _dbHelper.deleteAllGroceries();
    _items.clear();
    notifyListeners();
  }
}