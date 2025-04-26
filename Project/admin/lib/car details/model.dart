import 'package:admin/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ModelScreen extends StatefulWidget {
  const ModelScreen({super.key});

  @override
  State<ModelScreen> createState() => _ModelScreenState();
}

class _ModelScreenState extends State<ModelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  List<Map<String, dynamic>> _modelList = [];
  List<Map<String, dynamic>> _brandList = [];
  List<Map<String, dynamic>> _typeList = [];
  String? _selectedBrand;
  String? _selectedType;
  int _editId = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchBrands();
    _fetchTypes();
    _fetchModels();
  }

  Future<void> _fetchBrands() async {
    try {
      final response = await supabase.from('tbl_brand').select();
      setState(() {
        _brandList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      _showError('Error fetching brands: $e');
    }
  }

  Future<void> _fetchTypes() async {
    try {
      final response = await supabase.from('tbl_type').select();
      setState(() {
        _typeList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      _showError('Error fetching types: $e');
    }
  }

  Future<void> _fetchModels() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase.from('tbl_model').select();
      setState(() {
        _modelList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      _showError('Error fetching models: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _insertModel() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await supabase.from("tbl_model").insert({
          'model_name': _modelController.text,
          'brand_id': _selectedBrand,
          'type_id': _selectedType,
        });
        await _fetchModels();
        _modelController.clear();
        setState(() {
          _selectedBrand = null;
          _selectedType = null;
        });
        _showSuccess('Model inserted successfully');
      } catch (e) {
        _showError('Error inserting model: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateModel() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await supabase.from('tbl_model').update({
          'model_name': _modelController.text,
          'brand_id': _selectedBrand,
          'type_id': _selectedType,
        }).eq('id', _editId);
        await _fetchModels();
        _modelController.clear();
        setState(() {
          _editId = 0;
          _selectedBrand = null;
          _selectedType = null;
        });
        _showSuccess('Model updated successfully');
      } catch (e) {
        _showError('Error updating model: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteModel(int id) async {
    setState(() => _isLoading = true);
    try {
      await supabase.from("tbl_model").delete().eq('id', id);
      await _fetchModels();
      _showSuccess('Model deleted successfully');
    } catch (e) {
      _showError('Error deleting model: $e');
    } finally {
      setState(() => _isLoading = false);
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form Section
          Container(
            width: screenWidth > 800 ? 990 : screenWidth * 0.5,
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
                    'Manage Models',
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
                        child: DropdownButtonFormField<String>(
                          decoration: _inputDecoration('Brand', Icons.branding_watermark),
                          value: _selectedBrand,
                          items: _brandList.map((brand) {
                            return DropdownMenuItem<String>(
                              value: brand['id'].toString(),
                              child: Text(brand['brand_name'] ?? 'Unknown'),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedBrand = value),
                          validator: (value) => value == null ? 'Please select a brand' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: _inputDecoration('Type', Icons.directions_car),
                          value: _selectedType,
                          items: _typeList.map((type) {
                            return DropdownMenuItem<String>(
                              value: type['id'].toString(),
                              child: Text(type['type_name'] ?? 'Unknown'),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedType = value),
                          validator: (value) => value == null ? 'Please select a type' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _modelController,
                          decoration: _inputDecoration('Model Name', Icons.precision_manufacturing),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a model name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : (_editId == 0 ? _insertModel : _updateModel),
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
                                _editId == 0 ? 'Add Model' : 'Update Model',
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
                            _modelController.clear();
                            _selectedBrand = null;
                            _selectedType = null;
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
          // Models List Section
          Container(
            
            width: screenWidth > 800 ? 990 : screenWidth * 0.9,
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
                  'Model List',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 16),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _modelList.isEmpty
                        ? Center(
                            child: Text(
                              'No models found',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.grey),
                            itemCount: _modelList.length,
                            itemBuilder: (context, index) {
                              final model = _modelList[index];
                              final brandName = _brandList
                                      .firstWhere((b) => b['id'].toString() == model['brand_id'].toString(),
                                          orElse: () => {'brand_name': 'Unknown'})['brand_name'] ??
                                  'Unknown';
                              final typeName = _typeList
                                      .firstWhere((t) => t['id'].toString() == model['type_id'].toString(),
                                          orElse: () => {'type_name': 'Unknown'})['type_name'] ??
                                  'Unknown';
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                title: Text(
                                  model['model_name'] ?? 'Unnamed',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                                ),
                                subtitle: Text(
                                  'Brand: $brandName | Type: $typeName',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blueGrey),
                                      onPressed: () {
                                        setState(() {
                                          _modelController.text = model['model_name'];
                                          _selectedBrand = model['brand_id'].toString();
                                          _selectedType = model['type_id'].toString();
                                          _editId = model['id'];
                                        });
                                      },
                                      tooltip: 'Edit',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteModel(model['id']),
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
    _modelController.dispose();
    super.dispose();
  }
}