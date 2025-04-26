import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderDetailsPage extends StatefulWidget {
  final int bid; // Booking ID
  const OrderDetailsPage({super.key, required this.bid});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  List<Map<String, dynamic>> orderItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('tbl_cart')
          .select('*, tbl_product(*, tbl_seller(seller_name))')
          .eq('booking_id', widget.bid);

      List<Map<String, dynamic>> items = [];
      for (var item in response) {
        int total = item['tbl_product']['product_price'] * item['cart_qty'];
        items.add({
          'id': item['id'],
          'product': item['tbl_product']['product_name'],
          'image': item['tbl_product']['product_photo'],
          'qty': item['cart_qty'],
          'price': item['tbl_product']['product_price'],
          'total': total,
          'status': item['cart_status'],
          'seller': item['tbl_product']['tbl_seller']['seller_name'],
        });
      }

      setState(() {
        orderItems = items;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching order items: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: EdgeInsets.all(10),
        ),
      );
    }
  }

  Future<void> updateStatus(int id, int currentStatus) async {
    try {
      int newStatus = currentStatus + 1; // Progress to next status
      if (newStatus > 4) return; // Prevent updating beyond "Order Delivered"

      await Supabase.instance.client
          .from('tbl_cart')
          .update({'cart_status': newStatus}).eq('id', id);

      await fetchItems(); // Refresh items after update
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Status updated successfully"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: EdgeInsets.all(10),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating status: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: EdgeInsets.all(10),
        ),
      );
    }
  }

  Future<void> cancelOrder(int id) async {
    try {
      await Supabase.instance.client
          .from('tbl_cart')
          .update({'cart_status': 5}).eq('id', id); // 5 = Order Cancelled

      await fetchItems(); // Refresh items after cancellation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Order cancelled successfully"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: EdgeInsets.all(10),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error cancelling order: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: EdgeInsets.all(10),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5FA), // Light grey background
      appBar: AppBar(
        backgroundColor: Color(0xFF1976D2), // Primary color
        foregroundColor: Colors.white,
        title: Text(
          'Order #${widget.bid}',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF1976D2)))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Order Details',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Order Items List
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: orderItems.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 60,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'No items in this order',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.all(16),
                              itemCount: orderItems.length,
                              itemBuilder: (context, index) {
                                final item = orderItems[index];
                                return _buildOrderItemCard(item);
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildOrderItemCard(Map<String, dynamic> item) {
    // Status mapping
    final statusMap = {
      0: {
        'color': Colors.orange,
        'text': 'Processing',
        'button': 'Mark as Order Placed',
      },
      1: {
        'color': Colors.blue,
        'text': 'Order Placed',
        'button': 'Mark as Order Packed',
      },
      2: {
        'color': Colors.yellow[700],
        'text': 'Order Packed',
        'button': 'Mark as Order Shipped',
      },
      3: {
        'color': Colors.purple,
        'text': 'Order Shipped',
        'button': 'Mark as Order Delivered',
      },
      4: {
        'color': Colors.green,
        'text': 'Order Delivered',
        'button': null,
      },
      5: {
        'color': Colors.red,
        'text': 'Order Cancelled',
        'button': null,
      },
    };

    final statusInfo = statusMap[item['status']] ?? {
      'color': Colors.grey,
      'text': 'Unknown',
      'button': null,
    };

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image and Details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Photo
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item['image'] ?? '',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),

                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        item['product'] ?? 'Unknown Product',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),

                      // Seller Name
                      Text(
                        'Seller: ${item['seller'] ?? 'Unknown'}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),

                      // Quantity and Price
                      Row(
                        children: [
                          Text(
                            'Qty: ${item['qty']}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(width: 16),
                          Text(
                            'Price: \$${item['price'].toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),

                      // Total Price
                      Text(
                        'Total: \$${item['total'].toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Status and Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (statusInfo['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusInfo['text'].toString(),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      // color: statusInfo['color'],
                    ),
                  ),
                ),

                // Action Buttons
                Row(
                  children: [
                    if (statusInfo['button'] != null)
                      ElevatedButton(
                        onPressed: () {
                          updateStatus(item['id'], item['status']);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: Text(
                          statusInfo['button'].toString(),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (item['status'] < 4) // Allow cancellation before delivery
                      SizedBox(width: 8),
                    if (item['status'] < 4)
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                'Cancel Order',
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                              ),
                              content: Text(
                                'Are you sure you want to cancel this order?',
                                style: GoogleFonts.inter(),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('No', style: GoogleFonts.inter()),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    cancelOrder(item['id']);
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text('Yes', style: GoogleFonts.inter()),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}