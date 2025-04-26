import 'package:flutter/material.dart';
import 'package:seller/homepage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:seller/login.dart';
import 'package:seller/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Registationscreen extends StatefulWidget {
  const Registationscreen({super.key});

  @override
  State<Registationscreen> createState() => _RegistationscreenState();
}

class _RegistationscreenState extends State<Registationscreen> {
  final TextEditingController snameController = TextEditingController();
  final TextEditingController semailController = TextEditingController();
  final TextEditingController scontactController = TextEditingController();
  final TextEditingController saddressController = TextEditingController();
  final TextEditingController spasswordController = TextEditingController();
  final TextEditingController sconfirmPasswordController = TextEditingController();
  final TextEditingController sphotoController = TextEditingController();
  final TextEditingController sproofController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  PlatformFile? pickedImage;
  PlatformFile? pickedProof;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? selectedPlace;
  String? selectedDist;
  List<Map<String, dynamic>> placeList = [];
  List<Map<String, dynamic>> distList = [];

  @override
  void initState() {
    super.initState();
    fetchDistrict();
  }

  Future<void> fetchDistrict() async {
    try {
      final response = await supabase.from('tbl_district').select();
      setState(() => distList = response);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching districts: $e')),
      );
    }
  }

  Future<void> fetchPlace(String id) async {
    try {
      final response = await supabase.from('tbl_place').select().eq('district_id', id);
      setState(() => placeList = response);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching places: $e')),
      );
    }
  }

  Future<void> handleImagePick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image,
    );
    if (result != null) {
      setState(() {
        pickedImage = result.files.first;
        sphotoController.text = result.files.first.name;
      });
    }
  }

  Future<void> handleProofPick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );
    if (result != null) {
      setState(() {
        pickedProof = result.files.first;
        sproofController.text = result.files.first.name;
      });
    }
  }

  Future<String?> photoUpload(String uid, String type, PlatformFile? file) async {
    if (file == null) return null;
    try {
      final bucketName = 'shop';
      final filePath = "$uid-$type-${file.name}";
      await supabase.storage.from(bucketName).uploadBinary(filePath, file.bytes!);
      return supabase.storage.from(bucketName).getPublicUrl(filePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload error: $e')),
      );
      return null;
    }
  }

  Future<void> insert(String uid) async {
    try {
      final photoUrl = await photoUpload(uid, 'photo', pickedImage);
      final proofUrl = await photoUpload(uid, 'proof', pickedProof);
      await supabase.from('tbl_seller').insert({
        'id': uid,
        'seller_name': snameController.text,
        'seller_email': semailController.text,
        'seller_contact': scontactController.text,
        'seller_address': saddressController.text,
        'seller_password': spasswordController.text,
        'place_id': selectedPlace,
        'seller_photo': photoUrl,
        'seller_proof': proofUrl,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration successful")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Loginscreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration error: $e')),
        );
      }
    }
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;
    if (spasswordController.text != sconfirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final authResponse = await supabase.auth.signUp(
        password: spasswordController.text,
        email: semailController.text,
      );
      if (authResponse.user != null) {
        await insert(authResponse.user!.id);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-up error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/loginimage.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: screenWidth > 800 ? 600 : screenWidth * 0.9,
              padding: const EdgeInsets.all(32),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Join Our Seller Community",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: snameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("Full Name", Icons.person),
                      validator: (value) => value!.isEmpty ? "Name is required" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: scontactController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration("Mobile Number", Icons.phone),
                      validator: (value) => value!.length < 10 ? "Enter a valid phone number" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: semailController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration("Email", Icons.email),
                      validator: (value) => !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value ?? "")
                          ? "Enter a valid email"
                          : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      dropdownColor: Colors.grey[800],
                      decoration: _inputDecoration("District", Icons.location_on),
                      value: selectedDist,
                      items: distList.map((district) => DropdownMenuItem(
                        value: district['id'].toString(),
                        child: Text(district['district_name'] ?? "", style: const TextStyle(color: Colors.white)),
                      )).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDist = value;
                          selectedPlace = null;
                          placeList = [];
                        });
                        if (value != null) fetchPlace(value);
                      },
                      validator: (value) => value == null ? "Select a district" : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      dropdownColor: Colors.grey[800],
                      decoration: _inputDecoration("Place", Icons.place),
                      value: selectedPlace,
                      items: placeList.map((place) => DropdownMenuItem(
                        value: place['id'].toString(),
                        child: Text(place['place_name'] ?? "", style: const TextStyle(color: Colors.white)),
                      )).toList(),
                      onChanged: (value) => setState(() => selectedPlace = value),
                      validator: (value) => value == null ? "Select a place" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: saddressController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("Address", Icons.home),
                      validator: (value) => value!.isEmpty ? "Address is required" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      readOnly: true,
                      onTap: handleImagePick,
                      controller: sphotoController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("Photo", Icons.photo),
                      validator: (value) => value!.isEmpty ? "Photo is required" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      readOnly: true,
                      onTap: handleProofPick,
                      controller: sproofController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("Proof", Icons.verified),
                      validator: (value) => value!.isEmpty ? "Proof is required" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: spasswordController,
                      style: const TextStyle(color: Colors.white),
                      obscureText: _obscurePassword,
                      decoration: _inputDecoration("Password", Icons.lock).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (value) => value!.length < 6 ? "Password must be at least 6 characters" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: sconfirmPasswordController,
                      style: const TextStyle(color: Colors.white),
                      obscureText: _obscureConfirmPassword,
                      decoration: _inputDecoration("Confirm Password", Icons.lock).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
                          // tonew
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? "Confirm your password" : null,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Sign Up", style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      prefixIcon: Icon(icon, color: Colors.white70),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
      ),
    );
  }

  @override
  void dispose() {
    snameController.dispose();
    semailController.dispose();
    scontactController.dispose();
    saddressController.dispose();
    spasswordController.dispose();
    sconfirmPasswordController.dispose();
    sphotoController.dispose();
    sproofController.dispose();
    super.dispose();
  }
}