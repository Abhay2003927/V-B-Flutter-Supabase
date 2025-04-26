import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:animate_do/animate_do.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:seller/main.dart';
import 'package:seller/orderdetails.dart'; // Import the order details page

class SellerViewOrders extends StatefulWidget {
  const SellerViewOrders({super.key});

  @override
  State<SellerViewOrders> createState() => _SellerViewOrdersState();
}

class _SellerViewOrdersState extends State<SellerViewOrders> {
  bool _isLoading = true;
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  // Fetch orders related to the seller
  Future<void> _fetchOrders() async {
    try {
      // Fetch bookings with status 0 (Processing), 1 (Order Placed), 2 (Order Packed), 3 (Order Shipped), or 4 (Order Delivered)
      final bookingResponse = await supabase
          .from('tbl_booking')
          .select('*, tbl_user(user_name, user_email)')
          .inFilter('booking_status', [0, 1, 2, 3, 4])
          .order('created_at', ascending: false);

      List<Map<String, dynamic>> bookingList =
          List<Map<String, dynamic>>.from(bookingResponse);

      // Fetch cart data for each booking
      List<Map<String, dynamic>> allCartData = [];
      for (var booking in bookingList) {
        final bookingId = booking['id'];
        final cartResponse = await supabase
            .from('tbl_cart')
            .select('*, tbl_product(product_name, product_price)')
            .eq('booking_id', bookingId);



        List<Map<String, dynamic>> cartItems =
            List<Map<String, dynamic>>.from(cartResponse);
        for (var cartItem in cartItems) {
          cartItem['booking'] = booking; // Attach booking data with user info

        }
        allCartData.addAll(cartItems);
      }

      setState(() {
        orders = allCartData;
        _isLoading = false;
      });
    } catch (e) {
      _showSnackBar('Error fetching orders: $e', Colors.red);
      setState(() => _isLoading = false);
    }
  }

  // Show SnackBar for feedback
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Get status color
  Color _getStatusColor(int? status) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.purple;
      case 4:
        return Colors.green;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Get status text
  String _getStatusText(int status) {
    print(status);
    switch (status) {
      case 0:
        return status == 0 ? 'Processing' : 'Unknown';
      case 1:
        return status == 1 ? 'Order Placed' : 'Unknown';
      case 2:
        return status == 2 ? 'Order Packed' : 'Unknown';
      case 3:
        return status == 3 ? 'Order Shipped' : 'Unknown';
      case 4:
        return status == 4 ? 'Order Delivered' : 'Unknown';
      case 5:
        return status == 5 ? 'Order Cancelled' : 'Unknown';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Customer Orders',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Container(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: SpinKitFadingCircle(color: Colors.blue[900], size: 50),
      );
    }

    if (orders.isEmpty) {
      return Center(
        child: FadeInUp(
          duration: const Duration(milliseconds: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_outlined,
                  size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No Orders Found',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Orders from customers will appear here',
                style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchOrders,
      child: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return FadeInUp(
            duration: const Duration(milliseconds: 400),
            child: _buildOrderCard(orders[index]),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final booking = order['booking'];
    final product = order['tbl_product'];
    final user = booking['tbl_user'];
    final bookingId = booking['id'];
    final status = order['cart_status'] ?? 0;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${bookingId ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                Chip(
                  label: Text(
                    _getStatusText(status),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: _getStatusColor(status).withOpacity(0.1),
                  side: BorderSide(color: _getStatusColor(status)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Customer Info
            Row(
              children: [
                Icon(Icons.person, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Customer: ${user?['user_name'] ?? 'Unknown'}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.email, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    user?['user_email'] ?? 'No email',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Product Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product?['product_name'] ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Price: \$${product?['product_price']?.toStringAsFixed(2) ?? '0.00'}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quantity: ${order['cart_qty'] ?? '1'}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Order Date and Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: ${booking['created_at']?.toString().split(' ')[0] ?? 'Unknown'}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                Text(
                  'Total: \$${((order['cart_qty'] ?? 1) * (product?['product_price'] ?? 0)).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // View Details Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailsPage(bid: bookingId),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}