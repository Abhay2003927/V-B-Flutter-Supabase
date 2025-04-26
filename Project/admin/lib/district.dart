import 'package:admin/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class District extends StatefulWidget {
  const District({super.key});

  @override
  State<District> createState() => _DistrictState();
}

class _DistrictState extends State<District> {
  final _formKey = GlobalKey<FormState>();
  final _districtController = TextEditingController();
  List<Map<String, dynamic>> _fetchedDistricts = [];
  int _editId = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _insertDistrict() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await supabase.from("tbl_district").insert({'district_name': _districtController.text});
        await _fetchData();
        _districtController.clear();
        _showSuccess('District inserted successfully');
      } catch (e) {
        _showError('Insert Failed: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchData() async {
    try {
      final response = await supabase.from("tbl_district").select();
      setState(() {
        _fetchedDistricts = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      _showError('Error fetching districts: $e');
    }
  }

  Future<void> _deleteDistrict(int id) async {
    setState(() => _isLoading = true);
    try {
      await supabase.from('tbl_district').delete().eq('id', id);
      await _fetchData();
      _showSuccess('District deleted successfully');
    } catch (e) {
      _showError('Error deleting district: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateDistrict() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await supabase.from("tbl_district").update({
          "district_name": _districtController.text,
        }).eq('id', _editId);
        await _fetchData();
        _districtController.clear();
        setState(() => _editId = 0);
        _showSuccess('District updated successfully');
      } catch (e) {
        _showError('Error updating district: $e');
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
                    'Manage Districts',
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
                          controller: _districtController,
                          decoration: InputDecoration(
                            labelText: 'District Name',
                            hintText: 'Enter district name',
                            prefixIcon: const Icon(Icons.location_city, color: Colors.blueGrey),
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
                              return 'Please enter a district name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : (_editId == 0 ? _insertDistrict : _updateDistrict),
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
                                _editId == 0 ? 'Add District' : 'Update District',
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
                            _districtController.clear();
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
          // Districts List Section
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
                  'District List',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 16),
                _fetchedDistricts.isEmpty
                    ? Center(
                        child: Text(
                          'No districts found',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.grey),
                        itemCount: _fetchedDistricts.length,
                        itemBuilder: (context, index) {
                          final district = _fetchedDistricts[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            leading: Text(
                              district['district_name'],
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blueGrey),
                                  onPressed: () {
                                    setState(() {
                                      _districtController.text = district['district_name'];
                                      _editId = district['id'];
                                    });
                                  },
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteDistrict(district['id']),
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
    _districtController.dispose();
    super.dispose();
  }
}