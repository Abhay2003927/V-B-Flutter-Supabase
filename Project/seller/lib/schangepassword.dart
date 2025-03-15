import 'package:flutter/material.dart';

class Schangepassword extends StatefulWidget {
  const Schangepassword({super.key});

  @override
  State<Schangepassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<Schangepassword> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(
          "Change Password",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 500, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildPasswordField("Old Password", _oldPasswordController, _isOldPasswordVisible, () {
                setState(() {
                  _isOldPasswordVisible = !_isOldPasswordVisible;
                });
              }),
              SizedBox(height: 15),
              buildPasswordField("New Password", _newPasswordController, _isNewPasswordVisible, () {
                setState(() {
                  _isNewPasswordVisible = !_isNewPasswordVisible;
                });
              }),
              SizedBox(height: 15),
              buildPasswordField("Confirm Password", _confirmPasswordController, _isConfirmPasswordVisible, () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              }),
              SizedBox(height: 25),
              ElevatedButton(
                onPressed: _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: Text("Update Password"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPasswordField(String label, TextEditingController controller, bool isVisible, VoidCallback toggleVisibility) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: toggleVisibility,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  void _changePassword() {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("New passwords do not match"), backgroundColor: Colors.red),
      );
      return;
    }
    // Call API to update password (Implement logic here)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Password updated successfully"), backgroundColor: Colors.green),
    );
  }
}
