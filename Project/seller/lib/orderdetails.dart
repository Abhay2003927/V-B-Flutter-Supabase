import 'package:flutter/material.dart';

class Orderdetails extends StatefulWidget {
  const Orderdetails({super.key});

  @override
  State<Orderdetails> createState() => _OrderdetailsState();
}

class _OrderdetailsState extends State<Orderdetails> {
  
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
 
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Order ID', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Customer Name', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Order Date', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Text('Items:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            
          ],
        ),
      ),
    );
  }
} 

 