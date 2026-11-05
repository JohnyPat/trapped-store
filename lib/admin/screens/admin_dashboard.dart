import 'package:flutter/material.dart';

import '../models/admin_product_model.dart';
import '../models/admin_order_model.dart';
import '../models/admin_customer_model.dart';

import '../services/admin_product_service.dart';
import '../services/admin_order_service.dart';
import '../services/admin_customer_service.dart';
import '../services/admin_auth_service.dart';

import '../widgets/admin_sidebar.dart';
import '../widgets/admin_appbar.dart';
import '../widgets/dashboard_card.dart';
import 'package:trapped_store/shared/constants/admin_constants.dart';

import 'admin_products_page.dart';
import 'admin_categories_page.dart';
import 'admin_orders_page.dart';
import 'admin_customers_page.dart';
import 'admin_reports_page.dart';
import 'admin_site_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  String? _error;

  // Dashboard stats
  int _totalProducts = 0;
  int _totalOrders = 0;
  int _totalCustomers = 0;
  double _totalSales = 0.0;
  int _pendingOrders = 0;
  int _completedOrders = 0;
  List<AdminProduct> _lowStockProducts = [];
  List<AdminOrder> _recentOrders = [];
  List<AdminCustomer> _topCustomers = [];

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  Future<void> _checkAdminAccess() async {
    try {
      final isAdmin = await AdminAuthService().isAdmin;
      if (!mounted) return;
      if (!isAdmin) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your account does not have admin privileges.'),
          ),
        );
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/admin/login',
          (route) => false,
        );
        return;
      }
      await _initializeData();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to verify admin access or load data:\n$e';
      });
    }
  }

  Future<void> _initializeData() async {
    final productService = AdminProductService();
    final orderService = AdminOrderService();
    final customerService = AdminCustomerService();
    var step = 'starting';

    try {
      step = 'loading products';
      final productsSnap = await productService.watchAllProducts().first;

      step = 'loading orders';
      final ordersSnap = await orderService.watchAllOrders().first;

      step = 'loading customers';
      final customersSnap = await customerService.watchAllCustomers().first;

      if (!mounted) return;
      setState(() {
      _totalProducts = productsSnap.length;
      _totalOrders = ordersSnap.length;
      _totalCustomers = customersSnap.length;
      _pendingOrders = 0;
      _completedOrders = 0;
      for (final order in ordersSnap) {
        if (order.orderStatus.toLowerCase() == 'pending') _pendingOrders++;
        if (order.orderStatus.toLowerCase() == 'delivered') _completedOrders++;
      }

      // Calculate total sales from delivered orders
      _totalSales = 0.0;
      for (final order in ordersSnap) {
        if (order.orderStatus.toLowerCase() == 'delivered') _totalSales += order.totalAmount;
      }

      // Low stock products
      _lowStockProducts = productsSnap
          .where((p) => p.isLowStock)
          .toList()
        ..sort((a, b) => a.stock.compareTo(b.stock));

      // Recent orders (last 5)
      _recentOrders = ordersSnap.take(5).toList();

      // Top customers (by order count simplified)
      _topCustomers = customersSnap;

      _isLoading = false;
      _error = null;
    });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed while $step. Details: [${e.runtimeType}] $e';
      });
    }
  }

  String _formatCurrency(double amount) => '\$${amount.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar for desktop
          if (MediaQuery.of(context).size.width >= 600)
            AdminSidebar(selectedIndex: _selectedIndex, onItemSelected: _handleIndexTap),
          // Main content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorView()
                    : _buildBody(),
          ),
        ],
      ),
      appBar: AdminAppBar(
        onMenuToggle: () {
          // Toggle sidebar visibility on mobile
          setState(() {});
        },
        onLogout: () {
          // Navigate to login
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/admin/login', (route) => false);
        },
      ),
      drawer: MediaQuery.of(context).size.width < 600
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(color: AdminColors.ink),
                    child: Text(
                      'Admin Panel',
                      style:
                          TextStyle(color: AdminColors.paper, fontSize: 24),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.dashboard),
                    title: const Text('Dashboard'),
                    onTap: () => setState(() => _selectedIndex = 0),
                  ),
                  ListTile(
                    leading: const Icon(Icons.inventory),
                    title: const Text('Products'),
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                  ListTile(
                    leading: const Icon(Icons.category),
                    title: const Text('Categories'),
                    onTap: () => setState(() => _selectedIndex = 2),
                  ),
                  ListTile(
                    leading: const Icon(Icons.shopping_bag),
                    title: const Text('Orders'),
                    onTap: () => setState(() => _selectedIndex = 3),
                  ),
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text('Customers'),
                    onTap: () => setState(() => _selectedIndex = 4),
                  ),
                  ListTile(
                    leading: const Icon(Icons.bar_chart),
                    title: const Text('Reports'),
                    onTap: () => setState(() => _selectedIndex = 5),
                  ),
                  ListTile(
                    leading: const Icon(Icons.web_asset),
                    title: const Text('Site'),
                    onTap: () => setState(() => _selectedIndex = 6),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: AdminColors.danger),
                    title: const Text('Logout',
                        style: TextStyle(color: AdminColors.danger)),
                    onTap: () async {
                      await Navigator.of(context)
                          .pushNamedAndRemoveUntil(
                              '/admin/login', (route) => false);
                    },
                  ),
                ],
              ),
            )
          : null,
      bottomNavigationBar: MediaQuery.of(context).size.width < 600
          ? BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.inventory), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.category), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.people), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.web_asset), label: ''),
              ],
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              type: BottomNavigationBarType.fixed,
            )
          : null,
    );
  }

  // Handle sidebar index tap
  void _handleIndexTap(int index) {
    setState(() => _selectedIndex = index);
  }

  // Tab body dispatcher
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 1:
        return const AdminProductsPage();
      case 2:
        return const AdminCategoriesPage();
      case 3:
        return const AdminOrdersPage();
      case 4:
        return const AdminCustomersPage();
      case 5:
        return const AdminReportsPage();
      case 6:
        return const AdminSitePage();
      case 0:
      default:
        return _buildDashboard();
    }
  }

  // Error view with Retry (e.g. when the database rules are not published)
  Widget _buildErrorView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 48,
              color: AdminColors.danger,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load the admin dashboard',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AdminColors.ink,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _error ?? 'Unknown error.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AdminColors.muted, height: 1.4),
            ),
            const SizedBox(height: 12),
            const Text(
              'Make sure the Realtime Database Rules (database.rules.json) '
              'were published to the Firebase Console, and that you are '
              'signed in with the account whose UID is set as adminUid.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AdminColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: () async {
                    await AdminAuthService().signOut();
                    if (!mounted) return;
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/admin/login',
                      (route) => false,
                    );
                  },
                  child: const Text('SIGN OUT'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _error = null;
                      _isLoading = true;
                    });
                    _checkAdminAccess();
                  },
                  child: const Text('RETRY'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Dashboard screen body (tab 0)
  Widget _buildDashboard() {
    final avgOrderValue = _totalOrders > 0
        ? _totalSales / _totalOrders
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary stats row
          Row(
            children: [
              Expanded(
                child: DashboardCard(
                  title: 'Total Products',
                  value: _totalProducts.toString(),
                  iconData: Icons.inventory,
                  color: AdminColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DashboardCard(
                  title: 'Total Orders',
                  value: _totalOrders.toString(),
                  iconData: Icons.shopping_bag,
                  color: AdminColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DashboardCard(
                  title: 'Total Customers',
                  value: _totalCustomers.toString(),
                  iconData: Icons.people,
                  color: AdminColors.muted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DashboardCard(
                  title: 'Total Sales',
                  value: _formatCurrency(_totalSales),
                  iconData: Icons.money,
                  color: AdminColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DashboardCard(
                  title: 'Pending Orders',
                  value: _pendingOrders.toString(),
                  iconData: Icons.hourglass_empty,
                  color: AdminColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DashboardCard(
                  title: 'Completed Orders',
                  value: _completedOrders.toString(),
                  iconData: Icons.check_circle,
                  color: AdminColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DashboardCard(
                  title: 'Avg Order Value',
                  value: _formatCurrency(avgOrderValue),
                  iconData: Icons.trending_up,
                  color: AdminColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DashboardCard(
                  title: 'Low Stock Items',
                  value: _lowStockProducts.length.toString(),
                  iconData: Icons.warning,
                  color: AdminColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Recent orders section
          const Text(
            'Recent Orders',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AdminColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          _recentOrders.isEmpty
              ? const Text('No orders yet.')
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _recentOrders.length,
                  itemBuilder: (context, index) {
                    final order = _recentOrders[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AdminColors.line,
                        child: Text(
                          order.orderNumber
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(color: AdminColors.paper),
                        ),
                      ),
                      title: Text(order.customerName),
                      subtitle: Text(
                        '\$${order.subtotal.toStringAsFixed(0)} - ${order.statusLabel}',
                        style: TextStyle(color: AdminColors.muted),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: order.statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: order.statusColor, width: 1),
                        ),
                        child: Text(
                          order.statusLabel,
                          style: TextStyle(
                            color: order.statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      onTap: () {
                        // Navigate to order details
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Order details coming soon. Tap to view.')),
                        );
                      },
                    );
                  },
                ),
          const SizedBox(height: 24),
          // Best selling products section
          const Text(
            'Top Customers',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AdminColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          _topCustomers.isEmpty
              ? const Text('No product data yet.')
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _topCustomers.length,
                  itemBuilder: (context, index) {
                    final customer = _topCustomers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AdminColors.line,
                        child: Text(
                          customer.fullName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: AdminColors.paper),
                        ),
                      ),
                      title: Text(customer.fullName),
                      subtitle: Text(
                        'Orders: 5+',
                        style: TextStyle(color: AdminColors.muted),
                      ),
                      trailing: Text(
                        _formatCurrency(double.parse(_totalSales.toStringAsFixed(0))),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}