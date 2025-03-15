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
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController contactController = TextEditingController();

  Future<void> updateProfile() async {
    try {
      await supabase.from('tbl_seller').update({
        'seller_name': nameController.text,
        'seller_email': emailController.text,
        'seller_contact': contactController.text,
      }).eq('id', supabase.auth.currentUser!.id);
    } catch (e) {
      print("Error updating user: $e");
    }
  }

  Future<void> fetchUser() async {
    try {
      String uid = supabase.auth.currentUser!.id;
      final response = await supabase.from("tbl_seller").select().eq('id', uid).single();
      setState(() {
        nameController.text = response['seller_name'];
        emailController.text = response['seller_email'];
        contactController.text = response['seller_contact'];
      });
    } catch (e) {
      print("User not found: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Profile"),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.symmetric(  horizontal: 500, vertical: 50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.deepPurple[100],
                  child: Text(
                    nameController.text.isNotEmpty ? nameController.text[0] : "A",
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                ),
                const SizedBox(height: 20),
                buildProfileField("Name", nameController, Icons.person, true),
                buildProfileField("Mobile", contactController, Icons.phone, true),
                buildProfileField("Email", emailController, Icons.email, false),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Update Profile", style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const Schangepassword()));
                  },
                  child: const Text("Change Password", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProfileField(String label, TextEditingController controller, IconData icon, bool isEditable) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        readOnly: !isEditable,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.deepPurple),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }
}
