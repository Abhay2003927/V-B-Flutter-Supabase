import 'package:admin/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Aprofile extends StatefulWidget {
  const Aprofile({super.key});

  @override
  State<Aprofile> createState() => _AprofileState();
}

class _AprofileState extends State<Aprofile> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchadmin();
  }

  Future<void> _fetchadmin() async {
    setState(() => _isLoading = true);
    try {
      final uid = supabase.auth.currentUser!.id;
      if (uid == null) throw Exception('No user logged in');
      final response = await supabase.from("tbl_admin").select().eq('id', uid).single();
      print("response$response");
      setState(() {
        _nameController.text = response['admin_name'] ?? '';
        _emailController.text = response['admin_email'] ?? '';
        _contactController.text = response['admin_contact'] ?? '';
      });
    } catch (e) {
      _showError('Error fetching profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final uid = supabase.auth.currentUser?.id;
        if (uid == null) throw Exception('No user logged in');
        await supabase.from('tbl_admin').update({
          'admin_name': _nameController.text,
          'admin_email': _emailController.text,
          'admin_contact': _contactController.text,
        }).eq('id', uid);
        _showSuccess('Profile updated successfully');
      } catch (e) {
        _showError('Error updating profile: $e');
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
      child: Center(
        child: Container(
          width: screenWidth > 800 ? 500 : screenWidth * 0.9,
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
              mainAxisSize: MainAxisSize.min,
              children: [
                // Profile Header
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blueGrey[100],
                  child: Text(
                    _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : 'A',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Admin Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 24),
                // Profile Fields
                _buildProfileField(
                  label: 'Name',
                  controller: _nameController,
                  icon: Icons.person,
                  validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 16),
                _buildProfileField(
                  label: 'Email',
                  controller: _emailController,
                  icon: Icons.email,
                  isEditable: false, // Email typically not editable post-registration
                ),
                const SizedBox(height: 16),
                _buildProfileField(
                  label: 'Contact',
                  controller: _contactController,
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value!.isEmpty) return 'Please enter your contact number';
                    if (!RegExp(r'^\d{10}$').hasMatch(value)) return 'Enter a valid 10-digit number';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // Update Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[700],
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Update Profile',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isEditable = true,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: !isEditable,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueGrey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey[100],
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blueGrey, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    super.dispose();
  }
}