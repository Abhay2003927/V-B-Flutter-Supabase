import 'package:flutter/material.dart';
import 'package:seller/addproduct.dart';
import 'package:seller/manageorders.dart';
import 'package:seller/productdetails.dart';
 
class Manageproducts extends StatefulWidget {
  const Manageproducts({super.key});

  @override
  State<Manageproducts> createState() => _ProductsState();
}

class _ProductsState extends State<Manageproducts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       
      body: Padding(
        padding: const EdgeInsets.all(12.0), // Add padding around the entire body
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add Product Button
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Manage Your products",
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AddProduct()));
                      },
                      child: Text("Add Product",style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[800], // Button color
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Product GridView
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 items per row
                  crossAxisSpacing: 12, // Space between columns
                  mainAxisSpacing: 12, // Space between rows
                  childAspectRatio: 1, // Adjust the aspect ratio for better look
                ),
                shrinkWrap: true, // To make GridView scrollable inside Column
                itemCount: 6, // For now we use 6 as placeholder items
                itemBuilder: (context, index) {
                  return ProductCard();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Productdetails()));
      },
      child: Card(
        elevation: 5, // Adding shadow for card depth
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Rounded corners for cards
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: Image.asset(
                "assets/sper.jpeg", // Sample image for the product
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Product Name",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text("Price: \$100", style: TextStyle(fontSize: 14)),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text("Add Stock",style: TextStyle(color: Colors.white)),
                    
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}