import 'package:flutter/material.dart';
import 'package:user/main.dart';
import 'package:user/mycarts.dart';
import 'package:user/productdetails.dart';
import 'package:user/servies/cart_servies.dart';

class ShowProducts extends StatefulWidget {
  final int type;
  final int category;
  const ShowProducts({super.key, required this.type, required this.category});

  @override
  State<ShowProducts> createState() => _ShowProductsState();
}

class _ShowProductsState extends State<ShowProducts> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;
  final cartService = CartService(supabase);

  @override
  void initState() {
    super.initState();
    fetchProduct();
  }

  Future<void> fetchProduct() async {
    try {
      print('Fetching products for type: ${widget.type}, category: ${widget.category}');
      final response = await supabase
          .from('tbl_product')
          .select()
          .eq('category_id', widget.category)
          .eq('type_id', widget.type);

      List<Map<String, dynamic>> productList = List<Map<String, dynamic>>.from(response);

      // Fetch and assign average ratings for each product
      for (var product in productList) {
        final reviewResponse = await supabase
            .from('tbl_review')
            .select('review_rating')
            .eq('product_id', product['id']);
        final reviews = List<Map<String, dynamic>>.from(reviewResponse);

        double avgRating = 0.0;
        if (reviews.isNotEmpty) {
          final totalRating = reviews.fold<double>(
              0, (sum, review) => sum + (review['review_rating'] as num).toDouble());
          avgRating = totalRating / reviews.length;
        }
        product['review_rating'] = avgRating;
      }

      setState(() {
        products = productList;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching products: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: $e')),
      );
    }
  }

  void addItemToCart(BuildContext context, int itemId) {
    cartService.addToCart(context, itemId).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Added to cart successfully!'),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ),
      );
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to cart: $e')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select Product",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.red[800],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.red[800]))
          : products.isEmpty
              ? _buildEmptyState()
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final data = products[index];
                      return _buildProductCard(data);
                    },
                  ),
                ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> data) {
    return 
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetails(productId: data['id']),
          ),
        );
      },
      child: 
    Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                data['product_photo'] ?? 'https://via.placeholder.com/150',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported,
                      color: Colors.grey, size: 50),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['product_name'] ?? "Unnamed Product",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "₹${(data['product_price'] ?? 0).toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[800],
                  ),
                ),
                const SizedBox(height: 8),
                // Add this block to show the star rating
                Row(
                  children: List.generate(5, (index) {
                    double rating = (data['review_rating'] as num?)?.toDouble() ?? 0.0;
                    if (rating >= index + 1) {
                      return Icon(Icons.star, color: Colors.amber, size: 16);
                    } else if (rating > index && rating < index + 1) {
                      return Icon(Icons.star_half, color: Colors.amber, size: 16);
                    } else {
                      return Icon(Icons.star_border, color: Colors.amber, size: 16);
                    }
                  }),
                ),
                const SizedBox(height: 8),
                
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => addItemToCart(context, data['id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[800],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      "Add to Cart",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "No Products Found",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "No items available in this category",
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: ShowProducts(type: 1, category: 1), // Example values
    debugShowCheckedModeBanner: false,
     ));
}