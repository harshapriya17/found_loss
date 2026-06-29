import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../controllers/item_controller.dart';
import '../models/item_model.dart';
import '../theme/app_theme.dart';

class ReportItemScreen extends StatefulWidget {
  final String type; // 'lost' or 'found'
  final ItemModel? item; // For editing

  const ReportItemScreen({super.key, required this.type, this.item});

  @override
  State<ReportItemScreen> createState() => _ReportItemScreenState();
}

class _ReportItemScreenState extends State<ReportItemScreen> {
  final ItemController controller = Get.find<ItemController>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _contactController;
  
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  String? _imagePath;

  final List<String> categories = [
    'Electronics',
    'Documents',
    'Keys',
    'Clothing & Accessories',
    'Books & Stationery',
    'Others'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _descriptionController = TextEditingController(text: widget.item?.description ?? '');
    _locationController = TextEditingController(text: widget.item?.location ?? '');
    _contactController = TextEditingController(text: widget.item?.contactNumber ?? '');
    _selectedDate = widget.item?.date ?? DateTime.now();
    _selectedCategory = widget.item?.category;
    _imagePath = widget.item?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source, maxWidth: 800);
      if (pickedFile != null) {
        setState(() => _imagePath = pickedFile.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        Get.snackbar('Error', 'Please select a category', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final newItem = ItemModel(
        id: widget.item?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        type: widget.type,
        category: _selectedCategory!,
        description: _descriptionController.text.trim(),
        date: _selectedDate,
        location: _locationController.text.trim(),
        contactNumber: _contactController.text.trim(),
        status: widget.item?.status ?? (widget.type == 'lost' ? 'Lost' : 'Found'),
        imagePath: _imagePath,
      );

      if (widget.item == null) {
        controller.addItem(newItem);
      } else {
        controller.updateItem(newItem);
      }

      Get.back();
      Get.snackbar('Success', 'Report ${widget.item == null ? 'added' : 'updated'} successfully', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;
    final themeColor = widget.type == 'lost' ? AppTheme.statusLost : AppTheme.statusFound;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text('${isEdit ? 'Edit' : 'Report'} ${widget.type.capitalizeFirst} Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Picker
              _buildImageSelector(themeColor),
              const SizedBox(height: 24),

              // Form Fields
              _buildTextField(
                label: 'Item Name',
                controller: _nameController,
                icon: Icons.inventory_2_outlined,
                validator: (val) => val == null || val.isEmpty ? 'Item name is required' : null,
              ),
              const SizedBox(height: 16),

              _buildDropdownField(),
              const SizedBox(height: 16),

              _buildDateField(themeColor),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Location ${widget.type == 'lost' ? 'Lost' : 'Found'}',
                controller: _locationController,
                icon: Icons.location_on_outlined,
                validator: (val) => val == null || val.isEmpty ? 'Location is required' : null,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Contact Number',
                controller: _contactController,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Contact number is required';
                  }
                  if (val.length != 10) {
                    return 'Mobile number must be exactly 10 digits';
                  }
                  if (!RegExp(r'^[6-9]').hasMatch(val)) {
                    return 'Number must start with 6, 7, 8, or 9';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Description',
                controller: _descriptionController,
                icon: Icons.description_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  isEdit ? 'Update Report' : 'Submit Report',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSelector(Color themeColor) {
    return GestureDetector(
      onTap: () => _showImageSourceOptions(),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: _imagePath != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(File(_imagePath!), fit: BoxFit.cover, width: double.infinity, height: 180),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      radius: 16,
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 16, color: Colors.white),
                        onPressed: () => setState(() => _imagePath = null),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, size: 40, color: themeColor),
                  const SizedBox(height: 8),
                  Text('Add Item Image', style: TextStyle(color: themeColor, fontWeight: FontWeight.bold)),
                  const Text('(Optional)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      hint: const Text('Select Category'),
      decoration: const InputDecoration(
        labelText: 'Category',
        prefixIcon: Icon(Icons.category_outlined),
      ),
      items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
      onChanged: (val) => setState(() => _selectedCategory = val),
    );
  }

  Widget _buildDateField(Color themeColor) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date',
          prefixIcon: Icon(Icons.calendar_month_outlined),
        ),
        child: Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
      ),
    );
  }

  void _showImageSourceOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Image Source', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () { Get.back(); _pickImage(ImageSource.camera); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () { Get.back(); _pickImage(ImageSource.gallery); },
            ),
          ],
        ),
      ),
    );
  }
}
