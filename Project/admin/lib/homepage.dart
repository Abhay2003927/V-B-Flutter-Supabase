import 'package:admin/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:admin/seller%20details/Verifiedseller.dart';
import 'package:admin/seller%20details/ViewSeller.dart';
import 'package:admin/seller%20details/rejected_seller.dart';
import 'package:admin/profile.dart';
import 'package:admin/car%20details/brand.dart';
import 'package:admin/car%20details/engine.dart';
import 'package:admin/car%20details/model.dart';
import 'package:admin/car%20details/transmission.dart';
import 'package:admin/car%20details/type.dart';
import 'package:admin/car%20details/year.dart';
import 'package:admin/category.dart';
import 'package:admin/district.dart';
import 'package:admin/place.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  String adminName = 'Admin';
  bool isSidebarExpanded = true;

  int totalUsers = 0;
  int totalCategories = 0;
  int totalPartsSold = 0;

  final List<Map<String, dynamic>> menuItems = [
    {'name': 'Category', 'icon': Icons.category, 'page': const Category()},
    {'name': 'District', 'icon': Icons.location_city, 'page': const District()},
    {'name': 'Place', 'icon': Icons.place, 'page': const Place()},
    {'name': 'Brand', 'icon': Icons.branding_watermark, 'page': const Brand()},
    {'name': 'Model', 'icon': Icons.precision_manufacturing, 'page': const ModelScreen()},
    {'name': 'Transmission', 'icon': Icons.settings, 'page': const Transmission()},
    {'name': 'Year', 'icon': Icons.date_range, 'page': const Year()},
    {'name': 'Engine', 'icon': Icons.engineering, 'page': const Engine()},
    {'name': 'Type', 'icon': Icons.directions_car, 'page': const TypeScreen()},
    {'name': 'Verified', 'icon': Icons.verified, 'page': ManageVerifiedSeller()},
    {'name': 'Rejected', 'icon': Icons.cancel, 'page': const ManageRejectedSeller()},
    {'name': 'View New Seller', 'icon': Icons.view_list, 'page': ManageNewSeller()},
  ];

  @override
  void initState() {
    super.initState();
    fetchUser();
    // fetchDashboardCounts();
  }

  Future<void> fetchUser() async {
    try {
      String uid = Supabase.instance.client.auth.currentUser!.id;
      final response = await Supabase.instance.client
          .from("tbl_admin")
          .select()
          .eq('id', uid)
          .single();
      setState(() {
        adminName = response['admin_name'] ?? "Admin";
      });
    } catch (e) {
      print("User not found: $e");
    }
  }

  // Future<void> fetchDashboardCounts() async {
  //   try {
  //     final usersRes = await Supabase.instance.client
  //         .from('tbl_user')
  //         .select('id', const FetchOptions(count: CountOption.exact));
  //     final categoriesRes = await Supabase.instance.client
  //         .from('tbl_category')
  //         .select('id', const FetchOptions(count: CountOption.exact));
  //     final partsRes = await Supabase.instance.client
  //         .from('tbl_parts')
  //         .select('id', const FetchOptions(count: CountOption.exact));

  //     setState(() {
  //       totalUsers = usersRes.count ?? 0;
  //       totalCategories = categoriesRes.count ?? 0;
  //       totalPartsSold = partsRes.count ?? 0;
  //     });
  //   } catch (e) {
  //     print('Error fetching dashboard counts: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isWideScreen && isSidebarExpanded ? 260 : isWideScreen ? 80 : 0,
            child: isWideScreen ? _buildSidebar() : null,
          ),
          _buildMainContent(isWideScreen),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          const Icon(Icons.admin_panel_settings, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            'Admin Dashboard',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF1E2A44),
      centerTitle: false,
      actions: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: const Color(0xFF1E2A44)),
            ),
            const SizedBox(width: 10),
            Text(adminName, style: GoogleFonts.inter(color: Colors.white)),
            PopupMenuButton<String>(
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
              itemBuilder: (context) => [
                const PopupMenuItem(value: "profile", child: Text("Profile")),
                const PopupMenuItem(value: "submit", child: Text("Submit")),
                const PopupMenuItem(value: "logout", child: Text("Logout")),
              ],
              onSelected: (value) {
                if (value == 'profile') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const Aprofile()));
                } else if (value == 'submit') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Submit button pressed!')),
                  );
                } else if (value == 'logout') {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                }
              },
            ),
            const SizedBox(width: 16),
          ],
        )
      ],
      leading: IconButton(
        icon: Icon(isSidebarExpanded ? Icons.menu_open : Icons.menu, color: Colors.white),
        onPressed: () => setState(() => isSidebarExpanded = !isSidebarExpanded),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E2A44),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          if (isSidebarExpanded)
            Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: const Color(0xFF1E2A44)),
                ),
                const SizedBox(height: 8),
                Text(
                  adminName,
                  style: GoogleFonts.inter(fontSize: 18, color: Colors.white),
                ),
                Text(
                  'Admin Panel',
                  style: GoogleFonts.inter(color: Colors.white70),
                ),
              ],
            ),
          const Divider(color: Colors.white24),
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) => _buildMenuItem(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index) {
    final isSelected = selectedIndex == index;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF26A69A) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          selected: isSelected,
          leading: Icon(
            menuItems[index]['icon'],
            color: isSelected ? Colors.white : Colors.white70,
          ),
          title: isSidebarExpanded
              ? Text(
                  menuItems[index]['name'],
                  style: GoogleFonts.inter(
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                )
              : null,
          onTap: () => setState(() => selectedIndex = index),
        ),
      ),
    );
  }

  Widget _buildMainContent(bool isWideScreen) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isWideScreen) _buildMobileHeader(),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: menuItems[selectedIndex]['page'],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Admin: $adminName',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E2A44),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF1E2A44)),
          onPressed: () => _showMobileMenu(context),
        ),
      ],
    );
  }

   

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF26A69A).withOpacity(0.1),
            child: Icon(icon, color: const Color(0xFF26A69A)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E2A44),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        children: [
          const SizedBox(height: 16),
          Text('Menu', style: GoogleFonts.inter(fontSize: 18)),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    setState(() => selectedIndex = index);
                    Navigator.pop(context);
                  },
                  leading: Icon(
                    menuItems[index]['icon'],
                    color: const Color(0xFF1E2A44),
                  ),
                  title: Text(
                    menuItems[index]['name'],
                    style: GoogleFonts.inter(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}