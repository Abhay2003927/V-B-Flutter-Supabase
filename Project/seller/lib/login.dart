import 'package:flutter/material.dart';
import 'package:seller/homepage.dart';
import 'package:seller/main.dart';
import 'package:seller/registationscreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  TextEditingController semail = TextEditingController();
  TextEditingController spassword = TextEditingController();

  void _signin() async {
    try {
       
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: semail.text,
        password: spassword.text,
      );

      final User? user = res.user;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SHomepagescreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error during sign in.please try again")),
      );
    }
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
          child: Container(
            height: double.infinity,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/loginimage.jpg'), fit: BoxFit.cover)),
        child: Container(
          decoration: BoxDecoration(color: const Color.fromARGB(182, 0, 0, 0)),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 100,
                  ),
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/loginimage.jpg'),
                    radius: 50,
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Text(
                    "Welcome Seller",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 45,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "We Are Always Happy To Serve You !",
                    style: TextStyle(
                        fontSize: 25,
                        color: const Color.fromARGB(255, 229, 227, 226)),
                        textAlign: TextAlign.center,
                        
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  TextFormField(
                    controller: semail,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        suffixIcon: Icon(Icons.alternate_email,color: Colors.white,),
                        focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white54, width: 2)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        hintText: "Enter Your Email",
                        hintStyle: TextStyle(color: Colors.white),
                        border: UnderlineInputBorder()),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  //  Text("PassWord"),
                  
                  TextFormField(
                    controller: spassword,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white54, width: 2)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        suffixIcon: Icon(Icons.lock_open,color: Colors.white,),
                        hintText: "Enter Your Password",
                        hintStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder()),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        _signin();
                      },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Text("Sign In"),
                        )),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account ?",
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Registationscreen(),
                                )); //
                          },
                          child: Text(
                            'Register now',
                            style: TextStyle(color: Colors.white),
                          ))
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      )),
    );
  }
}
