import 'package:flutter/material.dart';
import 'package:seller/addproduct.dart';
import 'package:seller/main.dart';
import 'package:seller/productdetails.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Manageproducts extends StatefulWidget {
  const Manageproducts({super.key});

  @override
  State<Manageproducts> createState() => _ProductsState();
}

class _ProductsState extends State<Manageproducts> {
  List<Map<String, dynamic>> _products = [];
  Map<int, int> _stockData = {};
  String _selectedType = 'All'; // Track selected filter: All, Cars, Bikes

  @override
  void initState() {
    super.initState();
    fetchProduct();
  }

  Future<void> fetchProduct() async {
    try {
      final uid = supabase.auth.currentUser?.id;
      if (uid == null) throw Exception('No authenticated user');
      final response = await supabase
          .from("tbl_product")
          .select("id, product_name, product_price, product_photo,tbl_type(type_name)")
          .eq('seller_id', uid);
      setState(() {
        _products = List<Map<String, dynamic>>.from(response);
      });
      await fetchStock();
    } catch (e) {
      _showError('Error fetching products: $e');
    }
  }

  Future<void> fetchStock() async {
    try {
      for (var product in _products) {
        final stockResponse = await supabase
            .from("tbl_stock")
            .select("stock_quantity")
            .eq("product_id", product['id'])
            .maybeSingle();
        final stockQty = stockResponse != null
            ? int.tryParse(stockResponse['stock_quantity'].toString()) ?? 0
            : 0;

        final cartResponse = await supabase
            .from("tbl_cart")
            .select("cart_qty")
            .eq("product_id", product['id'])
            .neq('cart_status', 5);
        int cartQty = 0;
        if (cartResponse != null && cartResponse is List) {
          for (var item in cartResponse) {
            cartQty += int.tryParse(item['cart_qty'].toString()) ?? 0;
          }
        }

        final availableStock = stockQty - cartQty;

        setState(() {
          _stockData[product['id']] = availableStock;
        });
      }
    } catch (e) {
      _showError('Error fetching stock: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  List<Map<String, dynamic>> _filteredProducts() {
    if (_selectedType == 'All') return _products;
    return _products.where((product) {
      final typeName = product['tbl_type']['type_name']?.toString();
      return typeName != null && typeName == _selectedType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        color: Colors.blueGrey[50],
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Products',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddProduct()),
                      );
                      if (result) {
                        fetchProduct();
                      }
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Add Product', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey[700],
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Filter Tabs
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildFilterChip('All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Cars'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Bikes'),
                ],
              ),
              const SizedBox(height: 24),
              _filteredProducts().isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 50),
                          Icon(Icons.inventory_2, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No products found',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Click "Add Product" to start selling',
                            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: screenWidth > 1200 ? 4 : screenWidth > 800 ? 3 : 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: _filteredProducts().length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts()[index];
                        return _buildProductCard(product);
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String type) {
    final isSelected = _selectedType == type;
    return ChoiceChip(
      label: Text(type),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedType = type;
          });
        }
      },
      selectedColor: Colors.blueGrey[700],
      backgroundColor: Colors.blueGrey[100],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.blueGrey[800],
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final stock = _stockData[product['id']] ?? 0;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Productdetails(product: product['id'])),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  product['product_photo'] ?? 'https://via.placeholder.com/150',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['product_name'] ?? 'Unnamed Product',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\₹${product['product_price']?.toStringAsFixed(2) ?? '0.00'}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[700],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: stock > 0 ? Colors.green[100] : Colors.red[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          stock > 0 ? 'Stock: $stock' : 'Out of Stock',
                          style: TextStyle(
                            fontSize: 12,
                            color: stock > 0 ? Colors.green[800] : Colors.red[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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