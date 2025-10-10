// lib/widgets/grocery_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // You'll need to add the intl package
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
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
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
              style: TextStyle(fontSize: 12, color: expiryColor),
            ),
          ],
        ),
      ),
    );
  }
}