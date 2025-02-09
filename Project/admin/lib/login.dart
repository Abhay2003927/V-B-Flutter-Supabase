 
import 'package:admin/homepage.dart';
import 'package:admin/main.dart';
 
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _email =TextEditingController();
  final TextEditingController _password =TextEditingController();
void _signin()async{
  try {
    String email=_email.text;
    String PassWord=_password.text;
    final AuthResponse res = await supabase.auth.signInWithPassword(
  email: email,
  password: PassWord,
);
  
 final User? user = res.user;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Homepage ()),
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
        child:Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(image: DecorationImage(image:AssetImage('assets/sper.jpeg'),fit: BoxFit.cover)),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                width: 500,
                height: 400,
                decoration: BoxDecoration( 
                  image: DecorationImage(image: AssetImage('assets/sper.jpeg'))
                   ),
                   child:Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //  Text("Email"),
                    
                      TextFormField(
                        controller:_email,
                        decoration: InputDecoration(
                          fillColor:Colors.white,
                          filled: true,
                          hintText: "Enter Your Email",
                          border: OutlineInputBorder(
                
                          )
                        ),
                      ),
                      SizedBox(
                        height: 20,
                        
                      ),
                      //  Text("PassWord"),
                     
                      TextFormField(
                        controller: _password,
                        decoration: InputDecoration(
                          fillColor:Colors.white,
                          filled: true,
                          hintText: "Enter Your Password",
                          border: OutlineInputBorder(
                
                          )
                        ),
                      ),
                      SizedBox(
                        height: 5,
                        
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(onPressed: (){
                            _signin();
          
                            //Navigator.push(context, MaterialPageRoute(builder: (context) => Dashboard(),));//
                          }, 
                          child: Text("Sign In"))
                          
                        ],
                      )
                       
                    ],
                   )
                      ),
              ],
            ),
          ),
        )),
    );
  }
}