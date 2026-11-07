import 'package:flutter/material.dart';
import 'package:trapped_store/shared/constants/admin_constants.dart';
import 'package:trapped_store/utils/formatters.dart';

import '../models/admin_order_model.dart';
import '../services/admin_order_service.dart';
import '../widgets/admin_breakpoints.dart';
import '../widgets/admin_data_table.dart';
import '../widgets/admin_page_container.dart';

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
        SnackBar(
          content: Text('Order marked as ${_statusLabels[status] ?? status}'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to update order: $e')));
    }
  }

  Future<void> _confirmStatusChange(AdminOrder order, String newStatus) async {
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

  void _openOrderDetails(AdminOrder initialOrder) {
    final orderStream = initialOrder.userId.trim().isEmpty
        ? null
        : _orderService.watchOrder(initialOrder.userId, initialOrder.id);

    if (AdminBreakpoints.isDesktop(context)) {
      showDialog<void>(
        context: context,
        builder: (dialogContext) => Dialog(
          backgroundColor: AdminColors.paper,
          insetPadding: const EdgeInsets.all(32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 720,
              maxHeight: MediaQuery.sizeOf(dialogContext).height * 0.85,
            ),
            child: StreamBuilder<AdminOrder?>(
              stream: orderStream,
              initialData: initialOrder,
              builder: (context, snapshot) {
                final order = snapshot.data ?? initialOrder;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: _buildOrderDetailsContent(
                    order,
                    onClose: () => Navigator.of(dialogContext).pop(),
                  ),
                );
              },
            ),
          ),
        ),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AdminColors.paper,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => StreamBuilder<AdminOrder?>(
          stream: orderStream,
          initialData: initialOrder,
          builder: (context, snapshot) {
            final order = snapshot.data ?? initialOrder;
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: _buildOrderDetailsContent(order),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderDetailsContent(AdminOrder order, {VoidCallback? onClose}) {
    return Column(
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
            if (onClose != null) ...[
              const SizedBox(width: 8),
              Tooltip(
                message: 'Close',
                child: IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close, size: 20),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          _timeAgo(order.createdAt),
          style: const TextStyle(color: AdminColors.muted),
        ),
        const Divider(height: 24),
        const Text(
          'CUSTOMER',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.5,
            color: AdminColors.muted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          order.customerName.isNotEmpty
              ? order.customerName
              : 'Unknown customer',
        ),
        if (order.customerEmail.isNotEmpty)
          Text(
            order.customerEmail,
            style: const TextStyle(color: AdminColors.muted),
          ),
        const SizedBox(height: 16),
        const Text(
          'ITEMS',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.5,
            color: AdminColors.muted,
          ),
        ),
        const SizedBox(height: 8),
        ...order.items.map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.checkroom, size: 18, color: AdminColors.muted),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name),
                      Text(
                        'SIZE ${item.size ?? '—'} · QTY ${item.quantity}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AdminColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  Formatters.currency(item.price),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 24),
        _summaryRow('Subtotal', Formatters.currency(order.subtotal)),
        _summaryRow(
          'Shipping',
          order.shippingFee == 0
              ? 'FREE'
              : Formatters.currency(order.shippingFee),
        ),
        _summaryRow(
          'TOTAL',
          Formatters.currency(order.totalAmount),
          bold: true,
        ),
        const SizedBox(height: 16),
        _summaryRow('Payment method', _paymentMethodLabel(order.paymentMethod)),
        _summaryRow(
          'Payment status',
          order.paymentStatus.replaceAll('_', ' ').toUpperCase(),
        ),
        const SizedBox(height: 16),
        const Text(
          'UPDATE STATUS',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.5,
            color: AdminColors.muted,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final status in _statusFilters)
              if (status != 'all')
                ActionChip(
                  label: Text(_statusLabels[status] ?? status),
                  backgroundColor: order.orderStatus.toLowerCase() == status
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
    final desktop = AdminBreakpoints.isDesktop(context);
    return StreamBuilder<List<AdminOrder>>(
      stream: _orderService.watchAllOrders(),
      builder: (context, snapshot) {
        if (desktop) return _buildDesktop(snapshot);
        return _buildMobile(snapshot);
      },
    );
  }

  // ── Mobile (unchanged layout) ───────────────────────────────────────

  Widget _buildMobile(AsyncSnapshot<List<AdminOrder>> snapshot) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: const Text(
              'Orders',
              style: TextStyle(
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
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
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
          Expanded(child: _buildMobileList(snapshot)),
        ],
      ),
    );
  }

  Widget _buildMobileList(AsyncSnapshot<List<AdminOrder>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Center(child: Text('Failed to load orders: ${snapshot.error}'));
    }
    var orders = snapshot.data ?? <AdminOrder>[];
    if (_filter != 'all') {
      orders = orders
          .where((o) => o.orderStatus.toLowerCase() == _filter)
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
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: ListTile(
            title: Text(
              order.orderNumber,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              '${order.customerName.isNotEmpty ? order.customerName : 'Unknown'}'
              '\n${Formatters.currency(order.totalAmount)}'
              ' · ${_timeAgo(order.createdAt)}',
            ),
            isThreeLine: true,
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
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
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AdminColors.muted,
                ),
              ],
            ),
            onTap: () => _openOrderDetails(order),
          ),
        );
      },
    );
  }

  // ── Desktop data table ──────────────────────────────────────────────

  Widget _buildDesktop(AsyncSnapshot<List<AdminOrder>> snapshot) {
    var orders = snapshot.data ?? <AdminOrder>[];
    if (_filter != 'all') {
      orders = orders
          .where((o) => o.orderStatus.toLowerCase() == _filter)
          .toList();
    }

    return Scaffold(
      backgroundColor: AdminColors.canvas,
      body: AdminPageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminPageHeader(
              title: 'Orders',
              subtitle: 'Monitor every order and keep customers updated on its status.',
              actions: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AdminColors.paper,
                  border: Border.all(color: AdminColors.line),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.receipt_long_outlined,
                      size: 16,
                      color: AdminColors.muted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${orders.length} order${orders.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AdminColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: AdminDataTable<AdminOrder>(
                rows: orders,
                loading: snapshot.connectionState == ConnectionState.waiting,
                error: snapshot.hasError
                    ? 'Failed to load orders: ${snapshot.error}'
                    : null,
                searchText: (o) =>
                    '${o.orderNumber} ${o.customerName} ${o.customerEmail}',
                searchHint: 'Search order number or customer…',
                emptyMessage: 'No orders match this filter.',
                minWidth: 980,
                pageSize: 10,
                initialSortIndex: 0,
                initialSortAscending: false,
                onRowTap: _openOrderDetails,
                filters: [
                  for (final status in _statusFilters)
                    AdminTableFilter(
                      label: _statusLabels[status] ?? status,
                      selected: _filter == status,
                      onTap: () => setState(() => _filter = status),
                    ),
                ],
                columns: [
                  AdminTableColumn<AdminOrder>(
                    label: 'Order',
                    flex: 2,
                    sortValue: (o) => o.createdAt,
                    cell: (o) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          o.orderNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AdminColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _timeAgo(o.createdAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AdminColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AdminTableColumn<AdminOrder>(
                    label: 'Customer',
                    flex: 2,
                    sortValue: (o) => o.customerName,
                    cell: (o) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          o.customerName.isEmpty
                              ? 'Unknown customer'
                              : o.customerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AdminColors.ink,
                          ),
                        ),
                        if (o.customerEmail.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            o.customerEmail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AdminColors.muted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  AdminTableColumn<AdminOrder>(
                    label: 'Items',
                    flex: 1,
                    align: Alignment.centerRight,
                    sortValue: (o) => o.items.fold<int>(
                      0,
                      (sum, item) => sum + item.quantity,
                    ),
                    cell: (o) {
                      final quantity = o.items.fold<int>(
                        0,
                        (sum, item) => sum + item.quantity,
                      );
                      return Text(
                        '$quantity',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AdminColors.muted,
                        ),
                      );
                    },
                  ),
                  AdminTableColumn<AdminOrder>(
                    label: 'Total',
                    flex: 2,
                    align: Alignment.centerRight,
                    sortValue: (o) => o.totalAmount,
                    cell: (o) => Text(
                      Formatters.currency(o.totalAmount),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AdminColors.ink,
                      ),
                    ),
                  ),
                  AdminTableColumn<AdminOrder>(
                    label: 'Payment',
                    flex: 2,
                    sortValue: (o) => o.paymentMethod,
                    cell: (o) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _paymentMethodLabel(o.paymentMethod),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AdminColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          o.paymentStatus.replaceAll('_', ' ').toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                            color: AdminColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AdminTableColumn<AdminOrder>(
                    label: 'Status',
                    flex: 1,
                    sortValue: (o) => o.orderStatus,
                    cell: _statusBadge,
                  ),
                  AdminTableColumn<AdminOrder>(
                    label: 'Actions',
                    width: 96,
                    align: Alignment.centerRight,
                    cell: (o) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Tooltip(
                          message: 'View order',
                          child: IconButton(
                            iconSize: 18,
                            onPressed: () => _openOrderDetails(o),
                            icon: const Icon(
                              Icons.visibility_outlined,
                              color: AdminColors.accent,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          tooltip: 'Update status',
                          iconSize: 18,
                          onSelected: (status) =>
                              _confirmStatusChange(o, status),
                          itemBuilder: (context) => [
                            for (final status in _statusFilters)
                              if (status != 'all' &&
                                  status != o.orderStatus.toLowerCase())
                                PopupMenuItem<String>(
                                  value: status,
                                  child: Text(_statusLabels[status] ?? status),
                                ),
                          ],
                        ),
                      ],
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

  Widget _statusBadge(AdminOrder order) {
    final color = _statusColor(order.orderStatus);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
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
}
