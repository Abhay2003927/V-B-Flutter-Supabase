import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user/categorypage.dart';
import 'package:user/login.dart';
import 'package:user/main.dart';
import 'package:user/mycarts.dart';
import 'package:user/slide/helpandsupport.dart';
import 'package:user/viewcomplaints.dart';
import 'package:user/myorders.dart';
import 'package:user/myprofile.dart';
import 'package:user/searchproduct.dart';

class Homepagescreen extends StatefulWidget {
  const Homepagescreen({super.key});

  @override
  State<Homepagescreen> createState() => _HomepagescreenState();
}

class _HomepagescreenState extends State<Homepagescreen> {
  String name = "";
  String email = "";
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
    try {
      String uid = Supabase.instance.client.auth.currentUser!.id;
      final response = await Supabase.instance.client
          .from("tbl_user")
          .select()
          .eq('id', uid)
          .single();
      setState(() {
        name = response['user_name'] ?? "User";
        email = response['user_email'] ?? "email@example.com";
      });
    } catch (e) {
      print("User not found: $e");
    }
  }

  final List<Widget> _pages = [
    const HomeContent(),
    const SearchProduct(),
    const CartPage(),
    const MyProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(
        title: const Text(
          "BICA Parts",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.red[800],
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.red[800],
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _selectedIndex == 0
                    ? Colors.red[800]!.withOpacity(0.2)
                    : Colors.transparent,
              ),
              child: const Icon(Icons.home_outlined),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red[800]!.withOpacity(0.2),
              ),
              child: const Icon(Icons.home),
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _selectedIndex == 1
                    ? Colors.red[800]!.withOpacity(0.2)
                    : Colors.transparent,
              ),
              child: const Icon(Icons.search_outlined),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red[800]!.withOpacity(0.2),
              ),
              child: const Icon(Icons.search),
            ),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _selectedIndex == 2
                    ? Colors.red[800]!.withOpacity(0.2)
                    : Colors.transparent,
              ),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red[800]!.withOpacity(0.2),
              ),
              child: const Icon(Icons.shopping_cart),
            ),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _selectedIndex == 3
                    ? Colors.red[800]!.withOpacity(0.2)
                    : Colors.transparent,
              ),
              child: const Icon(Icons.person_outline),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red[800]!.withOpacity(0.2),
              ),
              child: const Icon(Icons.person),
            ),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            accountEmail: Text(
              email,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : "U",
                style: const TextStyle(fontSize: 40, color: Colors.red),
              ),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red[800]!, Colors.red[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                    Icons.shopping_bag, "My Orders", const OrdersPage()),
                    SizedBox(height: 5),
                _buildDrawerItem(
                    Icons.comment_bank, "My Complaints", ViewComplaints()),
                    SizedBox(height: 5),
                _buildDrawerItem(Icons.settings, "Settings", const Setting()),
                SizedBox(height: 5),
                _buildDrawerItem(Icons.headset_mic_rounded, "Help & Support",
                    const Helpandsupport()),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildDrawerItem(Icons.logout, "Log Out", null, onTap: () {
            Supabase.instance.client.auth.signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, Widget? screen,
      {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.red[800]),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
      onTap: onTap ??
          (screen != null
              ? () {
                  Navigator.pop(context); // Close drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => screen),
                  );
                }
              : null),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<Map<String, dynamic>> typelist = [];
  final ScrollController _scrollController = ScrollController();

  Future<void> fetchtype() async {
    try {
      final response = await supabase.from('tbl_type').select();
      print("type Data: $response");
      setState(() {
        typelist = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchtype();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Promotions Banner
        SizedBox(
          height: 20, // Fixed from 25 to 150 for visibility
          child: PageView.builder(
            itemCount: 3,
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(
                        "https://via.placeholder.com/800x400?text=Promotion+${index + 1}",
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Categories Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Categories",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[800],
                ),
              ),
              // Text(
              //   "See All",
              //   style: TextStyle(
              //     fontSize: 14,
              //     color: Colors.red[800],
              //     fontWeight: FontWeight.w500,
              //   ),
              // ),
            ],
          ),
        ),
        // Categories List
        Expanded(
          child: typelist.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.red,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: typelist.length,
                    itemBuilder: (context, index) {
                      final data = typelist[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildCategoryCard(
                          data['type_name'] ?? "Unnamed",
                          data['type_image'] ??
                              'https://via.placeholder.com/150',
                          data['id'],
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String title, String imageUrl, int type) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Categorypage(type: type),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: Colors.grey.withOpacity(0.2),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Full-bleed image
              Image.network(
                imageUrl,
                width: double.infinity,
                height: 200, // Fixed height for consistency
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: Colors.red[800],
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 50,
                      ),
                    ),
                  );
                },
              ),
              // Semi-transparent background for text
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: Colors.black.withOpacity(0.5),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Styled Settings Page
class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  String _name = "User";
  String _email = "email@example.com";

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _fetchUser();
  }

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  // Fetch user data from Supabase
  Future<void> _fetchUser() async {
    try {
      String uid = Supabase.instance.client.auth.currentUser!.id;
      final response = await Supabase.instance.client
          .from("tbl_user")
          .select()
          .eq('id', uid)
          .single();
      setState(() {
        _name = response['user_name'] ?? "User";
        _email = response['user_email'] ?? "email@example.com";
      });
    } catch (e) {
      print("User not found: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.red[800],
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                shadowColor: Colors.grey.withOpacity(0.2),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.red[800],
                        child: Text(
                          _name.isNotEmpty ? _name[0].toUpperCase() : "U",
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            _email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Appearance Section
              
              const SizedBox(height: 24),
              // Notifications Section
              Text(
                "Notifications",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[800],
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                shadowColor: Colors.grey.withOpacity(0.2),
                child: SwitchListTile(
                  title: const Text(
                    "Enable Notifications",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    "Receive order updates and promotions",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  value: _notificationsEnabled,
                  activeColor: Colors.red[800],
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    _saveSettings('notificationsEnabled', value);
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Account Section
              Text(
                "Account",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[800],
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                shadowColor: Colors.grey.withOpacity(0.2),
                child: ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: Colors.red[800],
                  ),
                  title: const Text(
                    "Log Out",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  onTap: () {
                    Supabase.instance.client.auth.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Supabase (adjust with your actual Supabase URL and anon key)
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  runApp(const MaterialApp(
    home: Homepagescreen(),
    debugShowCheckedModeBanner: false,
  ));
}