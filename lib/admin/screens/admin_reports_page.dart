import 'package:flutter/material.dart';

import 'package:trapped_store/shared/constants/admin_constants.dart';
import 'package:trapped_store/utils/formatters.dart';

import '../models/admin_order_model.dart';
import '../services/admin_order_service.dart';

/// Admin reports dashboard: sales overview, revenue split, top products.
class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  final _orderService = AdminOrderService();

  String _formatCurrency(double v) => Formatters.currency(v);

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return AdminColors.success;
      case 'shipped':
        return AdminColors.accent;
      case 'confirmed':
      case 'processing':
        return const Color(0xFF3B82F6);
      case 'pending':
        return AdminColors.warning;
      case 'cancelled':
        return AdminColors.danger;
      default:
        return AdminColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<AdminOrder>>(
        stream: _orderService.watchAllOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Failed to load reports. Make sure the Firebase rules were published.\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final orders = snapshot.data ?? <AdminOrder>[];
          var itemQty = <String, int>{};
          var statusCount = <String, int>{};
          var methodCount = <String, int>{};
          var methodRevenue = <String, double>{};
          var deliveredRevenue = 0.0;
          var totalRevenue = 0.0;
          var deliveredCount = 0;
          var cancelledCount = 0;

          for (final o in orders) {
            final status = o.orderStatus.toLowerCase();
            statusCount[status] = (statusCount[status] ?? 0) + 1;
            methodCount[o.paymentMethod.toLowerCase()] =
                (methodCount[o.paymentMethod.toLowerCase()] ?? 0) + 1;
            methodRevenue[o.paymentMethod.toLowerCase()] =
                (methodRevenue[o.paymentMethod.toLowerCase()] ?? 0.0) +
                    o.totalAmount;
            totalRevenue += o.totalAmount;
            if (status == 'delivered') {
              deliveredRevenue += o.totalAmount;
              deliveredCount += 1;
            } else if (status == 'cancelled') {
              cancelledCount += 1;
            }
            for (final item in o.items) {
              itemQty[item.name] = (itemQty[item.name] ?? 0) + item.quantity;
            }
          }
          final sortedSold = itemQty.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final sortedStatus = statusCount.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Reports',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Overall performance across all store orders.',
                  style: TextStyle(color: AdminColors.muted),
                ),
                const SizedBox(height: 20),
                // Headline metrics
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.35,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _metricCard(
                      'TOTAL ORDERS',
                      orders.length.toString(),
                      Icons.receipt_long,
                      AdminColors.ink,
                    ),
                    _metricCard(
                      'PAID / DELIVERED SALES',
                      _formatCurrency(deliveredRevenue),
                      Icons.payments,
                      AdminColors.success,
                    ),
                    _metricCard(
                      'ACTIVE ORDERS',
                      (orders.length - deliveredCount - cancelledCount).toString(),
                      Icons.pending_actions,
                      AdminColors.accent,
                    ),
                    _metricCard(
                      'CANCELLED',
                      cancelledCount.toString(),
                      Icons.cancel_outlined,
                      AdminColors.danger,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Order breakdown by status
                const Text(
                  'ORDERS BY STATUS',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.6,
                    color: AdminColors.muted,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: AdminColors.paper,
                    border: Border.all(color: AdminColors.line),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: sortedStatus.map((entry) {
                      final percent = orders.isEmpty
                          ? 0.0
                          : entry.value / orders.length;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 90,
                              child: Text(
                                entry.key.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: AdminColors.ink,
                                ),
                              ),
                            ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: percent,
                                  minHeight: 10,
                                  backgroundColor: AdminColors.canvas,
                                  color: _statusColor(entry.key),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${entry.value}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AdminColors.ink,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Top-selling products (by quantity ordered)
                const Text(
                  'TOP SELLING PRODUCTS',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.6,
                    color: AdminColors.muted,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: AdminColors.paper,
                    border: Border.all(color: AdminColors.line),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: sortedSold.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No sales data yet.',
                              style: TextStyle(color: AdminColors.muted)),
                        )
                      : Column(
                          children: List.generate(
                            sortedSold.length.clamp(0, 8),
                            (index) {
                              final name = sortedSold[index].key;
                              final qty = sortedSold[index].value;
                              final total = sortedSold
                                  .map((e) => e.value)
                                  .fold<int>(0, (a, b) => a + b);
                              final fraction =
                                  total == 0 ? 0.0 : qty / total;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 9),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 22,
                                      child: Text(
                                        '#${index + 1}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: AdminColors.muted,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: AdminColors.ink,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(2),
                                            child: LinearProgressIndicator(
                                              value: fraction,
                                              minHeight: 6,
                                              backgroundColor:
                                                  AdminColors.canvas,
                                              color: AdminColors.ink,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'x$qty',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AdminColors.ink,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ),
                const SizedBox(height: 24),

                // Payment method usage
                const Text(
                  'PAYMENT METHODS',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.6,
                    color: AdminColors.muted,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: AdminColors.paper,
                    border: Border.all(color: AdminColors.line),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      for (final method in ['cod', 'gcash', 'maya', 'card'])
                        if (methodCount[method] != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _methodLabel(method),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: AdminColors.ink,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${methodCount[method]} — ${_formatCurrency(methodRevenue[method] ?? 0)}',
                                  style: const TextStyle(
                                    color: AdminColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      if (methodCount.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No payment data yet.',
                              style: TextStyle(color: AdminColors.muted)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'TOTAL REVENUE (ALL ORDERS)',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.6,
                    color: AdminColors.muted,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatCurrency(totalRevenue),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AdminColors.ink,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _metricCard(
      String label, String value, IconData icon, Color accent) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.paper,
        border: Border.all(color: AdminColors.line),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 20, color: accent),
              const SizedBox.shrink(),
            ],
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w600,
              color: AdminColors.muted,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: AdminColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  String _methodLabel(String method) {
    switch (method) {
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
}