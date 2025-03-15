import 'package:flutter/material.dart';
import 'package:seller/manageorders.dart';
import 'package:seller/manageproducts.dart';
import 'package:seller/orderdetails.dart';
import 'package:seller/sprofile.dart';

class SHomepagescreen extends StatefulWidget {
  const SHomepagescreen({super.key});

  @override
  State<SHomepagescreen> createState() => _SHomepageState();
}

class _SHomepageState extends State<SHomepagescreen> {
  int selectedIndex = 0;
  List<String> pageName = [
    'Manage Orders',
    'Order Details',
    'Manage Products',
  ];

  List<IconData> pageIcon = [
    Icons.receipt_long,
    Icons.assignment,
    Icons.storefront,
  ];

  List<Widget> pageContent = [
    Manageorders(),
    Orderdetails(),
     Manageproducts(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seller Dashboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Sprofile()));
            },
            child: Text('Profile', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
          TextButton(
            onPressed: () {},
            child: Text('Complaints', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
          SizedBox(width: 10),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            icon: Icon(Icons.logout, color: Colors.white),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.deepPurple.shade100,
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Text('Navigation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Divider(),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: false,
                      itemCount: pageName.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          child: ListTile(
                            tileColor: selectedIndex == index ? Colors.deepPurple.shade300 : Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                            leading: Icon(pageIcon[index], color: Colors.deepPurple),
                            title: Text(pageName[index], style: TextStyle(fontSize: 16)),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              child: pageContent[selectedIndex],
            ),
          )
        ],
      ),
    );
  }
}
