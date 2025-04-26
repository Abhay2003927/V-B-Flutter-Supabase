import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:user/complaints.dart';
import 'package:user/main.dart';
import 'package:user/rating.dart'; // Ensure this points to the correct file

class OrderDetailsPage extends StatefulWidget {
  final int orderId;
  final int cartId;

  const OrderDetailsPage({
    super.key,
    required this.orderId,
    required this.cartId,

  });

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  Map<String, dynamic>? orderDetails;
  Map<String, dynamic> orderItems = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    try {
      final orderResponse = await supabase
          .from('tbl_booking')
          .select()
          .eq('id', widget.orderId)
          .single();

      final itemsResponse = await supabase
          .from('tbl_cart')
          .select('*, tbl_product(*)')
          .eq('id', widget.cartId)
          .single();

      Map<String, dynamic> items = {
        "id": itemsResponse['id'],
        "product_id": itemsResponse['product_id'],
        "name": itemsResponse['tbl_product']['product_name'],
        "image": itemsResponse['tbl_product']['product_photo'],
        "price": itemsResponse['tbl_product']['product_price'],
        "quantity": itemsResponse['cart_qty'],
        "status": itemsResponse['cart_status'],
      };

      setState(() {
        orderDetails = orderResponse;
        orderItems = items;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching order details: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load order details: $e')),
      );
    }
  }

  String getOrderStatusText(int status) {
    switch (status) {
      case 0:
        return 'Processing';
      case 1:
        return 'Order Placed';
      case 2:
        return 'Order Packed';
      case 3:
        return 'Order Shipped';
      case 4:
        return 'Order Delivered';
      case 5:
        return 'Order Cancelled';
      default:
        return 'Unknown';
    }
  }

  Color getOrderStatusColor(int status) {
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

  Future<void> _generateAndDownloadBill() async {
    final pdf = pw.Document();
    final orderDate = DateTime.parse(orderDetails!['created_at']);
    final formattedDate = DateFormat('MMMM dd, yyyy').format(orderDate);
    final formattedTime = DateFormat('hh:mm a').format(orderDate);
    final int total = (orderItems['quantity'] ?? 1) * (orderItems['price'] ?? 0);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Order Bill",
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text("Order #${widget.orderId}", style: pw.TextStyle(fontSize: 18)),
            pw.Text("Order Date: $formattedDate at $formattedTime"),
            pw.Text("Status: ${getOrderStatusText(orderItems['status'])}"),
            pw.SizedBox(height: 20),
            pw.Text("Order Items",
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(orderItems['name']),
                pw.Text("Qty: ${orderItems['quantity']}"),
                pw.Text("Rs.${orderItems['price']}"),
              ],
            ),
            pw.Divider(),
            pw.SizedBox(height: 20),
            pw.Text("Order Summary",
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Subtotal"),
                pw.Text("Rs.$total"),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Total", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text("Rs.$total",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );

    try {
      final directory = await getExternalStorageDirectory();
      final file = File("${directory!.path}/Order_${widget.orderId}_Bill.pdf");
      await file.writeAsBytes(await pdf.save());
      await OpenFile.open(file.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bill downloaded to ${file.path}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to download bill: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Order Details"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF64B5F6)),
        ),
      );
    }

    if (orderDetails == null || orderItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Order Details"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: const Center(child: Text("Order not found")),
      );
    }

    final orderDate = DateTime.parse(orderDetails!['created_at']);
    final formattedDate = DateFormat('MMMM dd, yyyy').format(orderDate);
    final formattedTime = DateFormat('hh:mm a').format(orderDate);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Order #${widget.orderId}",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderStatusCard(),
            _buildOrderTimeline(orderItems['status']),
            _buildOrderItemCard(),
            _buildOrderInfoCard(formattedDate, formattedTime),
            _buildOrderSummaryCard(),
            _buildActionButtons(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Order Status",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: getOrderStatusColor(orderItems['status']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              getOrderStatusText(orderItems['status']),
              style: TextStyle(
                color: getOrderStatusColor(orderItems['status']),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                orderItems['image'],
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    orderItems['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text("Qty: ${orderItems['quantity']}",
                      style: TextStyle(color: Colors.grey[700])),
                  const SizedBox(height: 4),
                  Text("Rs.${orderItems['price']}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Color(0xFF64B5F6))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfoCard(String formattedDate, String formattedTime) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow("Order Date", "$formattedDate at $formattedTime"),
          const Divider(height: 24),
          _buildInfoRow("Payment Status",
              orderDetails!['booking_status'] == 1 ? "Paid" : "Pending"),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    final int total = (orderItems['quantity'] ?? 1) * (orderItems['price'] ?? 0);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Subtotal", style: TextStyle(color: Colors.grey[700])),
              Text("Rs.$total",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text("Rs.$total",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64B5F6))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    bool canCancel = orderItems['status'] == 0 || orderItems['status'] == 1;
    bool isDelivered = orderItems['status'] == 4;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (canCancel)
            ElevatedButton.icon(
              icon: const Icon(Icons.cancel, color: Colors.white),
              onPressed: () async {
                final TextEditingController reasonController = TextEditingController();
                final result = await showDialog<String>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Cancel Order"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Please provide a reason for cancelling this order:"),
                        const SizedBox(height: 12),
                        TextField(
                          controller: reasonController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            hintText: "Enter reason",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Close"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (reasonController.text.trim().isEmpty) return;
                          Navigator.pop(context, reasonController.text.trim());
                        },
                        child: const Text("Submit"),
                      ),
                    ],
                  ),
                );

                if (result != null && result.isNotEmpty) {
                  try {
                    await supabase
                        .from('tbl_cart')
                        .update({
                          'cart_status': 5, // 5 = Cancelled
                          'cancel_reason': result, // Save reason if you have this field
                        })
                        .eq('id', orderItems['id']);
                    setState(() {
                      orderItems['status'] = 5;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Order cancelled successfully!")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to cancel order: $e")),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              label: const Text("Cancel Order"),
            ),
          if (isDelivered)
            ElevatedButton.icon(
              icon: const Icon(Icons.star_border_outlined, color: Colors.amber),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Rating(product: orderItems['product_id'])));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF64B5F6),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              label: const Text("Rate Us"),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ComplaintsScreen(product: orderItems['product_id']),
                ),
              );
            },
            icon: const Icon(Icons.support_agent),
            label: const Text("Post a Complaint"),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF64B5F6),
              side: const BorderSide(color: Color(0xFF64B5F6)),
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: _generateAndDownloadBill,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            label: const Text("Download Bill"),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[700])),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildOrderTimeline(int status) {
    bool isCancelled = status == 5;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          TimelineTile(
            alignment: TimelineAlign.start,
            isFirst: true,
            indicatorStyle: IndicatorStyle(
              width: 20,
              color: isCancelled ? Colors.grey[300]! : Colors.green,
              iconStyle: IconStyle(
                color: Colors.white,
                iconData: isCancelled ? Icons.cancel : Icons.check,
                fontSize: 12,
              ),
            ),
            endChild: _buildTimelineChild(
              "Order Placed",
              "Your order has been placed successfully",
              !isCancelled,
            ),
          ),
          TimelineTile(
            alignment: TimelineAlign.start,
            indicatorStyle: IndicatorStyle(
              width: 20,
              color: isCancelled ? Colors.grey[300]! : (status >= 1 ? Colors.green : Colors.grey[300]!),
              iconStyle: IconStyle(
                color: Colors.white,
                iconData: isCancelled
                    ? Icons.cancel
                    : (status >= 1 ? Icons.check : Icons.circle),
                fontSize: 12,
              ),
            ),
            endChild: _buildTimelineChild(
              "Processing",
              "Your order is being processed",
              !isCancelled && status >= 1,
            ),
          ),
           TimelineTile(
            alignment: TimelineAlign.start,
            indicatorStyle: IndicatorStyle(
              width: 20,
              color: isCancelled ? Colors.grey[300]! : (status >= 2 ? Colors.green : Colors.grey[300]!),
              iconStyle: IconStyle(
                color: Colors.white,
                iconData: isCancelled
                    ? Icons.cancel
                    : (status >= 2 ? Icons.check : Icons.circle),
                fontSize: 12,
              ),
            ),
            endChild: _buildTimelineChild(
              "Order Packed",
              "Your order has been packed and ready for shipping",
              !isCancelled && status >= 2,
            ),
          ),
          TimelineTile(
            alignment: TimelineAlign.start,
            indicatorStyle: IndicatorStyle(
              width: 20,
              color: isCancelled ? Colors.grey[300]! : (status >= 2 ? Colors.green : Colors.grey[300]!),
              iconStyle: IconStyle(
                color: Colors.white,
                iconData: isCancelled
                    ? Icons.cancel
                    : (status >= 3 ? Icons.check : Icons.circle),
                fontSize: 12,
              ),
            ),
            endChild: _buildTimelineChild(
              "Shipped",
              "Your order has been shipped",
              !isCancelled && status >= 3,
            ),
          ),
          TimelineTile(
            alignment: TimelineAlign.start,
            isLast: !isCancelled,
            indicatorStyle: IndicatorStyle(
              width: 20,
              color: isCancelled ? Colors.grey[300]! : (status >= 3 ? Colors.green : Colors.grey[300]!),
              iconStyle: IconStyle(
                color: Colors.white,
                iconData: isCancelled
                    ? Icons.cancel
                    : (status >= 4 ? Icons.check : Icons.circle),
                fontSize: 12,
              ),
            ),
            endChild: _buildTimelineChild(
              "Delivered",
              "Your order has been delivered",
              !isCancelled && status >= 4,
            ),
          ),
          if (isCancelled)
            TimelineTile(
              alignment: TimelineAlign.start,
              isLast: true,
              indicatorStyle: IndicatorStyle(
                width: 20,
                color: Colors.red,
                iconStyle: IconStyle(
                  color: Colors.white,
                  iconData: Icons.cancel,
                  fontSize: 12,
                ),
              ),
              endChild: _buildTimelineChild(
                "Cancelled",
                "Your order has been cancelled",
                true,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineChild(String title, String subtitle, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.black : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? Colors.grey[700] : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}