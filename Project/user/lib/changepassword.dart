import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:animate_do/animate_do.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePasswordscreen extends StatefulWidget {
  const ChangePasswordscreen({super.key});

  @override
  State<ChangePasswordscreen> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePasswordscreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isObscureOld = true;
  bool _isObscureNew = true;
  bool _isObscureConfirm = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final email = supabase.auth.currentUser?.email;

      if (email == null) {
        _showSnackBar('User not authenticated', Colors.red[800]!);
        setState(() => _isLoading = false);
        return;
      }

      // Verify old password by re-authenticating
      try {
        await supabase.auth.signInWithPassword(
          email: email,
          password: _oldPasswordController.text.trim(),
        );
      } catch (e) {
        _showSnackBar('Incorrect old password', Colors.red[800]!);
        setState(() => _isLoading = false);
        return;
      }

      // Update password in Supabase Auth
      await supabase.auth.updateUser(
        UserAttributes(password: _newPasswordController.text.trim()),
      );

      // Update password in tbl_user (make sure to use user_email)
      await supabase.from("tbl_user").update({
        "user_password": _newPasswordController.text.trim(),
      }).eq("user_email", email);

      _showSnackBar('Password updated successfully!', Colors.green[600]!);
      setState(() => _isLoading = false);

      // Navigate back to the profile screen
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Error updating password: $e', Colors.red[800]!);
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text('Change Password'),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: SpinKitFadingCircle(color: Colors.red[800], size: 50))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInUp(
                      duration: const Duration(milliseconds: 400),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              _buildPasswordField(
                                controller: _oldPasswordController,
                                label: 'Old Password',
                                isObscure: _isObscureOld,
                                toggleObscure: () =>
                                    setState(() => _isObscureOld = !_isObscureOld),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Enter your old password';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildPasswordField(
                                controller: _newPasswordController,
                                label: 'New Password',
                                isObscure: _isObscureNew,
                                toggleObscure: () =>
                                    setState(() => _isObscureNew = !_isObscureNew),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Enter your new password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildPasswordField(
                                controller: _confirmPasswordController,
                                label: 'Confirm New Password',
                                isObscure: _isObscureConfirm,
                                toggleObscure: () => setState(
                                    () => _isObscureConfirm = !_isObscureConfirm),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Confirm your new password';
                                  }
                                  if (value != _newPasswordController.text.trim()) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _changePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[800],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Submit',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isObscure,
    required VoidCallback toggleObscure,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.lock_outline, color: Colors.red[800]),
        suffixIcon: IconButton(
          icon: Icon(
            isObscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey[600],
          ),
          onPressed: toggleObscure,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red[800]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: TextInputType.visiblePassword,
    );
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}