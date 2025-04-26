import 'package:admin/main.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:shimmer/shimmer.dart';

class ManageRejectedSeller extends StatefulWidget {
  const ManageRejectedSeller({super.key});

  @override
  State<ManageRejectedSeller> createState() => _ManageRejectedSellerState();
}

class _ManageRejectedSellerState extends State<ManageRejectedSeller> {
  List<Map<String, dynamic>> rejectedSellerList = [];
  List<Map<String, dynamic>> filteredSellerList = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchRejectedSellers();
  }

  // Fetch rejected sellers from Supabase
  Future<void> _fetchRejectedSellers() async {
    try {
      setState(() {
        isLoading = true;
      });
      final response = await supabase
          .from('tbl_seller')
          .select()
          .eq('seller_status', 2); // Fetch rejected sellers
      if (mounted) {
        setState(() {
          rejectedSellerList = List<Map<String, dynamic>>.from(response);
          filteredSellerList = rejectedSellerList; // Initialize filtered list
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching rejected sellers: $e')),
        );
      }
    }
  }

  // Handle seller acceptance
  Future<void> _acceptSeller(String sellerId) async {
    try {
      setState(() {
        isLoading = true;
      });
      await supabase
          .from('tbl_seller')
          .update({'seller_status': 1}).eq('id', sellerId);
      await _fetchRejectedSellers(); // Refresh the list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seller accepted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error accepting seller: $e')),
        );
      }
    }
  }

  // Show confirmation dialog for accepting a seller
  Future<void> _showAcceptConfirmationDialog(
      String sellerId, String? sellerName) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Acceptance'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Are you sure you want to accept ${sellerName ?? 'this seller'}?'),
                const Text('This action cannot be undone.'),
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
              child: const Text('Accept'),
              onPressed: () {
                Navigator.of(context).pop();
                _acceptSeller(sellerId);
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
                  'Rejection Reason: ${seller['rejection_reason'] ?? 'N/A'}',
                  style: const TextStyle(color: Colors.red),
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
              child: const Text('Accept'),
              onPressed: () {
                Navigator.of(context).pop();
                _showAcceptConfirmationDialog(
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
        filteredSellerList = rejectedSellerList;
      } else {
        filteredSellerList = rejectedSellerList.where((seller) {
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
             
          ),
          // Main Content
          Expanded(
            child: isLoading
                ? _buildShimmerLoading()
                : filteredSellerList.isEmpty
                    ? const Center(child: Text('No rejected sellers found'))
                    : RefreshIndicator(
                        onRefresh: _fetchRejectedSellers,
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
                    'Reason: ${seller['rejection_reason'] ?? 'N/A'}',
                    style: const TextStyle(color: Colors.red),
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
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  onPressed: () => _showAcceptConfirmationDialog(
                    seller['id'].toString(),
                    seller['seller_name'],
                  ),
                  tooltip: 'Accept Seller',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}