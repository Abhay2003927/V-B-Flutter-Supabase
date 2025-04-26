import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:animate_do/animate_do.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user/main.dart';

class ViewComplaints extends StatefulWidget {
  const ViewComplaints({super.key});

  @override
  State<ViewComplaints> createState() => _ViewComplaintsState();
}

class _ViewComplaintsState extends State<ViewComplaints> {
  bool _isLoading = true;
  List<Map<String, dynamic>> complaints = [];

  @override
  void initState() {
    
    super.initState();
    _fetchComplaints();
  }

  // Fetch complaints for the authenticated user
  Future<void> _fetchComplaints() async {
    setState(() => _isLoading = true);

    try {
      final uid = supabase.auth.currentUser!.id;
      final response = await supabase
          .from('tbl_complaint')
          .select('*, tbl_product(product_name)')
          .eq('user_id', uid)
           ;

      setState(() {
        complaints = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      _showSnackBar('Error loading complaints: $e', Colors.red[800]!);
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
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Get status text
  String _getStatusText(int? status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'My Complaints',
          style: GoogleFonts.sanchez(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red[800],
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: SpinKitFadingCircle(color: Colors.red[800], size: 50),
      );
    }

    if (complaints.isEmpty) {
      return Center(
        child: FadeInUp(
          duration: const Duration(milliseconds: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sentiment_dissatisfied,
                size: 100,
                color: Colors.red[800]!.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No Complaints Found',
                style: GoogleFonts.sanchez(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your submitted complaints will appear here',
                style: GoogleFonts.sanchez(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[800],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Back to Home',
                  style: GoogleFonts.sanchez(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchComplaints,
      child: ListView.builder(
        itemCount: complaints.length,
        itemBuilder: (context, index) {
          return FadeInUp(
            duration: Duration(milliseconds: 300 + index * 100),
            child: _buildComplaintCard(complaints[index]),
          );
        },
      ),
    );
  }

  // Show complaint photo in a dialog
  void _showPicture(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                height: MediaQuery.of(context).size.height * 0.5,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[600],
                    size: 50,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'Close',
                  style: GoogleFonts.sanchez(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Complaint card
  Widget _buildComplaintCard(Map<String, dynamic> complaint) {
    final status = complaint['complaint_status'] ?? 0;
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      shadowColor: Colors.grey.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Product and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    complaint['tbl_product']?['product_name'] ?? 'Unknown Product',
                    style: GoogleFonts.sanchez(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[800],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Chip(
                  label: Text(
                    _getStatusText(status),
                    style: GoogleFonts.sanchez(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  backgroundColor: _getStatusColor(status).withOpacity(0.1),
                  side: BorderSide(color: _getStatusColor(status)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Date and Photo
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo
                InkWell(
                  onTap: () {
                    if (complaint['complaint_photo'] != null &&
                        complaint['complaint_photo'].isNotEmpty) {
                      _showPicture(complaint['complaint_photo']);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: complaint['complaint_photo'] == null ||
                            complaint['complaint_photo'].isEmpty
                        ? Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.grey[600],
                            ),
                          )
                        : Image.network(
                            complaint['complaint_photo'],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                // Date
                Expanded(
                  child: Text(
                    'Date: ${complaint['complaint_date'] ?? complaint['created_at']?.toString().split(' ')[0] ?? 'Unknown'}',
                    style: GoogleFonts.sanchez(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Complaint Title
            Text(
              complaint['complaint_title'] ?? 'Untitled',
              style: GoogleFonts.sanchez(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // Complaint Content
            Text(
              complaint['complaint_content'] ?? 'No description',
              style: GoogleFonts.sanchez(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),

            // Reply Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seller Reply:',
                    style: GoogleFonts.sanchez(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    complaint['complaint_replay'] ?? 'No reply yet',
                    style: GoogleFonts.sanchez(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontStyle: complaint['complaint_replay'] == null
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
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