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

  final List<String> pageName = [
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

  final List<IconData> pageIcon = [
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

  final List<Widget> pageContent = [
    Category(),
    District(),
    Place(),
    Brand(),
    ModelScreen(),
    transmission(),
    year(),
    Engine(),
    TypeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,color: Colors.white,),
        ),
        backgroundColor: Colors.blueGrey[900],
        centerTitle: true,
        elevation: 4,
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.blueGrey[800],
              child: ListView.builder(
                shrinkWrap: false,
                itemCount: pageName.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    leading: Icon(
                      pageIcon[index],
                      color: selectedIndex == index ? Colors.orange : Colors.white,
                    ),
                    title: Text(
                      pageName[index],
                      style: TextStyle(
                        color: selectedIndex == index ? Colors.orange : Colors.white,
                        fontWeight: selectedIndex == index ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    tileColor: selectedIndex == index
                        ? Colors.blueGrey[700]
                        : Colors.transparent,
                    selected: selectedIndex == index,
                    selectedTileColor: Colors.blueGrey[700],
                  );
                },
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage("assets/sper.jpeg"),
                  fit: BoxFit.cover,
                ),
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: pageContent[selectedIndex],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
