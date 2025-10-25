// lib/db/database_helper.dart

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/grocery_item.dart';
import '../utils/constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, Constants.databaseName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Method to create the 'groceries' table
  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      '''
      CREATE TABLE ${Constants.tableName}(
        ${Constants.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Constants.name} TEXT NOT NULL,
        ${Constants.category} TEXT NOT NULL,
        ${Constants.quantity} REAL NOT NULL,
        ${Constants.unit} TEXT NOT NULL,
        ${Constants.expiryDate} TEXT NOT NULL,
        ${Constants.imagePath} TEXT,
        ${Constants.createdAt} TEXT NOT NULL
      )
      ''',
    );
  }

  // --- CRUD Operations ---

  // Create/Insert an item
  Future<int> insertItem(GroceryItem item) async {
    final db = await database;
    return await db.insert(
      Constants.tableName,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Read all items
  Future<List<GroceryItem>> getItems() async {
    final db = await database;
    // Order by expiry date ascending
    final List<Map<String, dynamic>> maps = await db.query(
      Constants.tableName,
      orderBy: '${Constants.expiryDate} ASC',
    );

    return List.generate(maps.length, (i) {
      return GroceryItem.fromMap(maps[i]);
    });
  }

  // Update an existing item
  Future<int> updateItem(GroceryItem item) async {
    final db = await database;
    return await db.update(
      Constants.tableName,
      item.toMap(),
      where: '${Constants.id} = ?',
      whereArgs: [item.id],
    );
  }

  // Delete an item
  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete(
      Constants.tableName,
      where: '${Constants.id} = ?', 
      whereArgs: [id],
    );
  }

  // Securely delete all groceries
  Future<void> deleteAllGroceries() async {
    final db = await database;
    await db.delete(Constants.tableName);
    debugPrint(" All grocery records deleted from the database.");
  }

  // Close the database connection (optional, good practice)
  Future<void> closeDb() async {
    final db = await database;
    db.close();
    _database = null;
  }
}