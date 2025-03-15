import 'package:flutter/material.dart';
import 'package:user/mycarts.dart';
import 'package:user/myprofile.dart';
import 'package:user/searchproduct.dart';

class Homepagescreen extends StatefulWidget {
  const Homepagescreen({super.key});

  @override
  State<Homepagescreen> createState() => _HomepagescreenState();
}

class _HomepagescreenState extends State<Homepagescreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(
          width: 250,
          child: ListView(
            children: [
              GestureDetector(
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTgnbH3Tituy0IHA97phgWalA1nHCiN4Gzvpw&s'),
                  radius: 50,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              // Text("John", textAlign: TextAlign.center, style: TextStyle(
              //   fontSize: 24
              // ),),

              ListTile(
                  leading: Icon(Icons.person),
                  title: Text("My Profile"),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyProfile(),
                        ));
                  }),

              ListTile(
                leading: Icon(Icons.shopping_bag),
                title: Text("My Orders"),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Mycartsscreen(),
                      ));
                },
              ),

              ListTile(
                leading: Icon(Icons.headset_mic_rounded),
                title: Text("Help and Support"),
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text("Settings"),
              ),
               
              ListTile(
                leading: Icon(Icons.logout),
                title: Text("Log Out"),
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: Text("Spare Parts"),
          actions: [
            IconButton(onPressed: () {
               Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Searchproduct(),
                      ));

            }, icon: Icon(Icons.search)),

            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Mycartsscreen(),
                      ));
                },
                icon: Icon(Icons.shopping_cart)),
            // IconButton(onPressed: (){
            //    Navigator.push(context, MaterialPageRoute(builder: (context) => MyProfile()));
            // }, icon: Icon(Icons.person_2)),
          ],
        ),
        body: GridView(
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            children: [
              Card(
                child: Column(
                  children: [Text("Bike Spare Parts")],
                ),
              ),
              Card(
                child: Column(
                  children: [Text("Cars Spare Parts")],
                ),
              ),
              Card(
                child: Column(
                  children: [Text("Bike Accessories")],
                ),
              ),
              Card(
                child: Column(
                  children: [Text("Car Accessories")],
                ),
              ),
            ]));
  }
}
