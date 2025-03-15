import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user/homepage.dart';
import 'package:user/login.dart';
import 'package:user/main.dart';

class Registation extends StatefulWidget {
  const Registation({super.key});

  @override
  State<Registation> createState() => _RegistationState();
}

class _RegistationState extends State<Registation> {
   TextEditingController nameController=TextEditingController();
  TextEditingController emailController=TextEditingController();
  TextEditingController contactController=TextEditingController();
  TextEditingController addressController=TextEditingController();
  TextEditingController passwordController=TextEditingController();
  TextEditingController confirmPasswordController=TextEditingController();

  final formkey = GlobalKey<FormState>();

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

      await supabase.from('tbl_user').insert({
        'id': uid,
        'user_name': nameController.text,
        'user_email': emailController.text,
        'user_contact':contactController.text,
        'user_address':addressController.text,
        'user_password':passwordController.text,
        
        'place_id':selectedplace,
      });
     

      print("Inserted ");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Inserted successfully")));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Homepagescreen(),));
    } catch (e) {

      print("Error $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error founder $e')));
      
    }
  }

  Future<void> reg() async {
    try {
      
      final Authentication = await supabase.auth.signUp(password: passwordController.text,email: emailController.text);
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
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/loginimage.jpg'), fit: BoxFit.cover)),
        child: Container(
          decoration: BoxDecoration(color: const Color.fromARGB(182, 0, 0, 0)),
          child: Form(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Join with Us",
                    style: TextStyle(fontSize: 25, color: Colors.red),
                  ),

                  TextFormField(
                    controller: nameController,
                    style:TextStyle(color: Colors.white) ,
                    decoration: InputDecoration(
                        suffixIcon: Icon(Icons.alternate_email),
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
                    controller: contactController,
                    style:TextStyle(color: Colors.white) ,
                    decoration: InputDecoration(
                        suffixIcon: Icon(Icons.numbers),
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
                    controller: emailController,
                    style:TextStyle(color: Colors.white) ,
                    decoration: InputDecoration(
                        suffixIcon: Icon(Icons.attach_email),
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
                    style:TextStyle(color: Colors.white) ,
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
                            child: Text(district['district_name'] ?? ""));
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
                    style:TextStyle(color: Colors.white) ,
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
                            child: Text(place['place_name'] ?? ""));
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
                    controller:addressController ,
                    style:TextStyle(color: Colors.white) ,
                    decoration: InputDecoration(
                        suffixIcon: Icon(Icons.location_city),
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
                    controller: passwordController,
                    style:TextStyle(color: Colors.white) ,
                    decoration: InputDecoration(
                        suffixIcon: Icon(Icons.security),
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
                    controller:confirmPasswordController  ,
                    style:TextStyle(color: Colors.white) ,
                    decoration: InputDecoration(
                        suffixIcon: Icon(Icons.security),
                        focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white54, width: 2)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        labelText: "Enter Your  confirmPassword",
                        labelStyle: TextStyle(color: Colors.white),
                        border: UnderlineInputBorder()),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                           reg();
                          },
                          child: Text("Join"))
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
