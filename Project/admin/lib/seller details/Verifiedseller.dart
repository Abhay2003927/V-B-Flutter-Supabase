import 'package:admin/main.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ManageVerifiedSeller extends StatefulWidget {
  const ManageVerifiedSeller({super.key});

  @override
  State<ManageVerifiedSeller> createState() => _ManageVerifiedSellerState();
}

class _ManageVerifiedSellerState extends State<ManageVerifiedSeller> {
  List<Map<String, dynamic>> verifiedSellerList = [];
  List<Map<String, dynamic>> filteredSellerList = [];
  bool isLoading = true;
  String searchQuery = '';
  final TextEditingController _rejectionReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchVerifiedSellers();
  }

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  // Fetch verified sellers from Supabase
  Future<void> _fetchVerifiedSellers() async {
    try {
      setState(() {
        isLoading = true;
      });
      final response = await supabase
          .from('tbl_seller')
          .select()
          .eq('seller_status', 1); // Fetch verified sellers
      if (mounted) {
        setState(() {
          verifiedSellerList = List<Map<String, dynamic>>.from(response);
          filteredSellerList = verifiedSellerList; // Initialize filtered list
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching verified sellers: $e')),
        );
      }
    }
  }

  // Handle seller rejection
  Future<void> _rejectSeller(String sellerId, String? rejectionReason) async {
    try {
      setState(() {
        isLoading = true;
      });
      await supabase.from('tbl_seller').update({
        'seller_status': 2,
        'rejection_reason': rejectionReason ?? 'No reason provided',
      }).eq('id', sellerId);
      await _fetchVerifiedSellers(); // Refresh the list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seller rejected successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting seller: $e')),
        );
      }
    }
  }

  // Show rejection confirmation dialog with reason input
  Future<void> _showRejectConfirmationDialog(
      String sellerId, String? sellerName) async {
    _rejectionReasonController.clear(); // Clear previous input
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Rejection'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                    'Are you sure you want to reject ${sellerName ?? 'this seller'}?'),
                const SizedBox(height: 16),
                TextField(
                  controller: _rejectionReasonController,
                  decoration: const InputDecoration(
                    labelText: 'Rejection Reason (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Reject'),
              onPressed: () {
                Navigator.of(context).pop();
                _rejectSeller(sellerId, _rejectionReasonController.text);
              },
            ),
          ],
        );
      },
    );
  }

  // Show seller details in a dialog
  Future<void> _showSellerDetails(Map<String, dynamic> seller) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(seller['seller_name'] ?? 'Seller Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email: ${seller['seller_email'] ?? 'N/A'}'),
                const SizedBox(height: 8),
                Text('Contact: ${seller['seller_contact'] ?? 'N/A'}'),
                const SizedBox(height: 8),
                Text('Address: ${seller['seller_address'] ?? 'N/A'}'),
                const SizedBox(height: 8),
                Text(
                  'Verified Date: ${seller['verified_date'] ?? 'N/A'}',
                  style: const TextStyle(color: Colors.green),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Reject'),
              onPressed: () {
                Navigator.of(context).pop();
                _showRejectConfirmationDialog(
                  seller['id'].toString(),
                  seller['seller_name'],
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Filter sellers based on search query
  void _filterSellers(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredSellerList = verifiedSellerList;
      } else {
        filteredSellerList = verifiedSellerList.where((seller) {
          final name = seller['seller_name']?.toLowerCase() ?? '';
          final email = seller['seller_email']?.toLowerCase() ?? '';
          return name.contains(query.toLowerCase()) ||
              email.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _filterSellers,
              decoration: InputDecoration(
                labelText: 'Search Sellers',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _filterSellers('');
                  },
                ),
              ),
            ),
          ),
          // Main Content
          Expanded(
            child: isLoading
                ? _buildShimmerLoading()
                : filteredSellerList.isEmpty
                    ? const Center(child: Text('No verified sellers found'))
                    : RefreshIndicator(
                        onRefresh: _fetchVerifiedSellers,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: filteredSellerList.length,
                          itemBuilder: (context, index) {
                            final seller = filteredSellerList[index];
                            return _buildSellerCard(seller);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  // Build shimmer loading effect
  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 5, // Number of shimmer placeholders
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150,
                    height: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 100,
                    height: 36,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Build seller card
  Widget _buildSellerCard(Map<String, dynamic> seller) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seller Avatar
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[200],
              child: Text(
                seller['seller_name']?.isNotEmpty == true
                    ? seller['seller_name'][0].toUpperCase()
                    : 'S',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Seller Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    seller['seller_name'] ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    seller['seller_email'] ?? 'N/A',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Contact: ${seller['seller_contact'] ?? 'N/A'}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Verified: ${seller['verified_date'] ?? 'N/A'}',
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
            // Action Buttons
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.info, color: Colors.blueGrey),
                  onPressed: () => _showSellerDetails(seller),
                  tooltip: 'View Details',
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  onPressed: () => _showRejectConfirmationDialog(
                    seller['id'].toString(),
                    seller['seller_name'],
                  ),
                  tooltip: 'Reject Seller',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}