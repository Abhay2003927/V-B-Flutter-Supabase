import 'package:flutter/material.dart';
import 'package:seller/homepage.dart';
import 'package:seller/main.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

class Registationscreen extends StatefulWidget {
  const Registationscreen({super.key});

  @override
  State<Registationscreen> createState() => _RegistationscreenState();
}

class _RegistationscreenState extends State<Registationscreen> {
  TextEditingController snameController = TextEditingController();
  TextEditingController semailController = TextEditingController();
  TextEditingController scontactController = TextEditingController();
  TextEditingController saddressController = TextEditingController();
  TextEditingController spasswordController = TextEditingController();
  TextEditingController sconfirmPasswordController = TextEditingController();
  TextEditingController sphotoController = TextEditingController();
  TextEditingController sproofController = TextEditingController();
  final formkey = GlobalKey<FormState>();
  PlatformFile? pickedImage;
  PlatformFile? pickedProof;

  // Handle File Upload Process
  Future<void> handleImagePick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false, // Only single file upload
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
      allowMultiple: false, // Only single file upload
    );
    if (result != null) {
      setState(() {
        pickedProof = result.files.first;
        sproofController.text = result.files.first.name;
      });
    }
  }

  Future<String?> photoUpload(String uid, String type) async {
    try {
      final bucketName = 'shop'; // Replace with your bucket name
      final filePath = "$uid-$type-${pickedImage!.name}";
      await supabase.storage.from(bucketName).uploadBinary(
            filePath,
            pickedImage!.bytes!, // Use file.bytes for Flutter Web
          );
      final publicUrl =
          supabase.storage.from(bucketName).getPublicUrl(filePath);
      // await updateImage(uid, publicUrl);
      return publicUrl;
    } catch (e) {
      print("Error photo upload: $e");
      return null;
    }
  }

  List<Map<String, dynamic>> placeList = [];
  List<Map<String, dynamic>> distList = [];
  @override
  void initState() {
    super.initState();
    fetchplace();
    fetchtdistrict();
  }

  Future<void> fetchplace() async {
    try {
      final response = await supabase.from('tbl_place').select();
      print("Place: $response");
      setState(() {
        placeList = response;
      });
    } catch (e) {
      // print("Error fetching place: $e");
    }
  }

  Future<void> fetchtdistrict() async {
    try {
      final response = await supabase.from('tbl_district').select();
      print("District: $response");
      setState(() {
        distList = response;
      });
    } catch (e) {
      // print("Error fetching district: $e");
    }
  }

  Future<void> insert(String uid) async {
    try {
      String? photoUrl = await photoUpload(uid, 'photo');
      String? proofUrl = await photoUpload(uid, 'proof');
      await supabase.from('tbl_seller').insert({
        'id': uid,
        'seller_name': snameController.text,
        'seller_email': semailController.text,
        'seller_contact': scontactController.text,
        'seller_address': saddressController.text,
        'seller_password': spasswordController.text,
        'place_id': selectedplace,
        'seller_photo': photoUrl,
        'seller_proof': proofUrl,
      });

      print("Inserted ");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Inserted successfully")));
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SHomepagescreen(),
          ));
    } catch (e) {
      print("Error $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error founder $e')));
    }
  }

  Future<void> reg() async {
    try {
      final Authentication = await supabase.auth.signUp(
          password: spasswordController.text, email: semailController.text);
      String uid = Authentication.user!.id;
      insert(uid);
    } catch (e) {
      print("Error $e");
    }
  }

  String? selectedplace;
  String? selecteddist;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/loginimage.jpg'), fit: BoxFit.cover)),
        child: Container(
          decoration: BoxDecoration(color: const Color.fromARGB(182, 0, 0, 0)),
          child: SingleChildScrollView(
            child: Form(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 500),
                child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    Text(
                      "Join Us Our Seller Community",
                      style: TextStyle(fontSize: 25, color: Colors.red),
                    ),
            
                    TextFormField(
                      controller: snameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          suffixIcon: Icon(Icons.alternate_email,color: Colors.white,),
                          focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white54, width: 2)),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          labelText: " Full Name",
                          labelStyle: TextStyle(color: Colors.white),
                          border: UnderlineInputBorder()),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    //  Text("PassWord"),
            
                    TextFormField(
                      controller: scontactController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          suffixIcon: Icon(Icons.numbers,color: Colors.white,),
                          focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white54, width: 2)),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          labelText: " Mobile Number",
                          labelStyle: TextStyle(color: Colors.white),
                          border: UnderlineInputBorder()),
                    ),
                    SizedBox(
                      height: 15,
                    ),
            
                    TextFormField(
                      controller: semailController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          suffixIcon: Icon(Icons.attach_email,color: Colors.white,),
                          focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white54, width: 2)),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.white),
                          border: UnderlineInputBorder()),
                    ),
                    SizedBox(
                      height: 15,
                    ),
            
                    DropdownButtonFormField(
                       dropdownColor: Colors.black,
                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white54, width: 2)),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          labelText: 'District',
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        value: selecteddist,
                        items: distList.map((district) {
                          return DropdownMenuItem(
                              value: district['id'].toString(),
                              child: Text(district['district_name'] ?? "", style: TextStyle(color: Colors.white),));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selecteddist = value!;
                          });
                        }),
            
                    SizedBox(
                      height: 15,
                    ),
            
                    DropdownButtonFormField(
                       dropdownColor: Colors.black,
                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white54, width: 2)),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          labelText: 'Place',
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        value: selectedplace,
                        items: placeList.map((place) {
                          return DropdownMenuItem(
                              value: place['id'].toString(),
                              child: Text(place['place_name'], style: TextStyle(color: Colors.white),));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedplace = value!;
                          });
                        }),
                    SizedBox(
                      height: 15,
                    ),
            
                    TextFormField(
                      controller: saddressController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          suffixIcon: Icon(Icons.location_city,color: Colors.white,),
                          focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white54, width: 2)),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          labelText: " Address",
                          labelStyle: TextStyle(color: Colors.white),
                          border: UnderlineInputBorder()),
                    ),
                    SizedBox(
                      height: 15,
                    ),
            
            
                     TextFormField(
                      readOnly: true,
                      onTap: handleImagePick,
                      controller: sphotoController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          suffixIcon: Icon(Icons.photo,color: Colors.white,),
                          focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white54, width: 2)),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          labelText: 'Photo',
                          labelStyle: TextStyle(color: Colors.white),
                          border: UnderlineInputBorder()),
                    ),
            
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      readOnly: true,
                      onTap: handleProofPick,
                      controller: sproofController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          suffixIcon: Icon(Icons.open_in_browser,color: Colors.white,),
                          focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white54, width: 2)),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          labelText: 'Proof',
                          labelStyle: TextStyle(color: Colors.white),
                          border: UnderlineInputBorder()),
                    ),
            
            
                    SizedBox(
                      height: 15,
                    ),
            
                    TextFormField(
                      controller: spasswordController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          suffixIcon: Icon(Icons.security,color: Colors.white,),
                          focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white54, width: 2)),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          labelText: "Enter Your Password",
                          labelStyle: TextStyle(color: Colors.white),
                          border: UnderlineInputBorder()),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: sconfirmPasswordController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          suffixIcon: Icon(Icons.security,color: Colors.white,),
                          focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white54, width: 2)),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          labelText: "Enter Your  confirmPassword",
                          labelStyle: TextStyle(color: Colors.white),
                          border: UnderlineInputBorder()),
                    ),
                    SizedBox(
                      height: 15,
                    ),
            
                     Center(
                    child: ElevatedButton(
                        onPressed: () {
                          reg();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Text("Sign up"),
                        )),
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
}
