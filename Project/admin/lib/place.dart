import 'package:admin/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Place extends StatefulWidget {
  const Place({super.key});

  @override
  State<Place> createState() => _PlaceState();
}

class _PlaceState extends State<Place> {
  final _formKey = GlobalKey<FormState>();
  final _placeController = TextEditingController();
  List<Map<String, dynamic>> _districtList = [];
  List<Map<String, dynamic>> _placeList = [];
  String? _selectedDistrict;
  int _editId = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchDistricts();
    _fetchPlaces();
  }

  Future<void> _fetchDistricts() async {
    try {
      final response = await supabase.from('tbl_district').select();
      setState(() {
        _districtList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      _showError('Error fetching districts: $e');
    }
  }

  Future<void> _fetchPlaces() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase.from('tbl_place').select();
      setState(() {
        _placeList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      _showError('Error fetching places: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _insertPlace() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await supabase.from("tbl_place").insert({
          'place_name': _placeController.text,
          'district_id': _selectedDistrict,
        });
        await _fetchPlaces();
        _resetForm();
        _showSuccess('Place inserted successfully');
      } catch (e) {
        _showError('Insert Failed: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updatePlace() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await supabase.from('tbl_place').update({
          'place_name': _placeController.text,
          'district_id': _selectedDistrict,
        }).eq('id', _editId);
        await _fetchPlaces();
        _resetForm();
        _showSuccess('Place updated successfully');
      } catch (e) {
        _showError('Error updating place: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deletePlace(int id) async {
    setState(() => _isLoading = true);
    try {
      await supabase.from("tbl_place").delete().eq('id', id);
      await _fetchPlaces();
      _showSuccess('Place deleted successfully');
    } catch (e) {
      _showError('Error deleting place: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _placeController.clear();
    setState(() {
      _selectedDistrict = null;
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
                    'Manage Places',
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
                          decoration: _inputDecoration('District', Icons.location_city),
                          value: _selectedDistrict,
                          items: _districtList.map((district) {
                            return DropdownMenuItem<String>(
                              value: district['id'].toString(),
                              child: Text(district['district_name'] ?? 'Unknown'),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedDistrict = value),
                          validator: (value) => value == null ? 'Please select a district' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _placeController,
                          decoration: _inputDecoration('Place Name', Icons.place),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a place name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : (_editId == 0 ? _insertPlace : _updatePlace),
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
                                _editId == 0 ? 'Add Place' : 'Update Place',
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
          // Places List Section
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
                  'Place List',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 16),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _placeList.isEmpty
                        ? Center(
                            child: Text(
                              'No places found',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.grey),
                            itemCount: _placeList.length,
                            itemBuilder: (context, index) {
                              final place = _placeList[index];
                              final districtName = _districtList
                                      .firstWhere((d) => d['id'].toString() == place['district_id'].toString(),
                                          orElse: () => {'district_name': 'Unknown'})['district_name'] ??
                                  'Unknown';
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                title: Text(
                                  place['place_name'],
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                                ),
                                subtitle: Text(
                                  'District: $districtName',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blueGrey),
                                      onPressed: () {
                                        setState(() {
                                          _placeController.text = place['place_name'];
                                          _selectedDistrict = place['district_id'].toString();
                                          _editId = place['id'];
                                        });
                                      },
                                      tooltip: 'Edit',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deletePlace(place['id']),
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
    _placeController.dispose();
    super.dispose();
  }
}