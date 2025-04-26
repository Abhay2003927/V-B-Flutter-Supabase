import 'package:flutter/material.dart';
import 'package:user/homepage.dart';
import 'package:user/main.dart';
import 'package:user/payments.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;
  int? bid;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  // Fetch Cart Items from Supabase
  Future<void> fetchCartItems() async {
    try {
      final booking = await supabase
          .from('tbl_booking')
          .select("id")
          .eq('user_id', supabase.auth.currentUser!.id)
          .eq('booking_status', 0)
          .maybeSingle();

      if (booking == null) {
        setState(() {
          cartItems = [];
          isLoading = false;
        });
        return;
      }

      int bookingId = booking['id'];
      setState(() => bid = bookingId);

      final cartResponse = await supabase
          .from('tbl_cart')
          .select('*')
          .eq('booking_id', bookingId)
          .eq('cart_status', 0);

      List<Map<String, dynamic>> items = [];
      for (var cartItem in cartResponse) {
        final itemResponse = await supabase
            .from('tbl_product')
            .select('product_name, product_photo, product_price')
            .eq('id', cartItem['product_id'])
            .maybeSingle();

        final stock = await supabase
            .from('tbl_stock')
            .select('stock_quantity')
            .eq('product_id', cartItem['product_id']);
        
        // int totalStock = 0;
        // for (var item in stock) {
        //   int sQty = item['stock_quantity'];
        //   totalStock += sQty;
        // }
        int totalStock =
            stock.fold(0, (sum, item) => sum + (item['stock_quantity'] as int));

        final cart = await supabase
            .from('tbl_cart')
            .select('cart_qty')
            .eq('product_id', cartItem['product_id']);

        int totalCartQty =
            cart.fold(0, (sum, item) => sum + (item['cart_qty'] as int));

        num remainingStock = totalStock - totalCartQty + cartItem['cart_qty'];

        if (itemResponse != null) {
          items.add({
            "id": cartItem['id'],
            "product_id": cartItem['product_id'],
            "name": itemResponse['product_name'],
            "image": itemResponse['product_photo'],
            "price": itemResponse['product_price'],
            "quantity": cartItem['cart_qty'],
            "stock": remainingStock,
          });
        }
      }

      setState(() {
        cartItems = items;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching cart data: $e");
      setState(() => isLoading = false);
    }
  }

  // Update Cart Quantity
  Future<void> updateCartQuantity(int cartId, int newQty) async {
    try {
      await supabase
          .from('tbl_cart')
          .update({'cart_qty': newQty})
          .eq('id', cartId);
      fetchCartItems();
    } catch (e) {
      print("Error updating cart quantity: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update quantity: $e')),
      );
    }
  }

  // Delete Item from Cart
  Future<void> deleteCartItem(int cartId) async {
    try {
      await supabase.from('tbl_cart').delete().eq('id', cartId);
      fetchCartItems();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Item removed from cart'),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print("Error deleting item: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete item: $e')),
      );
    }
  }

  // Calculate Total Price
  double getTotalPrice() {
    return cartItems.fold(
        0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // appBar: AppBar(
      //   title: const Text(
      //     "Your Cart",
      //     style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      //   ),
      //   backgroundColor: Colors.red[800],
      //   elevation: 0,
      //   actions: [
      //     TextButton.icon(
      //       onPressed: () {
      //         // Navigate to OrdersPage when implemented
      //       },
      //       icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
      //       label: const Text(
      //         "My Orders",
      //         style: TextStyle(color: Colors.white),
      //       ),
      //     ),
      //   ],
      // ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.red[800]))
          : cartItems.isEmpty
              ? _buildEmptyCart()
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          var item = cartItems[index];
                          return _buildCartItem(item);
                        },
                      ),
                    ),
                    _buildOrderSummary(),
                  ],
                ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item) {
    return Dismissible(
      key: Key(item['id'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red[600],
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) => deleteCartItem(item['id']),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item['image'],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported,
                        color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₹${item['price'].toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildQuantityControls(item),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.red[600]),
                          onPressed: () => deleteCartItem(item['id']),
                        ),
                      ],
                    ),
                    if (item['stock'] <= 5 && item['stock'] > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "Only ${item['stock']} left in stock",
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    if (item['stock'] <= 0)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          "Out of stock",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
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

  Widget _buildQuantityControls(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            onPressed: item['quantity'] > 1
                ? () => updateCartQuantity(item['id'], item['quantity'] - 1)
                : null,
          ),
          SizedBox(
            width: 40,
            child: Center(
              child: Text(
                item['quantity'].toString(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: item['stock'] > 0
                ? () => updateCartQuantity(item['id'], item['quantity'] + 1)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Subtotal (${cartItems.length} items)",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              Text(
                "₹${getTotalPrice().toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "₹${getTotalPrice().toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: cartItems.isEmpty
                  ? null
                  : () {
                      int total = getTotalPrice().toInt();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PaymentGatewayScreen(id: bid!, amt: total),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Proceed to Checkout",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 120,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            "Your Cart is Empty",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Add some items to get started!",
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Homepagescreen()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[800],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Start Shopping",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: CartPage(),
    debugShowCheckedModeBanner: false,
  ));
}