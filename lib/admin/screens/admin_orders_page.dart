import 'package:flutter/material.dart';
import 'package:trapped_store/shared/constants/admin_constants.dart';

import '../models/admin_order_model.dart';
import '../services/admin_order_service.dart';

const _statusFilters = <String>[
  'all',
  'pending',
  'confirmed',
  'processing',
  'shipped',
  'delivered',
  'cancelled',
];

const _statusLabels = {
  'all': 'All',
  'pending': 'Pending',
  'confirmed': 'Confirmed',
  'processing': 'Processing',
  'shipped': 'Shipped',
  'delivered': 'Delivered',
  'cancelled': 'Cancelled',
};

/// Admin orders management: view all orders and update their statuses.
class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  final _orderService = AdminOrderService();
  String _filter = 'all';
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
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

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays >= 30) return '${diff.inDays ~/ 30}mo ago';
    if (diff.inDays >= 7) return '${diff.inDays ~/ 7}w ago';
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'just now';
  }

  Future<void> _updateStatus(AdminOrder order, String status) async {
    try {
      await _orderService.updateOrderStatus(
        uid: order.userId,
        orderId: order.id,
        newStatus: status,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order marked as ${_statusLabels[status] ?? status}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update order: $e')),
      );
    }
  }

  Future<void> _confirmStatusChange(
      AdminOrder order, String newStatus) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update order status?'),
        content: Text(
          'Change ${order.orderNumber} to ${_statusLabels[newStatus]}? '
          'The customer will see the new status.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('UPDATE'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _updateStatus(order, newStatus);
  }

  void _openOrderDetails(AdminOrder order) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AdminColors.paper,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.orderNumber,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AdminColors.ink,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _statusColor(order.orderStatus),
                      ),
                      child: Text(
                        order.statusLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _timeAgo(order.createdAt),
                  style: const TextStyle(color: AdminColors.muted),
                ),
                const Divider(height: 24),
                const Text('CUSTOMER',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.5,
                      color: AdminColors.muted,
                    )),
                const SizedBox(height: 4),
                Text(order.customerName.isNotEmpty
                    ? order.customerName
                    : 'Unknown customer'),
                if (order.customerEmail.isNotEmpty)
                  Text(order.customerEmail,
                      style: const TextStyle(color: AdminColors.muted)),
                const SizedBox(height: 16),
                const Text('ITEMS',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.5,
                      color: AdminColors.muted,
                    )),
                const SizedBox(height: 8),
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.checkroom,
                            size: 18, color: AdminColors.muted),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name),
                              Text('SIZE ${item.size ?? '—'} · QTY ${item.quantity}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AdminColors.muted)),
                            ],
                          ),
                        ),
                        Text('\$${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 24),
                _summaryRow('Subtotal',
                    '\$${order.subtotal.toStringAsFixed(2)}'),
                _summaryRow('Shipping',
                    order.shippingFee == 0
                        ? 'FREE'
                        : '\$${order.shippingFee.toStringAsFixed(2)}'),
                _summaryRow('TOTAL',
                    '\$${order.totalAmount.toStringAsFixed(2)}',
                    bold: true),
                const SizedBox(height: 16),
                _summaryRow('Payment method',
                    _paymentMethodLabel(order.paymentMethod)),
                _summaryRow('Payment status',
                    order.paymentStatus.replaceAll('_', ' ').toUpperCase()),
                const SizedBox(height: 16),
                const Text('UPDATE STATUS',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.5,
                      color: AdminColors.muted,
                    )),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final status in _statusFilters)
                      if (status != 'all')
                        ActionChip(
                          label: Text(_statusLabels[status] ?? status),
                          backgroundColor: order.orderStatus.toLowerCase() ==
                                  status
                              ? _statusColor(status)
                              : AdminColors.canvas,
                          labelStyle: TextStyle(
                            color: order.orderStatus.toLowerCase() == status
                                ? Colors.white
                                : AdminColors.ink,
                            fontWeight: FontWeight.w600,
                          ),
                          onPressed: () => _confirmStatusChange(order, status),
                        ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _paymentMethodLabel(String method) {
    switch (method.toLowerCase()) {
      case 'cod':
        return 'Cash on Delivery';
      case 'gcash':
        return 'GCash (SIM)';
      case 'maya':
        return 'Maya (SIM)';
      case 'card':
        return 'Card (SIM)';
      default:
        return method.toUpperCase();
    }
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AdminColors.muted,
                fontSize: bold ? 14 : 12,
                fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AdminColors.ink,
              fontSize: bold ? 16 : 12,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            ),
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
            child: Text(
              'Orders',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AdminColors.ink,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search order number or customer...',
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
          // Status filter chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                for (final status in _statusFilters)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_statusLabels[status] ?? status),
                      selected: _filter == status,
                      selectedColor: AdminColors.ink,
                      backgroundColor: AdminColors.canvas,
                      labelStyle: TextStyle(
                        color: _filter == status
                            ? AdminColors.paper
                            : AdminColors.ink,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) => setState(() => _filter = status),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<AdminOrder>>(
              stream: _orderService.watchAllOrders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Failed to load orders: ${snapshot.error}'),
                  );
                }
                var orders = snapshot.data ?? <AdminOrder>[];
                if (_filter != 'all') {
                  orders = orders
                      .where((o) =>
                          o.orderStatus.toLowerCase() == _filter)
                      .toList();
                }
                if (_query.isNotEmpty) {
                  orders = orders.where((o) {
                    return o.orderNumber.toLowerCase().contains(_query) ||
                        o.customerName.toLowerCase().contains(_query);
                  }).toList();
                }
                if (orders.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No orders found.'),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      color: AdminColors.paper,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      child: ListTile(
                        title: Text(order.orderNumber,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700)),
                        subtitle: Text(
                          '${order.customerName.isNotEmpty ? order.customerName : 'Unknown'}'
                          '\n\$${order.totalAmount.toStringAsFixed(2)}'
                          ' · ${_timeAgo(order.createdAt)}',
                        ),
                        isThreeLine: true,
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _statusColor(order.orderStatus),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                order.statusLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Icon(Icons.chevron_right,
                                size: 18, color: AdminColors.muted),
                          ],
                        ),
                        onTap: () => _openOrderDetails(order),
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