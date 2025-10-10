// lib/models/grocery_item.dart

import 'package:flutter/foundation.dart';
import '../utils/constants.dart';

@immutable
class GroceryItem {
  final int? id;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final DateTime expiryDate;
  final String? imagePath;
  final DateTime createdAt;

  const GroceryItem({
    this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.expiryDate,
    this.imagePath,
    required this.createdAt,
  });

  // Converting a GroceryItem object into a Map for the database
  Map<String, dynamic> toMap() {
    return {
      Constants.id: id, // Nullable for new items
      Constants.name: name,
      Constants.category: category,
      Constants.quantity: quantity,
      Constants.unit: unit,
      Constants.expiryDate: expiryDate.toIso8601String(),
      Constants.imagePath: imagePath,
      Constants.createdAt: createdAt.toIso8601String(),
    };
  }

  // Creating a GroceryItem object from a database Map
  factory GroceryItem.fromMap(Map<String, dynamic> map) {
    return GroceryItem(
      id: map[Constants.id] as int?,
      name: map[Constants.name] as String,
      category: map[Constants.category] as String,
      quantity: map[Constants.quantity] as double,
      unit: map[Constants.unit] as String,
      expiryDate: DateTime.parse(map[Constants.expiryDate] as String),
      imagePath: map[Constants.imagePath] as String?,
      createdAt: DateTime.parse(map[Constants.createdAt] as String),
    );
  }

  // Helper method for updating item without changing all fields
  GroceryItem copyWith({
    int? id,
    String? name,
    String? category,
    double? quantity,
    String? unit,
    DateTime? expiryDate,
    String? imagePath,
    DateTime? createdAt,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      expiryDate: expiryDate ?? this.expiryDate,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}