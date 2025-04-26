import 'package:admin/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Brand extends StatefulWidget {
  const Brand({super.key});

  @override
  State<Brand> createState() => _BrandState();
}

class _BrandState extends State<Brand> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  List<Map<String, dynamic>> _fetchedBrands = [];
  int _editId = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _insertBrand() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await supabase.from("tbl_brand").insert({'brand_name': _brandController.text});
        await _fetchData();
        _brandController.clear();
        _showSuccess('Brand inserted successfully');
      } catch (e) {
        _showError('Insert Failed: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchData() async {
    try {
      final response = await supabase.from("tbl_brand").select();
      setState(() {
        _fetchedBrands = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      _showError('Error fetching brands: $e');
    }
  }

  Future<void> _deleteBrand(int id) async {
    setState(() => _isLoading = true);
    try {
      await supabase.from('tbl_brand').delete().eq('id', id);
      await _fetchData();
      _showSuccess('Brand deleted successfully');
    } catch (e) {
      _showError('Error deleting brand: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateBrand() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await supabase.from("tbl_brand").update({
          "brand_name": _brandController.text,
        }).eq('id', _editId);
        await _fetchData();
        _brandController.clear();
        setState(() => _editId = 0);
        _showSuccess('Brand updated successfully');
      } catch (e) {
        _showError('Error updating brand: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
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
                    'Manage Brands',
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
                          controller: _brandController,
                          decoration: InputDecoration(
                            labelText: 'Brand Name',
                            hintText: 'Enter brand name',
                            prefixIcon: const Icon(Icons.branding_watermark, color: Colors.blueGrey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.blueGrey, width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a brand name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : (_editId == 0 ? _insertBrand : _updateBrand),
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
                                _editId == 0 ? 'Add Brand' : 'Update Brand',
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),
                      ),
                    ],
                  ),
                  if (_editId != 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _brandController.clear();
                            _editId = 0;
                          });
                        },
                        child: const Text('Cancel Edit', style: TextStyle(color: Colors.red)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Brands List Section
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
                  'Brand List',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 16),
                _fetchedBrands.isEmpty
                    ? Center(
                        child: Text(
                          'No brands found',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.grey),
                        itemCount: _fetchedBrands.length,
                        itemBuilder: (context, index) {
                          final brand = _fetchedBrands[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            leading: Text(
                              brand['brand_name'],
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blueGrey),
                                  onPressed: () {
                                    setState(() {
                                      _brandController.text = brand['brand_name'];
                                      _editId = brand['id'];
                                    });
                                  },
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteBrand(brand['id']),
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

  @override
  void dispose() {
    _brandController.dispose();
    super.dispose();
  }
}