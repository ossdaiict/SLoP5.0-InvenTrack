import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/grocery_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _confirmAndDeleteAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Data Deletion'),
        content: const Text(
          'Are you sure you want to delete ALL grocery records? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop(); 
              await context.read<GroceryProvider>().deleteAllItems();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All grocery data deleted successfully.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            child: const Text('Delete All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'App Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              icon: const Icon(Icons.delete_forever, color: Colors.white),
              label: const Text('Delete All Grocery Records', style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _confirmAndDeleteAll(context),
            ),

            const SizedBox(height: 16),
            const Text(
              'This will permanently remove all grocery items from your local storage.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
