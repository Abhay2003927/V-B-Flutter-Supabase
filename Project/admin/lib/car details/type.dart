import 'package:admin/main.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TypeScreen extends StatefulWidget {
  const TypeScreen({super.key});

  @override
  State<TypeScreen> createState() => _TypeState();
}

class _TypeState extends State<TypeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _imageUrlController = TextEditingController();
  List<Map<String, dynamic>> _fetchedTypes = [];
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

  Future<String?> _photoUpload(String uid, String type) async {
    if (_pickedImage == null) return null;
    try {
      final bucketName = 'shop'; // Replace with your Supabase storage bucket name
      final filePath = "${DateTime.now().millisecondsSinceEpoch}-$type-${_pickedImage!.name}";
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

  Future<void> _insertType() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final uid = supabase.auth.currentUser?.id ?? '1'; // Use actual UID or fallback
        String? photoUrl = await _photoUpload(uid, 'type');
        await supabase.from("tbl_type").insert({
          'type_name': _typeController.text,
          'type_image': photoUrl,
        });
        await _fetchData();
        _resetForm();
        _showSuccess('Type inserted successfully');
      } catch (e) {
        _showError('Insert Failed: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchData() async {
    try {
      final response = await supabase.from("tbl_type").select();
      setState(() {
        _fetchedTypes = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      _showError('Error fetching types: $e');
    }
  }

  Future<void> _deleteType(int id) async {
    setState(() => _isLoading = true);
    try {
      await supabase.from('tbl_type').delete().eq('id', id);
      await _fetchData();
      _showSuccess('Type deleted successfully');
    } catch (e) {
      _showError('Error deleting type: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateType() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final updateData = {'type_name': _typeController.text};
        if (_pickedImage != null) {
          final uid = supabase.auth.currentUser?.id ?? '1';
          String? photoUrl = await _photoUpload(uid, 'type');
          if (photoUrl != null) updateData['type_image'] = photoUrl;
        }
        await supabase.from("tbl_type").update(updateData).eq('id', _editId);
        await _fetchData();
        _resetForm();
        _showSuccess('Type updated successfully');
      } catch (e) {
        _showError('Error updating type: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _resetForm() {
    _typeController.clear();
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
                    'Manage Types',
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
                          controller: _typeController,
                          decoration: _inputDecoration('Type Name', Icons.directions_car),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a type name';
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
                          decoration: _inputDecoration('Type Image', Icons.image).copyWith(
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
                        onPressed: _isLoading ? null : (_editId == 0 ? _insertType : _updateType),
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
                                _editId == 0 ? 'Add Type' : 'Update Type',
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
          // Types List Section
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
                  'Type List',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 16),
                _fetchedTypes.isEmpty
                    ? Center(
                        child: Text(
                          'No types found',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.grey),
                        itemCount: _fetchedTypes.length,
                        itemBuilder: (context, index) {
                          final type = _fetchedTypes[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            leading: CircleAvatar(
                              backgroundImage: type['type_image'] != null ? NetworkImage(type['type_image']) : null,
                              backgroundColor: Colors.grey[200],
                              radius: 20,
                              child: type['type_image'] == null
                                  ? const Icon(Icons.image_not_supported, color: Colors.grey)
                                  : null,
                            ),
                            title: Text(
                              type['type_name'],
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blueGrey),
                                  onPressed: () {
                                    setState(() {
                                      _typeController.text = type['type_name'];
                                      _imageUrlController.text = type['type_image'] ?? '';
                                      _pickedImage = null; // Reset image for update unless new one picked
                                      _editId = type['id'];
                                    });
                                  },
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteType(type['id']),
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
    _typeController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}