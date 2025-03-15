import 'package:flutter/material.dart';
import 'package:user/login.dart';
import 'package:user/registation.dart';

class Skipscreen extends StatefulWidget {
  const Skipscreen({super.key});

  @override
  State<Skipscreen> createState() => _SkipscreenState();
}

class _SkipscreenState extends State<Skipscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          // BoxDecoration(color: const Color.fromARGB(109, 154, 96, 96)),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/skipscreen.jpeg'),
                  fit: BoxFit.cover)),

          child: Container(
            decoration:
                BoxDecoration(color: const Color.fromARGB(182, 0, 0, 0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome to  Auto Spare Parts online Market",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 45,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  "  An online market for auto spare parts is a digital platform  where  customers can easily  the automotive parts  and accessories.allowing car owners, repair shops,and mechanics   to find specific parts for vehicles without visiting  physical stores.check product specifications",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold ,fontSize:15),
                      textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                         style: ElevatedButton.styleFrom(backgroundColor:const Color.fromARGB(255, 139, 137, 143) ),
                        
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ));
                          },
                          child: Text("Login Page",style: TextStyle(color:Colors.black),),
                        ),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Expanded(
                        child: ElevatedButton(
                           style: ElevatedButton.styleFrom(backgroundColor:const Color.fromARGB(255, 139, 137, 143) ),
                        
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Registation(),
                                ));
                          },
                          child: Text("Signup Page",style: TextStyle(color:Colors.black),),
                          
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
