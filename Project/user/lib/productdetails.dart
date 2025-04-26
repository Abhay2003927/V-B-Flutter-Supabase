import 'package:flutter/material.dart';
import 'package:user/main.dart';
import 'package:user/servies/cart_servies.dart';

class ProductDetails extends StatefulWidget {
  final int productId;

  const ProductDetails({super.key, required this.productId});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  Map<String, dynamic> productData = {};
  bool isLoading = true;
  bool hasError = false;
  final cartService = CartService(supabase);

  @override
  void initState() {
    super.initState();
    fetchProduct();
  }

  Future<void> fetchProduct() async {
    try {
      print("Fetching product with ID: ${widget.productId}");
      final response = await supabase
          .from("tbl_product")
          .select('*,tbl_transmission(transmission_name),'
              'tbl_engine(engine_name),tbl_brand(brand_name),tbl_year(year_name),'
              'tbl_category(category_name),tbl_type(type_name),tbl_model(model_name)')
          .eq('id', widget.productId)
          .maybeSingle();
      print("Response: $response");
      setState(() {
        if (response != null) {
          productData = response;
          print("Product Data: $productData");
        } else {
          hasError = true;
          print("No product found for ID: ${widget.productId}");
        }
        isLoading = false;
      });
    } catch (e, stackTrace) {
      print("Error fetching product: $e");
      print("Stack trace: $stackTrace");
      setState(() {
        hasError = true;
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching product: $e")),
        );
      }
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
        title: Text(
           "Spare Part Details",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.blueGrey,
              ),
            )
          : hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Product not found or error occurred",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Retry",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  color: Colors.grey[100],
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Product Image Section
                        Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: productData['product_photo']?.toString().isNotEmpty ?? false
                                ? Image.network(
                                    productData['product_photo'],
                                    height: 250,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      print("Image load error: $error");
                                      return Image.asset(
                                        "assets/sper.jpeg",
                                        height: 250,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  )
                                : Image.asset(
                                    "assets/sper.jpeg",
                                    height: 250,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        // Product Details Section
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productData['product_name']?.toString() ?? "N/A",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "\$${productData['product_price']?.toString() ?? "N/A"}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Specifications",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              const Divider(color: Colors.grey),
                              buildDetailRow("Brand:", productData['tbl_brand']?['brand_name']?.toString() ?? "N/A"),
                              buildDetailRow("Model:", productData['tbl_model']?['model_name']?.toString() ?? "N/A"),
                              buildDetailRow("Year:", productData['tbl_year']?['year_name']?.toString() ?? "N/A"),
                              buildDetailRow("Category:", productData['tbl_category']?['category_name']?.toString() ?? "N/A"),
                              buildDetailRow("Type:", productData['tbl_type']?['type_name']?.toString() ?? "N/A"),
                              buildDetailRow("Engine:", productData['tbl_engine']?['engine_name']?.toString() ?? "N/A"),
                              buildDetailRow("Transmission:", productData['tbl_transmission']?['transmission_name']?.toString() ?? "N/A"),
                              const SizedBox(height: 16),
                              const Text(
                                "Details",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              const Divider(color: Colors.grey),
                              Text(
                                productData['product_details']?.toString() ?? "No details available",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Add to Cart Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: ElevatedButton(
                             onPressed: () => addItemToCart(context, productData['id']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey[800],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                              elevation: 5,
                            ),
                            child: const Text(
                              "Add to Cart",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget buildDetailRow(String label, String value, {double height = 40}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
              height: height,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}