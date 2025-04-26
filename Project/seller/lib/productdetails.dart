import 'package:flutter/material.dart';
import 'package:seller/homepage.dart';
import 'package:seller/main.dart';
import 'package:seller/manageproducts.dart';

class Productdetails extends StatefulWidget {
  final int product;

  const Productdetails({super.key, required this.product});

  @override
  State<Productdetails> createState() => _ProductdetailsState();
}

class _ProductdetailsState extends State<Productdetails> {
  String name = "";
  String price = "";
  String details = "";
  String? photoUrl;
  List<Map<String, dynamic>> stock = [];

  @override
  void initState() {
    super.initState();
    fetchProduct();
    fetchStock();
  }

  Future<void> fetchProduct() async {
    try {
      final response = await supabase
          .from("tbl_product")
          .select()
          .eq('id', widget.product)
          .single();
      setState(() {
        name = response['product_name'] ?? 'Unnamed Product';
        price = response['product_price']?.toStringAsFixed(2) ?? '0.00';
        details = response['product_details'] ?? 'No description';
        photoUrl = response['product_photo'];
      });
    } catch (e) {
      _showError('Error fetching product details: $e');
    }
  }

  Future<void> fetchStock() async {
    try {
      final response = await supabase
          .from('tbl_stock')
          .select()
          .eq('product_id', widget.product);
      setState(() {
        stock = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      _showError('Error fetching stock: $e');
    }
  }

  Future<void> deleteProduct() async {
    try {
      await supabase.from("tbl_product").delete().eq('id', widget.product);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product deleted successfully")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SHomepagescreen()),
        );
      }
    } catch (e) {
      _showError('Error deleting product: $e');
    }
  }

  Future<void> updateStock(int quantity) async {
    try {
      await supabase.from('tbl_stock').insert({
        'product_id': widget.product,
        'stock_quantity': quantity,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product restocked successfully")),
        );
        fetchStock(); // Refresh stock
        Navigator.pop(context); // Close dialog
      }
    } catch (e) {
      _showError('Error updating stock: $e');
    }
  }

  void _showRestockDialog() {
    final TextEditingController quantityController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restock Product', style: TextStyle(color: Colors.blueGrey)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter quantity to restock "$name"', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              TextFormField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a quantity';
                  final qty = int.tryParse(value);
                  if (qty == null || qty <= 0) return 'Enter a valid positive number';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.blueGrey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                updateStock(int.parse(quantityController.text));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey[700],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Restock', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey[900],
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.blueGrey[50],
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: screenWidth > 800 ? 600 : screenWidth * 0.9,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Product Details',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      photoUrl ?? 'https://via.placeholder.com/300',
                      width: 300,
                      height: 300,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 300,
                        height: 300,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildDetailRow('Product Name:', name),
                  _buildDetailRow('Price:', '\$$price'),
                  _buildDetailRow('Description:', details, maxLines: 3),
                  _buildDetailRow('Stock:', stock.isNotEmpty ? stock.map((s) => s['stock_quantity']).join(', ') : '0'),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: deleteProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Delete', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: _showRestockDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey[700],
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Add Stock', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}