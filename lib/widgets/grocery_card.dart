// lib/widgets/grocery_card.dart

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // You'll need to add the intl package
import 'package:iventrack/providers/grocery_provider.dart';
import 'package:provider/provider.dart';
import '../models/grocery_item.dart';
import '../screens/edit_item_screen.dart';

class GroceryCard extends StatelessWidget {
  final GroceryItem item;

  const GroceryCard({super.key, required this.item});

  // Calculate days remaining until expiry
  int getDaysRemaining() {
    final now = DateTime.now();
    final difference = item.expiryDate.difference(now);
    return difference.inDays;
  }

  @override
  Widget build(BuildContext context) {
    final days = getDaysRemaining();
    Color expiryColor;

    if (days < 0) {
      expiryColor = Colors.red;
    } else if (days <= 7) {
      expiryColor = Colors.orange;
    } else {
      expiryColor = Colors.green;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1.5,
      child: ListTile(
        onTap: () {
          // Navigate to the edit screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditItemScreen(item: item),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: expiryColor.withOpacity(0.1),
          child: Icon(
            days < 0 ? Icons.error_outline : Icons.shopping_bag,
            color: expiryColor,
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
            'Category: ${item.category}\nAdded: ${DateFormat.yMd().format(item.createdAt)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Quantity and Unit
                Text(
                  '${item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 2)} ${item.unit}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: item.quantity <= 1 ? Colors.deepOrange : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                // Expiry Info
                Text(
                  days < 0
                      ? 'Expired ${-days} days ago'
                      : days == 0
                      ? 'Expires TODAY!'
                      : 'Expires in $days days',
                  style: TextStyle(fontSize: 12 , color: expiryColor),
                ),
              ],
            ),
                // const SizedBox(width: 10),
                // Quick Action Button
                IconButton(
                  icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                  tooltip: 'Mark as Used',
                  onPressed: () => _showConsumeDialog(context, item),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                ),
              ],
            ),
          ),
        );
      }

  // Modal Dialog for entering consumption amount
  void _showConsumeDialog(BuildContext context, GroceryItem item) {
  final TextEditingController controller = TextEditingController(text: '1');
  double availableQuantity = item.quantity;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Consume ${item.name}'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Available: ${availableQuantity.toStringAsFixed(2)} ${item.unit}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Decrease button
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        double current = double.tryParse(controller.text) ?? 0;
                        if (current > 0) {
                          setState(() => controller.text = (current - 1).toString());
                        }
                      },
                    ),
                    // TextField for manual entry
                    SizedBox(
                      width: 60,
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    // Increase button
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        double current = double.tryParse(controller.text) ?? 0;
                        if (current < availableQuantity) {
                          setState(() => controller.text = (current + 1).toString());
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Cannot exceed available quantity (${availableQuantity.toStringAsFixed(2)} ${item.unit})',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text) ?? 1;
              if (amount > availableQuantity) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Cannot consume more than available quantity!')),
                );
                return;
              }

              await context.read<GroceryProvider>().markAsUsed(item, amount);
              Navigator.pop(context);

              final updatedQuantity = item.quantity - amount;
              if (updatedQuantity <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item.name} used up and removed')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item.name} used ($amount ${item.unit})')),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      );
    },
  );
}

}