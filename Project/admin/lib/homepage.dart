import 'package:admin/car%20details/brand.dart';
import 'package:admin/car%20details/engine.dart';
import 'package:admin/car%20details/model.dart';
import 'package:admin/car%20details/transmission.dart';
import 'package:admin/car%20details/type.dart';
import 'package:admin/car%20details/year.dart';
import 'package:admin/category.dart';
 
import 'package:admin/district.dart';
import 'package:admin/place.dart';
 
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int selectedIndex = 0;

  List<String> pageName = [
     
    'Category',
    'District',
    'Place',
    'Brand',
    'Model',
    'Transmission',
    'Year',
    'Engine',
    'Type',

  ];

  List<IconData> pageIcon = [
     
    Icons.category,
    Icons.location_city,
    Icons.place,
    Icons.branding_watermark,
    Icons.model_training,
    Icons.transit_enterexit_sharp,
    Icons.date_range,
    Icons.engineering,
    Icons.type_specimen,
     
  ];

  List<Widget> pageContent = [
    
    
    Category(),
    District(),
    Place(),
    brand(),
    Model(),
    transmission(),
    year(),
    Engine(),
    TypeScreen(),
     
    
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: const Color.fromARGB(255, 248, 103, 6),
     
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: const Color.fromARGB(255, 126, 143, 156),
              child: ListView.builder(
                shrinkWrap: false,
                itemCount: pageName.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      setState(() {
                        print(index);
                        selectedIndex = index;
                      });
                    },
                    leading: Icon(pageIcon[index]),
                    title: Text(pageName[index]),
                  );
                },
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage("assets/sper.jpeg"),fit: BoxFit.cover
                ),
                
              ),
              child: pageContent[selectedIndex],
              
            ),
          )
        ],
      ),
    );
  }
}