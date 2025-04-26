import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:animate_do/animate_do.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user/main.dart';
import 'package:user/orderdetails.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<Map<String, dynamic>> cartProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCartProducts();
  }

  // Fetch Cart Products from Supabase
  Future<void> fetchCartProducts() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() {
          cartProducts = [];
          isLoading = false;
        });
        return;
      }

      // Fetch all bookings for the user (remove .limit(1) and .maybeSingle())
      final bookingsResponse = await supabase
          .from('tbl_booking')
          .select('id')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      if (bookingsResponse == null || bookingsResponse.isEmpty) {
        setState(() {
          cartProducts = [];
          isLoading = false;
        });
        return;
      }

      List<Map<String, dynamic>> products = [];
      for (var booking in bookingsResponse) {
        final bookingId = booking['id'];

        // Fetch cart items for each booking
        final cartResponse = await supabase
            .from('tbl_cart')
            .select('*')
            .eq('booking_id', bookingId);

        for (var cartItem in cartResponse) {
          final productResponse = await supabase
              .from('tbl_product')
              .select('product_name, product_photo, product_price')
              .eq('id', cartItem['product_id'])
              .single();

          if (productResponse.isNotEmpty) {
            products.add({
              "id": cartItem['id'],
              "order_id": cartItem['booking_id'],
              "product_id": cartItem['product_id'],
              "name": productResponse['product_name'],
              "image": productResponse['product_photo'],
              "price": productResponse['product_price'],
              "quantity": cartItem['cart_qty'],
            });
          }
        }
      }

      setState(() {
        cartProducts = products;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching cart products: $e");
      setState(() {
        cartProducts = [];
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading orders: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red[800],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "My Orders",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: SpinKitFadingCircle(
                color: Colors.red[800],
                size: 50,
              ),
            )
          : cartProducts.isEmpty
              ? _buildEmptyCart()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: cartProducts.length,
                  itemBuilder: (context, index) {
                    var product = cartProducts[index];
                    return FadeInUp(
                      duration: Duration(milliseconds: 300 + index * 100),
                      child: _buildOrderCard(product),
                    );
                  },
                ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsPage(
              orderId: product['order_id'],
              cartId: product['id'],
            ),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadowColor: Colors.grey.withOpacity(0.2),
        margin: const EdgeInsets.only(bottom: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Full-bleed image
              Image.network(
                product['image'] ?? 'https://via.placeholder.com/150',
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: double.infinity,
                    height: 180,
                    color: Colors.grey[200],
                    child: Center(
                      child: SpinKitFadingCircle(
                        color: Colors.red[800],
                        size: 30,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 180,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 50,
                      ),
                    ),
                  );
                },
              ),
              // Semi-transparent overlay for text
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.3),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'] ?? "Unnamed Product",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₹${(product['price'] ?? 0).toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[100],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Quantity: ${product['quantity']}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Empty Cart Widget
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.red[800]!.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            "Your Orders are Empty",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red[800],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Looks like you haven't placed any orders yet",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[800],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Continue Shopping",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}