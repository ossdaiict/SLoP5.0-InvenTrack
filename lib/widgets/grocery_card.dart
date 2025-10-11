// lib/widgets/grocery_card.dart

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
  int amount = 1; // initial counter value
  final TextEditingController controller = TextEditingController(text: amount.toString());

  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Consume Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Counter row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Minus button
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    if (amount > 1) {
                      setState(() {
                        amount--;
                        controller.text = amount.toString();
                      });
                    }
                  },
                ),
                // Editable TextField
                SizedBox(
                  width: 50,
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed != null && parsed > 0) {
                        setState(() {
                          amount = parsed;
                        });
                      }
                    },
                  ),
                ),
                // Plus button
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    setState(() {
                      amount++;
                      controller.text = amount.toString();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<GroceryProvider>().markAsUsed(item, amount.toDouble());
              Navigator.pop(context);

              // Check if item still exists
              final provider = context.read<GroceryProvider>();
              final exists = provider.items.any((i) => i.id == item.id);


              if (!exists) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item.name} used up and removed!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item.name} used ($amount)')),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    ),
  );
}

}