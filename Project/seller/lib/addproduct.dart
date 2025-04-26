import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:seller/main.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final TextEditingController productName = TextEditingController();
  final TextEditingController productPrice = TextEditingController();
  final TextEditingController productDescription = TextEditingController();
  final TextEditingController productImageUrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  PlatformFile? pickedImage;

  String? selectedCategory;
  String? selectedBrand;
  String? selectedModel;
  String? selectedType;
  String? selectedEngine;
  String? selectedTransmission;
  String? selectedYear;

  List<Map<String, dynamic>> categoryList = [];
  List<Map<String, dynamic>> brandList = [];
  List<Map<String, dynamic>> modelList = [];
  List<Map<String, dynamic>> typeList = [];
  List<Map<String, dynamic>> engineList = [];
  List<Map<String, dynamic>> transmissionList = [];
  List<Map<String, dynamic>> yearList = [];

  @override
  void initState() {
    super.initState();
    fetchCategory();
    fetchType();
    fetchEngine();
    fetchTransmission();
    fetchYear();
  }

  Future<void> fetchCategory() async {
    try {
      final response = await supabase.from('tbl_category').select();
      setState(() {
        categoryList = response.map<Map<String, dynamic>>((item) => {
              'id': item['id'],
              'name': item['category_name'],
            }).toList();
      });
    } catch (e) {
      _showError('Error fetching categories: $e');
    }
  }

  Future<void> fetchType() async {
    try {
      final response = await supabase.from('tbl_type').select();
      setState(() {
        typeList = response.map<Map<String, dynamic>>((item) => {
              'id': item['id'],
              'name': item['type_name'],
            }).toList();
      });
    } catch (e) {
      _showError('Error fetching types: $e');
    }
  }

  Future<void> fetchEngine() async {
    try {
      final response = await supabase.from('tbl_engine').select();
      setState(() {
        engineList = response.map<Map<String, dynamic>>((item) => {
              'id': item['id'],
              'name': item['engine_name'],
            }).toList();
      });
    } catch (e) {
      _showError('Error fetching engines: $e');
    }
  }

  Future<void> fetchTransmission() async {
    try {
      final response = await supabase.from('tbl_transmission').select();
      setState(() {
        transmissionList = response.map<Map<String, dynamic>>((item) => {
              'id': item['id'],
              'name': item['transmission_name'],
            }).toList();
      });
    } catch (e) {
      _showError('Error fetching transmissions: $e');
    }
  }

  Future<void> fetchYear() async {
    try {
      final response = await supabase.from('tbl_year').select();
      setState(() {
        yearList = response.map<Map<String, dynamic>>((item) => {
              'id': item['id'],
              'name': item['year_name'],
            }).toList();
      });
    } catch (e) {
      _showError('Error fetching years: $e');
    }
  }

  Future<void> fetchBrand() async {
    try {
      final response = await supabase.from('tbl_brand').select();
      setState(() {
        brandList = response.map<Map<String, dynamic>>((item) => {
              'id': item['id'],
              'name': item['brand_name'],
            }).toList();
      });
    } catch (e) {
      _showError('Error fetching brands: $e');
    }
  }

  Future<void> fetchModel(String brand, String type) async {
    try {
      final response = await supabase
          .from('tbl_model')
          .select()
          .eq('brand_id', brand)
          .eq('type_id', type);
      setState(() {
        modelList = response.map<Map<String, dynamic>>((item) => {
              'id': item['id'],
              'name': item['model_name'],
            }).toList();
      });
    } catch (e) {
      _showError('Error fetching models: $e');
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
        productImageUrl.text = result.files.first.name;
      });
    }
  }

  Future<String?> photoUpload(String uid, String type) async {
    if (pickedImage == null) return null;
    try {
      final bucketName = 'shop';
      final filePath = "${DateTime.now().millisecondsSinceEpoch}-$type-${pickedImage!.name}";
      await supabase.storage.from(bucketName).uploadBinary(filePath, pickedImage!.bytes!);
      return supabase.storage.from(bucketName).getPublicUrl(filePath);
    } catch (e) {
      _showError('Error uploading image: $e');
      return null;
    }
  }

  Future<void> insert() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      final uid = supabase.auth.currentUser?.id ?? 'temp'; // Replace with actual seller ID
      final photoUrl = await photoUpload(uid, 'photo');
      await supabase.from('tbl_product').insert({
        'product_name': productName.text,
        'product_details': productDescription.text,
        'product_price': double.parse(productPrice.text),
        'category_id': selectedCategory,
        'brand_id': selectedBrand,
        'model_id': selectedModel,
        'type_id': selectedType,
        'year_id': selectedYear,
        'engine_id': selectedEngine,
        'transmission_id': selectedTransmission,
        'product_photo': photoUrl,
        'seller_id': uid,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product Added Successfully")),
        );
        Navigator.pop(context,true);
      }
    } catch (e) {
      _showError('Error adding product: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey[900],
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.blueGrey[50],
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: screenWidth > 800 ? 700 : screenWidth * 0.9,
              padding: const EdgeInsets.all(32),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Add New Product',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: productName,
                      decoration: _inputDecoration('Product Name', Icons.label),
                      validator: (value) => value!.isEmpty ? 'Product name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: productPrice,
                      decoration: _inputDecoration('Product Price', Icons.attach_money),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return 'Price is required';
                        if (double.tryParse(value) == null) return 'Enter a valid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: productDescription,
                      decoration: _inputDecoration('Product Description', Icons.description),
                      maxLines: 3,
                      validator: (value) => value!.isEmpty ? 'Description is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: productImageUrl,
                      readOnly: true,
                      onTap: handleImagePick,
                      decoration: _inputDecoration('Product Image', Icons.image),
                      validator: (value) => value!.isEmpty ? 'Image is required' : null,
                    ),
                    const SizedBox(height: 24),
                    GridView.count(
                      crossAxisCount: screenWidth > 600 ? 2 : 1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: screenWidth > 600 ? 3 : 2,
                      children: [
                        _buildDropdown('Category', categoryList, selectedCategory, (value) => setState(() => selectedCategory = value)),
                        _buildDropdown('Type', typeList, selectedType, (value) {
                          setState(() => selectedType = value);
                          fetchBrand();
                        }),
                        _buildDropdown('Brand', brandList, selectedBrand, (value) {
                          setState(() => selectedBrand = value);
                          if (selectedType != null && value != null) fetchModel(value, selectedType!);
                        }),
                        _buildDropdown('Model', modelList, selectedModel, (value) => setState(() => selectedModel = value)),
                        _buildDropdown('Engine', engineList, selectedEngine, (value) => setState(() => selectedEngine = value)),
                        _buildDropdown('Transmission', transmissionList, selectedTransmission, (value) => setState(() => selectedTransmission = value)),
                        _buildDropdown('Year', yearList, selectedYear, (value) => setState(() => selectedYear = value)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: isLoading ? null : insert,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey[900],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Add Product',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.blueGrey),
      prefixIcon: Icon(icon, color: Colors.blueGrey[700]),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.blueGrey, width: 2),
      ),
    );
  }

  Widget _buildDropdown(String label, List<Map<String, dynamic>> items, String? selectedValue, void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: _inputDecoration(label, Icons.category),
      value: selectedValue,
      items: items.map((item) => DropdownMenuItem<String>(
        value: item['id'].toString(),
        child: Text(item['name'], style: const TextStyle(color: Colors.blueGrey)),
      )).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? '$label is required' : null,
      dropdownColor: Colors.white,
    );
  }

  @override
  void dispose() {
    productName.dispose();
    productPrice.dispose();
    productDescription.dispose();
    productImageUrl.dispose();
    super.dispose();
  }
}