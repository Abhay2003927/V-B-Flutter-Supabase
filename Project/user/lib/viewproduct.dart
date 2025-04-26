import 'package:flutter/material.dart';
import 'package:user/main.dart';

class ViewProduct extends StatefulWidget {
  final Map<String, dynamic> product;
  const ViewProduct({super.key, required this.product});

  @override
  State<ViewProduct> createState() => _ViewProductState();
}

class _ViewProductState extends State<ViewProduct> {
  double rating = 0.0; // Store the average rating
  bool isLoadingRating = true;

  @override
  void initState() {
    super.initState();
    fetchRating();
  }

  Future<void> fetchRating() async {
    try {
      // Fetch reviews for the specific product
      final reviewResponse = await supabase
          .from('tbl_review')
          .select('review_rating')
          .eq('product_id', widget.product['id']); // Match product ID

      final reviews = List<Map<String, dynamic>>.from(reviewResponse);

      // Calculate average rating
      double avgRating = 0.0;
      if (reviews.isNotEmpty) {
        final totalRating = reviews.fold<double>(
            0, (sum, review) => sum + (review['review_rating'] as num).toDouble());
        avgRating = totalRating / reviews.length;
      }

      setState(() {
        rating = avgRating;
        isLoadingRating = false;
      });
    } catch (e) {
      print("Error fetching rating: $e");
      setState(() => isLoadingRating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading rating: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product['name'],
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      widget.product['image'],
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product['name'],
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "₹${widget.product['price'].toStringAsFixed(2)}",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 8),
                        isLoadingRating
                            ? CircularProgressIndicator(color: Colors.blueAccent)
                            : Row(
                                children: List.generate(5, (index) {
                                  if (rating >= index + 1) {
                                    return Icon(Icons.star, color: Colors.amber, size: 20);
                                  } else if (rating > index && rating < index + 1) {
                                    return Icon(Icons.star_half, color: Colors.amber, size: 20);
                                  } else {
                                    return Icon(Icons.star_border, color: Colors.amber, size: 20);
                                  }
                                }),
                              ),
                        SizedBox(height: 16),
                        Text(
                          "This is a high-quality ${widget.product['name']} suitable for your vehicle. Designed for durability and performance.",
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // Add to Cart functionality
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text("Add to Cart",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ),
      ),
    );
  }
}