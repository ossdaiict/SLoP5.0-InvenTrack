// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/grocery_provider.dart';
import '../screens/add_item_screen.dart';
import '../widgets/grocery_card.dart'; // We'll create this next
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the provider for state changes
    final groceryProvider = Provider.of<GroceryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('IvenTrack 🧺'),
        actions: [

          // Sorting popup menu

          PopupMenuButton<SortOption>(
            icon: Icon(Icons.sort, 
            color: Colors.green.shade600,
            ),
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
           ),
            color: Theme.of(context).colorScheme.surface,
            onSelected: (SortOption selectedOption) {
              groceryProvider.sortItems(selectedOption);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: SortOption.expiryDate,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Expiry Date'),
                    if (groceryProvider.currentSort == SortOption.expiryDate)
                      Icon(Icons.check, color: Colors.green.shade600),
                  ],
                ),
              ),
              PopupMenuItem(
                value: SortOption.name,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Sort by Name (A-Z)'),
                    if (groceryProvider.currentSort == SortOption.name)
                      Icon(Icons.check, color: Colors.green.shade600),
                  ],
                ),
              ),
              PopupMenuItem(
                value: SortOption.quantity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Sort by Quantity (High to Low)'),
                    if (groceryProvider.currentSort == SortOption.quantity)
                      Icon(Icons.check, color: Colors.green.shade600),
                  ],
                ),
              ),
            ],
          ),
          // Settings button
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.green.shade600,
            ),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen())
              );
            },
          ),
        ],
      ),
      body: groceryProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : groceryProvider.items.isEmpty
          ? const Center(
        child: Text(
          'Your pantry is empty!\nTap the + to add an item.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: groceryProvider.items.length,
        itemBuilder: (context, index) {
          final item = groceryProvider.items[index];
          // Using a Dismissible for swipe-to-delete functionality
          return Dismissible(
            key: ValueKey(item.id),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              // Delete the item from the database and state
              groceryProvider.deleteItem(item.id!);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item.name} deleted.')),
              );
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: GroceryCard(item: item), // The display widget
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addFab',
        onPressed: () {
          // Navigate to the screen to add a new item
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddItemScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}