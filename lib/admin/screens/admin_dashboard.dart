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
import '../widgets/admin_breakpoints.dart';
import '../widgets/admin_page_container.dart';
import '../widgets/admin_section_card.dart';
import '../widgets/admin_stat_card.dart';
import '../widgets/admin_top_navbar.dart';
import '../widgets/dashboard_card.dart';

import 'package:trapped_store/shared/constants/admin_constants.dart';
import 'package:trapped_store/utils/formatters.dart';

import 'admin_products_page.dart';
import 'admin_categories_page.dart';
import 'admin_orders_page.dart';
import 'admin_customers_page.dart';
import 'admin_payments_page.dart';
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
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/admin/login', (route) => false);
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
          if (order.orderStatus.toLowerCase() == 'delivered') {
            _completedOrders++;
          }
        }

        // Calculate total sales from delivered orders
        _totalSales = 0.0;
        for (final order in ordersSnap) {
          if (order.orderStatus.toLowerCase() == 'delivered') {
            _totalSales += order.totalAmount;
          }
        }

        // Low stock products
        _lowStockProducts = productsSnap.where((p) => p.isLowStock).toList()
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

  String _formatCurrency(double amount) => Formatters.currency(amount);

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Select an admin section from the mobile drawer and close it.
  void _selectIndex(int index) {
    _scaffoldKey.currentState?.closeDrawer();
    setState(() => _selectedIndex = index);
  }

  static const _sectionTitles = [
    'Dashboard',
    'Products',
    'Categories',
    'Orders',
    'Customers',
    'Payments',
    'Reports',
    'Site',
  ];

  Future<void> _logout() async {
    await AdminAuthService().signOut();
    if (!mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/admin/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = AdminBreakpoints.isDesktop(context);

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AdminColors.canvas,
        body: Row(
          children: [
            AdminSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: _handleIndexTap,
            ),
            Expanded(
              child: Column(
                children: [
                  AdminTopNavbar(
                    title: _sectionTitles[_selectedIndex],
                    onLogout: _logout,
                  ),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                        ? _buildErrorView()
                        : _buildBody(),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorView()
          : _buildBody(),
      appBar: AdminAppBar(
        onMenuToggle: () => _scaffoldKey.currentState?.openDrawer(),
        onLogout: _logout,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AdminColors.ink),
              child: const Text(
                'Admin Panel',
                style: TextStyle(color: AdminColors.paper, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => _selectIndex(0),
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Products'),
              onTap: () => _selectIndex(1),
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Categories'),
              onTap: () => _selectIndex(2),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: const Text('Orders'),
              onTap: () => _selectIndex(3),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Customers'),
              onTap: () => _selectIndex(4),
            ),
            ListTile(
              leading: const Icon(Icons.payments),
              title: const Text('Payments'),
              onTap: () => _selectIndex(5),
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Reports'),
              onTap: () => _selectIndex(6),
            ),
            ListTile(
              leading: const Icon(Icons.web_asset),
              title: const Text('Site'),
              onTap: () => _selectIndex(7),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AdminColors.danger),
              title: const Text(
                'Logout',
                style: TextStyle(color: AdminColors.danger),
              ),
              onTap: _logout,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.payments), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.web_asset), label: ''),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
      ),
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
        return const AdminPaymentsPage();
      case 6:
        return const AdminReportsPage();
      case 7:
        return const AdminSitePage();
      case 0:
      default:
        return AdminBreakpoints.isDesktop(context)
            ? _buildDesktopDashboard()
            : _buildDashboard();
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
            const Icon(Icons.cloud_off, size: 48, color: AdminColors.danger),
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
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/admin/login', (route) => false);
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
    final avgOrderValue = _totalOrders > 0 ? _totalSales / _totalOrders : 0.0;

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
                          order.orderNumber.substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: AdminColors.paper),
                        ),
                      ),
                      title: Text(order.customerName),
                      subtitle: Text(
                        '${Formatters.currency(order.subtotal)} - ${order.statusLabel}',
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
                          border: Border.all(
                            color: order.statusColor,
                            width: 1,
                          ),
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
                        setState(() => _selectedIndex = 3);
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
                        _formatCurrency(
                          double.parse(_totalSales.toStringAsFixed(0)),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  // ── Desktop dashboard ───────────────────────────────────────────────

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays >= 30) return '${diff.inDays ~/ 30}mo ago';
    if (diff.inDays >= 7) return '${diff.inDays ~/ 7}w ago';
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'just now';
  }

  Color _orderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AdminColors.warning;
      case 'confirmed':
      case 'processing':
      case 'shipped':
        return AdminColors.accent;
      case 'delivered':
        return AdminColors.success;
      case 'cancelled':
        return AdminColors.danger;
      default:
        return AdminColors.muted;
    }
  }

  Widget _statusPill(AdminOrder order) {
    final color = _orderStatusColor(order.orderStatus);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        order.statusLabel.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: color,
        ),
      ),
    );
  }

  Widget _buildDesktopDashboard() {
    final avgOrderValue = _totalOrders > 0 ? _totalSales / _totalOrders : 0.0;

    return AdminPageContainer(
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminPageHeader(
            title: 'Dashboard',
            subtitle:
                'A quick overview of store performance and recent activity.',
            actions: FilledButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _checkAdminAccess();
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Refresh'),
              style: FilledButton.styleFrom(
                backgroundColor: AdminColors.ink,
                foregroundColor: AdminColors.paper,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 860 ? 4 : 2;
              const spacing = 16.0;
              final cardWidth =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;
              final stats = <Widget>[
                _statTile(
                  cardWidth,
                  'Total Products',
                  _totalProducts.toString(),
                  Icons.inventory_2_outlined,
                  AdminColors.accent,
                  'Products currently in the catalog',
                ),
                _statTile(
                  cardWidth,
                  'Total Orders',
                  _totalOrders.toString(),
                  Icons.shopping_bag_outlined,
                  AdminColors.success,
                  'All orders placed by customers',
                ),
                _statTile(
                  cardWidth,
                  'Total Customers',
                  _totalCustomers.toString(),
                  Icons.people_outline,
                  AdminColors.muted,
                  'Registered customer accounts',
                ),
                _statTile(
                  cardWidth,
                  'Total Sales',
                  _formatCurrency(_totalSales),
                  Icons.money,
                  AdminColors.accent,
                  'Revenue from delivered orders',
                ),
                _statTile(
                  cardWidth,
                  'Pending Orders',
                  _pendingOrders.toString(),
                  Icons.hourglass_empty,
                  AdminColors.warning,
                  'Orders waiting for confirmation',
                ),
                _statTile(
                  cardWidth,
                  'Completed Orders',
                  _completedOrders.toString(),
                  Icons.check_circle_outline,
                  AdminColors.success,
                  'Orders marked as delivered',
                ),
                _statTile(
                  cardWidth,
                  'Avg Order Value',
                  _formatCurrency(avgOrderValue),
                  Icons.trending_up,
                  AdminColors.accent,
                  'Average value per order',
                ),
                _statTile(
                  cardWidth,
                  'Low Stock Items',
                  _lowStockProducts.length.toString(),
                  Icons.warning_amber_outlined,
                  AdminColors.warning,
                  'Products at or below the low-stock threshold',
                ),
              ];
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: stats,
              );
            },
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final sideBySide = constraints.maxWidth >= 880;
              if (!sideBySide) {
                return Column(
                  children: [
                    SizedBox(height: 360, child: _recentOrdersPanel()),
                    const SizedBox(height: 16),
                    SizedBox(height: 360, child: _topCustomersPanel()),
                    const SizedBox(height: 16),
                    _lowStockPanel(),
                  ],
                );
              }
              return Column(
                children: [
                  SizedBox(
                    height: 380,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 2, child: _recentOrdersPanel()),
                        const SizedBox(width: 16),
                        Expanded(flex: 1, child: _topCustomersPanel()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _lowStockPanel(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _statTile(
    double width,
    String title,
    String value,
    IconData icon,
    Color color,
    String hint,
  ) {
    return SizedBox(
      width: width,
      height: 132,
      child: AdminStatCard(
        title: title,
        value: value,
        iconData: icon,
        color: color,
        hint: hint,
      ),
    );
  }

  Widget _recentOrdersPanel() {
    return AdminSectionCard(
      title: 'Recent orders',
      subtitle: 'Latest activity from the store',
      trailing: TextButton(
        onPressed: () => setState(() => _selectedIndex = 3),
        child: const Text('View all'),
      ),
      fill: true,
      padding: EdgeInsets.zero,
      child: _recentOrders.isEmpty
          ? const Center(
              child: Text(
                'No orders yet.',
                style: TextStyle(color: AdminColors.muted),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: _recentOrders.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: AdminColors.line),
              itemBuilder: (context, index) {
                final order = _recentOrders[index];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() => _selectedIndex = 3),
                    hoverColor: AdminColors.canvas.withValues(alpha: 0.6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 11,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 17,
                            backgroundColor: AdminColors.canvas,
                            child: const Icon(
                              Icons.receipt_long_outlined,
                              size: 17,
                              color: AdminColors.muted,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.customerName.isEmpty
                                      ? 'Unknown customer'
                                      : order.customerName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AdminColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${order.orderNumber} · ${_timeAgo(order.createdAt)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AdminColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _formatCurrency(order.totalAmount),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AdminColors.ink,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _statusPill(order),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _topCustomersPanel() {
    return AdminSectionCard(
      title: 'Customers',
      subtitle: 'Newest registered accounts',
      trailing: TextButton(
        onPressed: () => setState(() => _selectedIndex = 4),
        child: const Text('View all'),
      ),
      fill: true,
      padding: EdgeInsets.zero,
      child: _topCustomers.isEmpty
          ? const Center(
              child: Text(
                'No customers yet.',
                style: TextStyle(color: AdminColors.muted),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: _topCustomers.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: AdminColors.line),
              itemBuilder: (context, index) {
                final customer = _topCustomers[index];
                final initial = customer.fullName.trim().isEmpty
                    ? '?'
                    : customer.fullName.trim().substring(0, 1).toUpperCase();
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() => _selectedIndex = 4),
                    hoverColor: AdminColors.canvas.withValues(alpha: 0.6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 11,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 17,
                            backgroundColor: AdminColors.canvas,
                            child: Text(
                              initial,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AdminColors.ink,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  customer.fullName.isEmpty
                                      ? 'Unnamed customer'
                                      : customer.fullName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AdminColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  customer.email.isEmpty
                                      ? 'No email'
                                      : customer.email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AdminColors.muted,
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
              },
            ),
    );
  }

  Widget _lowStockPanel() {
    return AdminSectionCard(
      title: 'Low stock alerts',
      subtitle: _lowStockProducts.isEmpty
          ? 'Everything is well stocked'
          : '${_lowStockProducts.length} product${_lowStockProducts.length == 1 ? '' : 's'} need attention',
      child: _lowStockProducts.isEmpty
          ? const Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 20,
                  color: AdminColors.success,
                ),
                SizedBox(width: 10),
                Text(
                  'All products are above the low-stock threshold.',
                  style: TextStyle(fontSize: 13, color: AdminColors.muted),
                ),
              ],
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 760 ? 2 : 1;
                const spacing = 12.0;
                final width =
                    (constraints.maxWidth - spacing * (columns - 1)) / columns;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final product in _lowStockProducts.take(6))
                      SizedBox(
                        width: width,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AdminColors.canvas.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(color: AdminColors.line),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.inventory_2_outlined,
                                size: 20,
                                color: AdminColors.warning,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AdminColors.ink,
                                      ),
                                    ),
                                    Text(
                                      '${product.stock} left · ${_formatCurrency(product.price)}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AdminColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AdminColors.warning.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'LOW',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                    color: AdminColors.warning,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }
}
