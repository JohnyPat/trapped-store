import 'package:flutter/material.dart';

import 'package:trapped_store/shared/constants/admin_constants.dart';

import '../models/admin_customer_model.dart';
import '../services/admin_customer_service.dart';
import '../services/admin_order_service.dart';

/// Admin customers management: search customers and view their profiles.
class AdminCustomersPage extends StatefulWidget {
  const AdminCustomersPage({super.key});

  @override
  State<AdminCustomersPage> createState() => _AdminCustomersPageState();
}

class _AdminCustomersPageState extends State<AdminCustomersPage> {
  final _customerService = AdminCustomerService();
  final _orderService = AdminOrderService();
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _filter = 'all';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Color _statusColor(String status) =>
      status.toLowerCase() == 'active' ? AdminColors.success : AdminColors.warning;

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays >= 30) return '${diff.inDays ~/ 30}mo ago';
    if (diff.inDays >= 7) return '${diff.inDays ~/ 7}w ago';
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return 'just now';
  }

  Future<void> _toggleCustomerStatus(AdminCustomer customer) async {
    final newStatus =
        customer.status.toLowerCase() == 'active' ? 'disabled' : 'active';
    try {
      await _customerService.updateCustomerStatus(
        uid: customer.uid,
        status: newStatus,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newStatus == 'active'
              ? 'Customer enabled.'
              : 'Customer disabled.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update customer: $e')),
      );
    }
  }

  Future<void> _openCustomerDetails(AdminCustomer customer) async {
    // Count this customer's orders (best effort)
    int? orderCount;
    try {
      final orders = await _orderService.watchUserOrders(customer.uid).first;
      orderCount = orders.length;
    } catch (_) {
      // not fatal
    }

    if (!mounted) return;
    final isActive = customer.status.toLowerCase() == 'active';
    final initials = customer.fullName.trim().isEmpty
        ? '?'
        : customer.fullName.trim().substring(0, 1).toUpperCase();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AdminColors.canvas,
              child: Text(
                initials,
                style: const TextStyle(
                  color: AdminColors.ink,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                customer.fullName.isNotEmpty
                    ? customer.fullName
                    : 'Unnamed customer',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Email', customer.email),
            _detailRow('Phone', customer.phone),
            if (customer.address != null &&
                customer.address!.trim().isNotEmpty)
              _detailRow('Address', customer.address!),
            _detailRow(
              'Orders',
              orderCount == null ? 'Unknown' : orderCount.toString(),
            ),
            _detailRow('Status', customer.status.toUpperCase()),
            _detailRow('Joined',
                customer.createdAt.toString().split(' ').first),
            const SizedBox(height: 8),
            Text(
              'Toggling status disables or enables this customer account.',
              style: TextStyle(
                  fontSize: 11, color: AdminColors.muted, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CLOSE'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _toggleCustomerStatus(customer);
            },
            style: FilledButton.styleFrom(
              backgroundColor:
                  isActive ? AdminColors.warning : AdminColors.success,
              foregroundColor: Colors.white,
            ),
            child: Text(isActive ? 'DISABLE' : 'ENABLE'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: AdminColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(value.isEmpty ? '—' : value,
                style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                const Text(
                  'Customers',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.ink,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search name or email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
              onChanged: (v) =>
                  setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
          // Filter chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                for (final (value, label) in const [
                  ('all', 'All'),
                  ('active', 'Active'),
                  ('disabled', 'Disabled'),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: _filter == value,
                      selectedColor: AdminColors.ink,
                      backgroundColor: AdminColors.canvas,
                      labelStyle: TextStyle(
                        color: _filter == value
                            ? AdminColors.paper
                            : AdminColors.ink,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) => setState(() => _filter = value),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<AdminCustomer>>(
              stream: _customerService.watchAllCustomers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Failed to load customers: ${snapshot.error}'),
                  );
                }
                var customers = snapshot.data ?? <AdminCustomer>[];
                if (_filter != 'all') {
                  customers = customers
                      .where((c) =>
                          c.status.toLowerCase() == _filter)
                      .toList();
                }
                if (_query.isNotEmpty) {
                  customers = customers.where((c) {
                    return c.fullName.toLowerCase().contains(_query) ||
                        c.email.toLowerCase().contains(_query) ||
                        c.phone.contains(_query);
                  }).toList();
                }
                if (customers.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No customers found.'),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    final initials = customer.fullName.trim().isEmpty
                        ? '?'
                        : customer.fullName
                            .trim()
                            .substring(0, 1)
                            .toUpperCase();
                    return Card(
                      color: AdminColors.paper,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              _statusColor(customer.status).withValues(alpha: 0.15),
                          child: Text(
                            initials,
                            style: TextStyle(
                              color: _statusColor(customer.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          customer.fullName.isNotEmpty
                              ? customer.fullName
                              : 'Unnamed customer',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${customer.email}\nJoined ${_timeAgo(customer.createdAt)}',
                        ),
                        isThreeLine: true,
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: _statusColor(customer.status)
                                .withValues(alpha: 0.15),
                          ),
                          child: Text(
                            customer.status.toUpperCase(),
                            style: TextStyle(
                              color: _statusColor(customer.status),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        onTap: () => _openCustomerDetails(customer),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}