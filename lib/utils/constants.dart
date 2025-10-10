// lib/utils/constants.dart

class Constants {
  // Database constants
  static const String databaseName = 'grocytrack_db.db';
  static const String tableName = 'groceries';

  // Column names
  static const String id = 'id';
  static const String name = 'name';
  static const String category = 'category';
  static const String quantity = 'quantity';
  static const String unit = 'unit';
  static const String expiryDate = 'expiry_date';
  static const String imagePath = 'image_path';
  static const String createdAt = 'created_at';

  // Categories
  static const List<String> categories = [
    'Dairy',
    'Produce',
    'Meat',
    'Frozen',
    'Pantry',
    'Snacks',
    'Beverages',
    'Other',
  ];

  // Units
  static const List<String> units = [
    'pcs',
    'kg',
    'g',
    'L',
    'ml',
    'pack',
    'bottle',
    'box',
  ];
}