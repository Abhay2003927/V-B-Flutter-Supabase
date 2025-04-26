import 'package:admin/main.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Category extends StatefulWidget {
  const Category({super.key});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _imageUrlController = TextEditingController();
  List<Map<String, dynamic>> _fetchedCategories = [];
  PlatformFile? _pickedImage;
  int _editId = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _handleImagePick() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result != null && mounted) {
        setState(() {
          _pickedImage = result.files.first;
          _imageUrlController.text = _pickedImage!.name;
        });
      }
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }

  Future<String?> _photoUpload() async {
    if (_pickedImage == null) return null;
    try {
      final bucketName = 'shop'; // Replace with your Supabase storage bucket name
      final filePath = "${DateTime.now().millisecondsSinceEpoch}-cat-${_pickedImage!.name}";
      await supabase.storage.from(bucketName).uploadBinary(
            filePath,
            _pickedImage!.bytes!,
          );
      return supabase.storage.from(bucketName).getPublicUrl(filePath);
    } catch (e) {
      _showError('Error uploading photo: $e');
      return null;
    }
  }

  Future<void> _insertCategory() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        String? photoUrl = await _photoUpload();
        await supabase.from("tbl_category").insert({
          'category_name': _categoryController.text,
          'category_image': photoUrl,
        });
        await _fetchData();
        _resetForm();
        _showSuccess('Category inserted successfully');
      } catch (e) {
        _showError('Insert Failed: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchData() async {
    try {
      final response = await supabase.from("tbl_category").select();
      setState(() {
        _fetchedCategories = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      _showError('Error fetching categories: $e');
    }
  }

  Future<void> _deleteCategory(int id) async {
    setState(() => _isLoading = true);
    try {
      await supabase.from('tbl_category').delete().eq('id', id);
      await _fetchData();
      _showSuccess('Category deleted successfully');
    } catch (e) {
      _showError('Error deleting category: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateCategory() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final updateData = {'category_name': _categoryController.text};
        if (_pickedImage != null) {
          String? photoUrl = await _photoUpload();
          if (photoUrl != null) updateData['category_image'] = photoUrl;
        }
        await supabase.from("tbl_category").update(updateData).eq('id', _editId);
        await _fetchData();
        _resetForm();
        _showSuccess('Category updated successfully');
      } catch (e) {
        _showError('Error updating category: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _resetForm() {
    _categoryController.clear();
    _imageUrlController.clear();
    setState(() {
      _pickedImage = null;
      _editId = 0;
    });
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form Section
          Container(
            width: screenWidth > 800 ? 600 : screenWidth * 0.9,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Manage Categories',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _categoryController,
                          decoration: _inputDecoration('Category Name', Icons.category),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a category name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _imageUrlController,
                          readOnly: true,
                          onTap: _handleImagePick,
                          decoration: _inputDecoration('Category Image', Icons.image).copyWith(
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.upload, color: Colors.blueGrey),
                              onPressed: _handleImagePick,
                            ),
                          ),
                          validator: (value) {
                            if (_editId == 0 && (_pickedImage == null || value!.isEmpty)) {
                              return 'Please select an image';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : (_editId == 0 ? _insertCategory : _updateCategory),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey[700],
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                _editId == 0 ? 'Add Category' : 'Update Category',
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),
                      ),
                    ],
                  ),
                  if (_editId != 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextButton(
                        onPressed: _resetForm,
                        child: const Text('Cancel Edit', style: TextStyle(color: Colors.red)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Categories List Section
          Container(
            width: screenWidth > 800 ? 600 : screenWidth * 0.9,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Category List',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 16),
                _fetchedCategories.isEmpty
                    ? Center(
                        child: Text(
                          'No categories found',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.grey),
                        itemCount: _fetchedCategories.length,
                        itemBuilder: (context, index) {
                          final category = _fetchedCategories[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            leading: CircleAvatar(
                              backgroundImage: category['category_image'] != null ? NetworkImage(category['category_image']) : null,
                              backgroundColor: Colors.grey[200],
                              radius: 20,
                              child: category['category_image'] == null
                                  ? const Icon(Icons.image_not_supported, color: Colors.grey)
                                  : null,
                            ),
                            title: Text(
                              category['category_name'],
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blueGrey),
                                  onPressed: () {
                                    setState(() {
                                      _categoryController.text = category['category_name'];
                                      _imageUrlController.text = category['category_image'] ?? '';
                                      _pickedImage = null; // Reset image unless new one picked
                                      _editId = category['id'];
                                    });
                                  },
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteCategory(category['id']),
                                  tooltip: 'Delete',
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blueGrey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: Colors.grey[100],
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.blueGrey, width: 2),
      ),
    );
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}