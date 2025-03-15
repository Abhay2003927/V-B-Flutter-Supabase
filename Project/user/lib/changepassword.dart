import 'package:flutter/material.dart';
 
class ChangePasswordscreen extends StatefulWidget {
  const ChangePasswordscreen({super.key});

  @override
  State<ChangePasswordscreen> createState() => _ChangePasswordState();
}

bool _isObscure = true;
bool _isObscure2 = true;

class _ChangePasswordState extends State<ChangePasswordscreen> {

  final TextEditingController _password = TextEditingController();
  final TextEditingController _cpassword = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back)),
        title: Text(
          "Change Your Password",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
      body: SizedBox.expand(
        child: Center(
          child: Form(
            child: ListView(
              padding: EdgeInsets.all(25.0),
              children: [
                TextFormField(
                  controller: _password,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter Your Old Password';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    hintText: "Enter Your Old Passsword",
                    label: Text("Old Password"),
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _isObscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                  ),
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: _isObscure,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _cpassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter Your New Password';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    hintText: "Enter Your New Passsword",
                    label: Text("New Password"),
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_isObscure2
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _isObscure2 = !_isObscure2;
                        });
                      },
                    ),
                  ),
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: _isObscure2,
                ),
                SizedBox(
                  height: 10,
                ),
                 TextFormField(
                  controller: _cpassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm Your New Password';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    hintText: "Confirm Your New Passsword",
                    label: Text("Confirm New Password"),
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_isObscure2
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _isObscure2 = !_isObscure2;
                        });
                      },
                    ),
                  ),
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: _isObscure2,
                ),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    
                    
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Text(
                      "Submit",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}