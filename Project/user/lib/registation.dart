import 'package:flutter/material.dart';

class Registation extends StatefulWidget {
  const Registation({super.key});

  @override
  State<Registation> createState() => _RegistationState();
}

class _RegistationState extends State<Registation> {
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
                  "Welcome to Registation Page",style: TextStyle(fontSize: 25, color: Colors.red),
                ),
                Container(
                width: 500,
                height: 500,
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
                          prefix: Icon(Icons.person),
                  
                          hintText: "Enter Your Name",
                          border: OutlineInputBorder(
                
                          )
                        ),
                      ),
                      SizedBox(
                        height: 5,
                        
                      ),
                      //  Text("PassWord"),
                     
                      TextFormField(
                        
                        decoration: InputDecoration(
                          fillColor:Colors.white,
                          filled: true,
                          prefix: Icon(Icons.mobile_friendly),
                          hintText: "Enter Your Mobile Number",
                          border: OutlineInputBorder(
                
                          )
                        ),
                      ),
                      SizedBox(
                        height: 5,
      
                      ),
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
                        height: 5,
                        
                      ),
                      TextFormField(
                        
                        decoration: InputDecoration(
                          fillColor:Colors.white,
                          filled: true,
                          prefix: Icon(Icons.location_city),
                          hintText: "Enter Your Address",
                          border: OutlineInputBorder(
                
                          )
                        ),
                      ),
                       SizedBox(
                        height: 5,
                        
                      ),
                       
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

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(onPressed: (){ 
                            
          
                            //Navigator.push(context, MaterialPageRoute(builder: (context) => Dashboard(),));//
                          }, 
                          child: Text("Join"))
                          
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