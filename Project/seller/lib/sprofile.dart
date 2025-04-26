import 'package:flutter/material.dart';
import 'package:seller/main.dart';
import 'package:seller/schangepassword.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Sprofile extends StatefulWidget {
  const Sprofile({super.key});

  @override
  State<Sprofile> createState() => _SprofileState();
}

class _SprofileState extends State<Sprofile> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  bool _isLoading = false;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
    try {
      final uid = supabase.auth.currentUser!.id;
      final response = await supabase.from("tbl_seller").select().eq('id', uid).single();
      setState(() {
        nameController.text = response['seller_name'] ?? '';
        emailController.text = response['seller_email'] ?? '';
        contactController.text = response['seller_contact'] ?? '';
        _photoUrl = response['seller_photo'];
      });
    } catch (e) {
      _showError('Error fetching profile: $e');
    }
  }

  Future<void> updateProfile() async {
    if (nameController.text.isEmpty || contactController.text.isEmpty) {
      _showError('Name and contact are required');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await supabase.from('tbl_seller').update({
        'seller_name': nameController.text,
        'seller_email': emailController.text,
        'seller_contact': contactController.text,
      }).eq('id', supabase.auth.currentUser!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      _showError('Error updating profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        title: const Text('Your Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.grey[100],
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: screenWidth > 800 ? 600 : screenWidth * 0.9,
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.deepPurple[100],
                    backgroundImage: _photoUrl != null ? NetworkImage(_photoUrl!) : null,
                    child: _photoUrl == null
                        ? Text(
                            nameController.text.isNotEmpty ? nameController.text[0].toUpperCase() : 'A',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Seller Profile',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your account details',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildProfileField('Name', nameController, Icons.person, true),
                  const SizedBox(height: 16),
                  _buildProfileField('Mobile', contactController, Icons.phone, true),
                  const SizedBox(height: 16),
                  _buildProfileField('Email', emailController, Icons.email, false),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Update Profile',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Schangepassword()),
                      );
                    },
                    child: const Text(
                      'Change Password',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, TextEditingController controller, IconData icon, bool isEditable) {
    return TextFormField(
      controller: controller,
      readOnly: !isEditable,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.deepPurple),
        prefixIcon: Icon(icon, color: Colors.deepPurple[700]),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      style: const TextStyle(color: Colors.black87),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    contactController.dispose();
    super.dispose();
  }
}