import 'package:admin/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Year extends StatefulWidget {
  const Year({super.key});

  @override
  State<Year> createState() => _YearState();
}

class _YearState extends State<Year> {
  final _formKey = GlobalKey<FormState>();
  final _yearController = TextEditingController();
  List<Map<String, dynamic>> _fetchedYears = [];
  int _editId = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _insertYear() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await supabase.from("tbl_year").insert({'year_name': _yearController.text});
        await _fetchData();
        _yearController.clear();
        _showSuccess('Year inserted successfully');
      } catch (e) {
        _showError('Insert Failed: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchData() async {
    try {
      final response = await supabase.from("tbl_year").select();
      setState(() {
        _fetchedYears = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      _showError('Error fetching years: $e');
    }
  }

  Future<void> _deleteYear(int id) async {
    setState(() => _isLoading = true);
    try {
      await supabase.from('tbl_year').delete().eq('id', id);
      await _fetchData();
      _showSuccess('Year deleted successfully');
    } catch (e) {
      _showError('Error deleting year: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateYear() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await supabase.from("tbl_year").update({
          "year_name": _yearController.text,
        }).eq('id', _editId);
        await _fetchData();
        _yearController.clear();
        setState(() => _editId = 0);
        _showSuccess('Year updated successfully');
      } catch (e) {
        _showError('Error updating year: $e');
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
                    'Manage Years',
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
                          controller: _yearController,
                          decoration: InputDecoration(
                            labelText: 'Year',
                            hintText: 'Enter year (e.g., 2023)',
                            prefixIcon: const Icon(Icons.date_range, color: Colors.blueGrey),
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
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a year';
                            }
                            if (int.tryParse(value) == null || int.parse(value) < 1900 || int.parse(value) > DateTime.now().year + 1) {
                              return 'Enter a valid year (1900-${DateTime.now().year + 1})';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : (_editId == 0 ? _insertYear : _updateYear),
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
                                _editId == 0 ? 'Add Year' : 'Update Year',
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
                            _yearController.clear();
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
          // Years List Section
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
                  'Year List',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 16),
                _fetchedYears.isEmpty
                    ? Center(
                        child: Text(
                          'No years found',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.grey),
                        itemCount: _fetchedYears.length,
                        itemBuilder: (context, index) {
                          final year = _fetchedYears[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            leading: Text(
                              year['year_name'],
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blueGrey),
                                  onPressed: () {
                                    setState(() {
                                      _yearController.text = year['year_name'];
                                      _editId = year['id'];
                                    });
                                  },
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteYear(year['id']),
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
    _yearController.dispose();
    super.dispose();
  }
}