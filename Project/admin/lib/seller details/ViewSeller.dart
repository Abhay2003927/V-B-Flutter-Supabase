import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Initialize Supabase client (ensure this is done in main.dart)
final supabase = Supabase.instance.client;

class ManageNewSeller extends StatefulWidget {
  const ManageNewSeller({Key? key}) : super(key: key);

  @override
  State<ManageNewSeller> createState() => _ManageNewSellerState();
}

class _ManageNewSellerState extends State<ManageNewSeller> {
  List<Map<String, dynamic>> newSellerList = [];
  bool isLoading = false;
  String searchQuery = '';
  String sortBy = 'seller_name'; // Default sort by name

  @override
  void initState() {
    super.initState();
    fetchNewSellers();
  }

  Future<void> fetchNewSellers() async {
    setState(() => isLoading = true);
    try {
      final response = await supabase
          .from("tbl_seller")
          .select()
          .eq('seller_status', 0)
          .order(sortBy, ascending: true);

      setState(() {
        newSellerList = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar("Error loading new sellers: $e");
    }
  }

  Future<void> updateSellerStatus(String id, int status) async {
    setState(() => isLoading = true);
    try {
      await supabase
          .from('tbl_seller')
          .update({'seller_status': status}).eq('id', id);
      await fetchNewSellers();
      _showSnackBar(status == 1 ? "Seller approved" : "Seller rejected");
    } catch (e) {
      _showSnackBar("Error updating seller: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showConfirmationDialog({
    required String sellerId,
    required String sellerName,
    required bool isApprove,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(isApprove ? 'Confirm Approval' : 'Confirm Rejection'),
          content: Text(
              'Are you sure you want to ${isApprove ? 'approve' : 'reject'} $sellerName?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isApprove ? Colors.green : Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(isApprove ? 'Approve' : 'Reject'),
              onPressed: () {
                Navigator.of(context).pop();
                updateSellerStatus(sellerId, isApprove ? 1 : 2);
              },
            ),
          ],
        );
      },
    );
  }

  void _showImagePopup(String? imageUrl, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? PhotoView(
                        imageProvider: NetworkImage(imageUrl),
                        backgroundDecoration:
                            const BoxDecoration(color: Colors.black),
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered * 2,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.broken_image,
                              color: Colors.white, size: 50),
                        ),
                      )
                    : const Center(
                        child:
                            Icon(Icons.broken_image, color: Colors.white, size: 50),
                      ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Positioned(
                top: 10,
                left: 20,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSellerImage(String? url, String label) {
    return GestureDetector(
      onTap: () => _showImagePopup(url, label),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              url ?? 'https://via.placeholder.com/100',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 80),
            ),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSellerCard(Map<String, dynamic> seller) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seller Photos
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSellerImage(seller["seller_photo"], "Seller Photo"),
                const SizedBox(width: 20),
                _buildSellerImage(seller["seller_proof"], "Proof Document"),
              ],
            ),
            const Divider(height: 20),
            // Seller Details
            Text(
              seller["seller_name"] ?? 'N/A',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Email: ${seller["seller_email"] ?? 'N/A'}",
                style: const TextStyle(fontSize: 14)),
            Text("Contact: ${seller["seller_contact"] ?? 'N/A'}",
                style: const TextStyle(fontSize: 14)),
            Text("Address: ${seller["seller_address"] ?? 'N/A'}",
                style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  label: 'Accept',
                  color: Colors.green,
                  onPressed: () => _showConfirmationDialog(
                    sellerId: seller['id'].toString(),
                    sellerName: seller['seller_name'] ?? 'Unknown',
                    isApprove: true,
                  ),
                ),
                _buildActionButton(
                  label: 'Reject',
                  color: Colors.red,
                  onPressed: () => _showConfirmationDialog(
                    sellerId: seller['id'].toString(),
                    sellerName: seller['seller_name'] ?? 'Unknown',
                    isApprove: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by name or email...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        onChanged: (value) {
          setState(() {
            searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButton<String>(
        value: sortBy,
        isExpanded: true,
        hint: const Text('Sort by'),
        items: const [
          DropdownMenuItem(value: 'seller_name', child: Text('Name')),
          DropdownMenuItem(value: 'seller_email', child: Text('Email')),
          DropdownMenuItem(value: 'seller_contact', child: Text('Contact')),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() {
              sortBy = value;
              fetchNewSellers();
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredSellers = newSellerList.where((seller) {
      final name = seller['seller_name']?.toLowerCase() ?? '';
      final email = seller['seller_email']?.toLowerCase() ?? '';
      return name.contains(searchQuery) || email.contains(searchQuery);
    }).toList();

    return Scaffold(
       
      body: Column(
        children: [
          _buildSearchBar(),
          _buildSortDropdown(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredSellers.isEmpty
                    ? const Center(child: Text('No new sellers found'))
                    : RefreshIndicator(
                        onRefresh: fetchNewSellers,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: filteredSellers.length,
                          itemBuilder: (context, index) =>
                              _buildSellerCard(filteredSellers[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}