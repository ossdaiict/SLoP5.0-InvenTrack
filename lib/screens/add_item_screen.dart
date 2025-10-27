// lib/screens/add_item_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/grocery_item.dart';
import '../providers/grocery_provider.dart';
import '../utils/constants.dart';
import 'package:image_picker/image_picker.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Field Controllers
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  String _selectedCategory = Constants.categories.first;
  String _selectedUnit = Constants.units.first;
  DateTime? _selectedExpiryDate;
  File? _pickedImage;
  // Cleanup controllers
  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  // Helper to show the date picker
  Future<void> _selectExpiryDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedExpiryDate = pickedDate;
      });
    }
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  // Form submission logic
  void _submitForm() {
    if (_formKey.currentState!.validate() && _selectedExpiryDate != null) {
      final name = _nameController.text.trim();
      final quantity = double.tryParse(_quantityController.text) ?? 0.0;

      if (quantity <= 0.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quantity must be greater than zero.')),
        );
        return;
      }

      final newItem = GroceryItem(
        name: name,
        category: _selectedCategory,
        quantity: quantity,
        unit: _selectedUnit,
        expiryDate: _selectedExpiryDate!,
        createdAt: DateTime.now(),
        imagePath: _pickedImage?.path, // Placeholder for image path
      );

      // Call the provider to add the item
      Provider.of<GroceryProvider>(context, listen: false).addItem(newItem);

      // Show confirmation and close the screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added $name to GrocyTrack!')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select an expiry date.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage:
                        _pickedImage != null ? FileImage(_pickedImage!) : null,
                    child: _pickedImage == null
                        ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name (e.g., Milk, Eggs)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an item name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Quantity & Unit Row
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly, // only allow digits
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a quantity.';
                        }
                        final quantity = int.tryParse(value);
                        if (quantity == null) {
                          return 'Please enter a valid number.';
                        }
                        if(quantity <= 0) {
                          return 'Quantity must be greater than zero.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                      ),
                      items: Constants.units
                          .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedUnit = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: Constants.categories
                    .map((category) =>
                    DropdownMenuItem(value: category, child: Text(category)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Expiry Date Picker Button
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  _selectedExpiryDate == null
                      ? 'Select Expiry Date'
                      : 'Expiry Date: ${DateFormat.yMMMd().format(_selectedExpiryDate!)}',
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: const Icon(Icons.edit),
                onTap: _selectExpiryDate,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.save),
                label: const Text('Save Item'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}