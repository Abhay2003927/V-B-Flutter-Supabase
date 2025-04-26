import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:user/main.dart';

class ComplaintsScreen extends StatefulWidget {
  final int product; // Added userId parameter to track the submitting user
  const ComplaintsScreen({super.key, required this.product});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _complaintPhotoController = TextEditingController();
  PlatformFile? pickedImage;

  String? _selectedCategory;
  bool _isSubmitting = false;

  final List<String> _categories = [
    "Product Issue",
    "Late Delivery",
    "Damaged Item",
    "Payment Issue",
    "Other"
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitComplaint() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        // Simulate API call to Supabase or your backend
        await Future.delayed(const Duration(seconds: 1)); // Mock delay
        await _insertComplaint(widget.product);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Complaint Submitted Successfully!"),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );

          // Reset form
          _titleController.clear();
          _descriptionController.clear();
          setState(() {
            _selectedCategory = null;
          });

          // Navigate back or to homepage
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error submitting complaint: $e"),
              backgroundColor: Colors.red[600],
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  Future<void> _insertComplaint(int product) async {
    String? photourl = await photoUpload(); 
    // Replace with your actual Supabase or backend integration
    await supabase.from('tbl_complaint').insert({
      'user_id': supabase.auth.currentUser!.id,
      'complaint_title': _titleController.text.trim(),
      'complaint_content': _descriptionController.text.trim(),
      'category_post': _selectedCategory,
      'complaint_photo':  photourl,
      'product_id': product,
    });
   
    print("Complaint photo URL: $photourl");
  }
Future<String?> photoUpload() async {
  try {
    // Check if photo is null
    if ( pickedImage == null) {
      print("Error: No photo selected");
      return null;
    }

    final bucketName = 'shop';
    String formattedDate = DateFormat('dd-MM-yyyy-HH-mm').format(DateTime.now());
    final filePath = "$formattedDate-${ pickedImage!.name}";
    print("File path: $filePath");

    // Handle the upload based on platform
    Uint8List? fileBytes;
    
    // For web, bytes should be available
    if ( pickedImage!.bytes != null) {
      fileBytes =  pickedImage!.bytes;
    } 
    // For mobile platforms, read bytes from path if available
    else if ( pickedImage!.path != null) {
      final file = File( pickedImage!.path!);
      fileBytes = await file.readAsBytes();
    } else {
      print("Error: Unable to get file bytes");
      return null;
    }

    if (fileBytes == null) {
      print("Error: File bytes are null");
      return null;
    }

    await supabase.storage
        .from(bucketName)
        .uploadBinary(filePath, fileBytes);

    return supabase.storage.from(bucketName).getPublicUrl(filePath);
  } catch (e) {
    print("Error photo upload: $e");
    return null;
  }
}
Future<void> handleImagePick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image,
    );
    if (result != null) {
      setState(() {
        pickedImage = result.files.first;
        _complaintPhotoController.text = result.files.first.name;
      });
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "File a Complaint",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red[800],
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Dropdown
                _buildSectionTitle("Complaint Category"),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? "Please select a category" : null,
                  decoration: _inputDecoration("Select Category"),
                ),
                const SizedBox(height: 20),

                // Title Field
                _buildSectionTitle("Complaint Title"),
                TextFormField(
                  controller: _titleController,
                  decoration: _inputDecoration("Enter complaint title"),
                  validator: (value) =>
                      value!.isEmpty ? "Title cannot be empty" : null,
                ),
                const SizedBox(height: 20),

                _buildSectionTitle("Complaint Photo"),
                TextFormField(
                   readOnly: true,
                      onTap: handleImagePick,
                  controller: _complaintPhotoController,
                  maxLines: 1,
                  decoration: _inputDecoration("Upload your complaint photo"),
                  validator: (value) =>
                      value!.isEmpty ? "Description cannot be empty" : null,
                ),
                const SizedBox(height: 20),

                // Description Field
                _buildSectionTitle("Description"),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: _inputDecoration("Describe your issue in detail"),
                  validator: (value) =>
                      value!.isEmpty ? "Description cannot be empty" : null,
                ),
                const SizedBox(height: 30),

                

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitComplaint,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Submit Complaint",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red[800]!, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: Colors.grey[100],
    );
  }
}

// Example usage:
// void main() {
//   runApp(MaterialApp(
//     home: ComplaintsScreen(userId: "user123"),
//     theme: ThemeData(
//       primarySwatch: Colors.red,
//       visualDensity: VisualDensity.adaptivePlatformDensity,
//     ),
//   ));
// }
