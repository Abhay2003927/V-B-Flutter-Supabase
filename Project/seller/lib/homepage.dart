import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:seller/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:seller/main.dart';
import 'package:seller/orders.dart';
import 'package:seller/orderdetails.dart';
import 'package:seller/manageproducts.dart';
import 'package:seller/sprofile.dart';
import 'package:seller/view_complaints.dart';

class SHomepagescreen extends StatefulWidget {
  const SHomepagescreen({super.key});

  @override
  State<SHomepagescreen> createState() => _SHomepagescreenState();
}

class _SHomepagescreenState extends State<SHomepagescreen> {
  int selectedIndex = 0;
  bool isLoading = true;
  String? sellerName;
  Map<String, dynamic> stats = {
    'total_sales': '₹0',
    'orders': '0',
    'products': '0',
    'pending': '0',
  };
  List<Map<String, dynamic>> recentOrders = [];

  final List<Map<String, dynamic>> menuItems = [
    {
      'name': 'Dashboard',
      'icon': Icons.dashboard,
      'page': null, // Will be built dynamically
    },
    {'name': 'Manage Orders', 'icon': Icons.receipt_long, 'page': const SellerViewOrders()},
    {'name': 'Manage Products', 'icon': Icons.storefront, 'page': const Manageproducts()},
    {'name': ' Manage Complaints', 'icon': Icons.report, 'page': const ComplaintsPage()},
  ];

  @override
  void initState() {
    super.initState();

    fetchseller();
    if (selectedIndex == 0) {
      _fetchDashboardData();
    }
  }

 Future<void> fetchseller() async {
    try {
      String uid = Supabase.instance.client.auth.currentUser!.id;
      final response = await Supabase.instance.client
          .from("tbl_seller")
          .select()
          .eq('id', uid)
          .single();
      setState(() {
       sellerName= response['seller_name'] ?? "Seller";
        
      });
    } catch (e) {
      print("User not found: $e");
    }
  }

  Future<void> _fetchDashboardData() async {
    try {
      setState(() => isLoading = true);

      // Fetch stats
      final salesResponse = await supabase
          .from('tbl_booking')
          .select('booking_amount')
          .inFilter('booking_status', [1, 4]); // Delivered or Order Placed
      final totalSales = salesResponse.fold<double>(
          0, (sum, item) => sum + (item['booking_amount'] ?? 0));
      
      final ordersResponse = await supabase
          .from('tbl_booking')
          .select()
          .inFilter('booking_status', [0, 1, 2, 3, 4]);
      final totalOrders = ordersResponse.length;

      final productsResponse = await supabase.from('tbl_product').select();
      final totalProducts = productsResponse.length;

      final pendingResponse = await supabase
          .from('tbl_booking')
          .select()
          .eq('booking_status', 0); // Processing
      final pendingOrders = pendingResponse.length;

      // Fetch recent orders
      final orders = await supabase
          .from('tbl_booking')
          .select('*, tbl_user(user_name), tbl_cart(*, tbl_product(product_price))')
          .inFilter('booking_status', [0, 1, 2, 3, 4])
          .order('created_at', ascending: false)
          .limit(4);

      List<Map<String, dynamic>> ordersList = [];
      for (var order in orders) {
        final cartItems = order['tbl_cart'] as List<dynamic>;
        final total = cartItems.fold<double>(
            0,
            (sum, item) =>
                sum + (item['cart_qty'] * (item['tbl_product']['product_price'] ?? 0)));
        ordersList.add({
          'id': order['id'],
          'customer': order['tbl_user']['user_name'] ?? 'Unknown',
          'date': order['created_at']?.toString().split(' ')[0] ?? 'Unknown',
          'amount': total,
          'status': order['booking_status'],
          'cart_status': cartItems.isNotEmpty ? cartItems[0]['cart_status'] : null,
        });
      }

      setState(() {
        stats = {
          'total_sales': '₹${totalSales.toStringAsFixed(2)}',
          'orders': totalOrders.toString(),
          'products': totalProducts.toString(),
          'pending': pendingOrders.toString(),
        };
        recentOrders = ordersList;
        isLoading = false;
      });
    } catch (e) {
      _showError('Error fetching dashboard data: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateOrderStatus(int bookingId, int currentStatus) async {
    try {
      final newStatus = currentStatus + 1 > 4 ? 4 : currentStatus + 1;
      await supabase
          .from('tbl_booking')
          .update({'booking_status': newStatus})
          .eq('id', bookingId);
      await supabase
          .from('tbl_cart')
          .update({'cart_status': newStatus})
          .eq('booking_id', bookingId);
      await _fetchDashboardData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      _showError('Error updating status: $e');
    }
  }

  Future<void> _logout() async {
    try {
      await supabase.auth.signOut();
      if (mounted) {
        Navigator.pushReplacement (context, MaterialPageRoute(builder: (context) => const Loginscreen()));
      }
    } catch (e) {
      _showError('Error logging out: $e');
    }
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
    final isWideScreen = screenWidth > 800;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
          if (isWideScreen)
            Container(
              width: 280,
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'S',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Seller Portal',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: menuItems.length,
                      itemBuilder: (context, index) => _buildMenuItem(index),
                    ),
                  ),
                  const Divider(height: 1),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               
                              Text(
                                'LogOut',
                                style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 14, 14, 14)),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout, color: Colors.grey),
                          tooltip: 'Logout',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // App Bar
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (!isWideScreen)
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () => _showMobileMenu(context),
                        ),
                      if (!isWideScreen) const SizedBox(width: 16),
                      Text(
                        menuItems[selectedIndex]['name'] as String,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      
                      IconButton(
                        icon: Stack(
                          children: [
                            const Icon(Icons.notifications_outlined),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 12,
                                  minHeight: 12,
                                ),
                                
                              ),
                            ),
                          ],
                        ),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 16),
                      if (isWideScreen)
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const Sprofile()),
                            );
                          },
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.deepPurple.shade100,
                                child: const Icon(Icons.person, color: Colors.deepPurple),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                sellerName ?? 'Seller',
                                style: const TextStyle(fontSize: 16, color: Colors.deepPurple),
                              ),
                              
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                // Content Area
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    color: Colors.grey[100],
                    child: selectedIndex == 0
                        ? _buildDashboardContent()
                        : menuItems[selectedIndex]['page'] as Widget,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      decoration: BoxDecoration(
        color: selectedIndex == index ? Colors.deepPurple.shade50 : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: () {
          setState(() {
            selectedIndex = index;
            if (index == 0) _fetchDashboardData();
          });
        },
        leading: Icon(
          menuItems[index]['icon'] as IconData,
          color: selectedIndex == index ? Colors.deepPurple : Colors.grey,
        ),
        title: Text(
          menuItems[index]['name'] as String,
          style: TextStyle(
            fontSize: 16,
            fontWeight: selectedIndex == index ? FontWeight.bold : FontWeight.normal,
            color: selectedIndex == index ? Colors.deepPurple : Colors.grey[700],
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minLeadingWidth: 20,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'S',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Seller Portal',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: menuItems.length,
                itemBuilder: (context, index) => ListTile(
                  leading: Icon(
                    menuItems[index]['icon'] as IconData,
                    color: selectedIndex == index ? Colors.deepPurple : Colors.grey,
                  ),
                  title: Text(
                    menuItems[index]['name'] as String,
                    style: TextStyle(
                      fontWeight: selectedIndex == index ? FontWeight.bold : FontWeight.normal,
                      color: selectedIndex == index ? Colors.deepPurple : Colors.grey[700],
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                      if (index == 0) _fetchDashboardData();
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(),
                const SizedBox(height: 24),
                _buildStatsGrid(),
                const SizedBox(height: 24),
                _buildChartsSection(),
                const SizedBox(height: 24),
                _buildRecentOrders(),
                const SizedBox(height: 24),
                _buildProductSection(),
              ],
            ),
          );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, ${sellerName ?? 'Seller'}!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Today is ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard('Total Sales', stats['total_sales'], Icons.attach_money, Colors.green),
        _buildStatCard('Orders', stats['orders'], Icons.shopping_bag, Colors.blue),
        _buildStatCard('Products', stats['products'], Icons.inventory_2, Colors.orange),
        _buildStatCard('Pending', stats['pending'], Icons.pending_actions, Colors.red),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            height: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sales Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const titles = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                              if (value.toInt() < titles.length && value.toInt() >= 0) {
                                return Text(titles[value.toInt()]);
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 3),
                            FlSpot(1, 2),
                            FlSpot(2, 5),
                            FlSpot(3, 3.1),
                            FlSpot(4, 4),
                            FlSpot(5, 5),
                          ],
                          isCurved: true,
                          color: Colors.deepPurple,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.deepPurple.withOpacity(0.2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Container(
            height: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Product Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          color: Colors.deepPurple,
                          value: 40,
                          title: '40%',
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: Colors.amber,
                          value: 30,
                          title: '30%',
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: Colors.green,
                          value: 15,
                          title: '15%',
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: Colors.red,
                          value: 15,
                          title: '15%',
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentOrders() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Orders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() => selectedIndex = 1); // Navigate to Manage Orders
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DataTable(
            columnSpacing: 20,
            columns: const [
              DataColumn(label: Text('Order ID')),
              DataColumn(label: Text('Customer')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Amount')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Action')),
            ],
            rows: recentOrders.map((order) => _buildOrderRow(order)).toList(),
          ),
        ],
      ),
    );
  }

  DataRow _buildOrderRow(Map<String, dynamic> order) {
    final status = order['status'] as int;
    String statusText;
    Color statusColor;
    String? buttonText;

    switch (status) {
      case 0:
        statusText = 'Processing';
        statusColor = Colors.orange;
        buttonText = 'Mark as Order Placed';
        break;
      case 1:
        statusText = 'Order Placed';
        statusColor = Colors.blue;
        buttonText = 'Mark as Order Packed';
        break;
      case 2:
        statusText = 'Order Packed';
        statusColor = Colors.yellow;
        buttonText = 'Mark as Order Shipped';
        break;
      case 3:
        statusText = 'Order Shipped';
        statusColor = Colors.purple;
        buttonText = 'Mark as Order Delivered';
        break;
      case 4:
        statusText = 'Order Delivered';
        statusColor = Colors.green;
        buttonText = null;
        break;
      default:
        statusText = 'Unknown';
        statusColor = Colors.grey;
        buttonText = null;
    }

    return DataRow(
      cells: [
        DataCell(Text('#ORD-${order['id']}')),
        DataCell(Text(order['customer'])),
        DataCell(Text(order['date'])),
        DataCell(Text('₹${order['amount'].toStringAsFixed(2)}')),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              style: TextStyle(color: statusColor),
            ),
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, size: 20),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailsPage(bid: order['id']),
                    ),
                  );
                },
                color: Colors.blue,
              ),
              if (buttonText != null)
                TextButton(
                  onPressed: () => _updateOrderStatus(order['id'], status),
                  child: Text(buttonText),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductSection() {
    // Dummy product data (replace with Supabase query)
    final products = [
      {
        'name': 'Sample Product 1',
        'imageUrl': 'https://via.placeholder.com/150',
        'price': 499.99,
        'stock': 10,
        'category': 'Electronics',
      },
      {
        'name': 'Sample Product 2',
        'imageUrl': 'https://via.placeholder.com/150',
        'price': 299.99,
        'stock': 0,
        'category': 'Clothing',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
       
    );
  }
}

class ProductCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final double price;
  final int stock;
  final String category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    Key? key,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.stock,
    required this.category,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              imageUrl,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 160,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: stock > 0 ? Colors.green[100] : Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        stock > 0 ? 'In Stock: $stock' : 'Out of Stock',
                        style: TextStyle(
                          fontSize: 12,
                          color: stock > 0 ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}