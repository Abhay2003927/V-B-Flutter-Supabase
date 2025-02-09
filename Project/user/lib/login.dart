import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
       
       body: Form(
        
        
       
        child:Container(
          
          
          
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(image: DecorationImage(image:AssetImage('assets/loginimage.jpg'),fit: BoxFit.cover)),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Welcome to Login page",style: TextStyle(fontSize: 25, color: Colors.red),
                ),
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
                        
                        
                        decoration: InputDecoration(
                          fillColor:Colors.white,
                          filled: true,
                          prefix: Icon(Icons.email),
                  
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
                        
                        decoration: InputDecoration(
                          fillColor:Colors.white,
                          filled: true,
                          prefix: Icon(Icons.password),
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