import 'package:flutter/material.dart';

import 'package:trapped_store/shared/constants/admin_constants.dart';
import 'package:trapped_store/utils/formatters.dart';

import '../models/admin_order_model.dart';
import '../services/admin_order_service.dart';
import '../widgets/admin_breakpoints.dart';
import '../widgets/admin_page_container.dart';
import '../widgets/admin_section_card.dart';
import '../widgets/admin_stat_card.dart';

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
      backgroundColor: AdminBreakpoints.isDesktop(context)
          ? AdminColors.canvas
          : null,
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

          if (AdminBreakpoints.isDesktop(context)) {
            return _buildDesktopBody(
              orders: orders,
              sortedStatus: sortedStatus,
              sortedSold: sortedSold,
              methodCount: methodCount,
              methodRevenue: methodRevenue,
              deliveredRevenue: deliveredRevenue,
              totalRevenue: totalRevenue,
              deliveredCount: deliveredCount,
              cancelledCount: cancelledCount,
            );
          }

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
                      (orders.length - deliveredCount - cancelledCount)
                          .toString(),
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
                          horizontal: 14,
                          vertical: 10,
                        ),
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
                          child: Text(
                            'No sales data yet.',
                            style: TextStyle(color: AdminColors.muted),
                          ),
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
                              final fraction = total == 0 ? 0.0 : qty / total;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 9,
                                ),
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
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
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
                              horizontal: 14,
                              vertical: 10,
                            ),
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
                          child: Text(
                            'No payment data yet.',
                            style: TextStyle(color: AdminColors.muted),
                          ),
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

  Widget _buildDesktopBody({
    required List<AdminOrder> orders,
    required List<MapEntry<String, int>> sortedStatus,
    required List<MapEntry<String, int>> sortedSold,
    required Map<String, int> methodCount,
    required Map<String, double> methodRevenue,
    required double deliveredRevenue,
    required double totalRevenue,
    required int deliveredCount,
    required int cancelledCount,
  }) {
    return AdminPageContainer(
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AdminPageHeader(
            title: 'Reports',
            subtitle: 'Overall performance across all store orders.',
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 860 ? 4 : 2;
              const spacing = 16.0;
              final width =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;
              final metrics = <Widget>[
                _desktopMetric(
                  width,
                  'TOTAL ORDERS',
                  orders.length.toString(),
                  Icons.receipt_long,
                  AdminColors.ink,
                  'All orders in the store',
                ),
                _desktopMetric(
                  width,
                  'PAID / DELIVERED SALES',
                  _formatCurrency(deliveredRevenue),
                  Icons.payments,
                  AdminColors.success,
                  'Revenue from delivered orders',
                ),
                _desktopMetric(
                  width,
                  'ACTIVE ORDERS',
                  (orders.length - deliveredCount - cancelledCount).toString(),
                  Icons.pending_actions,
                  AdminColors.accent,
                  'Orders still in progress',
                ),
                _desktopMetric(
                  width,
                  'CANCELLED',
                  cancelledCount.toString(),
                  Icons.cancel_outlined,
                  AdminColors.danger,
                  'Orders cancelled by customers or admin',
                ),
              ];
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: metrics,
              );
            },
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final sideBySide = constraints.maxWidth >= 900;
              final statusCard = AdminSectionCard(
                title: 'Orders by status',
                subtitle: 'Distribution of order states',
                child: _statusBreakdown(sortedStatus, orders.length),
              );
              final productsCard = AdminSectionCard(
                title: 'Top selling products',
                subtitle: 'By quantity ordered',
                child: _topProducts(sortedSold),
              );
              if (!sideBySide) {
                return Column(
                  children: [
                    statusCard,
                    const SizedBox(height: 16),
                    productsCard,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: statusCard),
                  const SizedBox(width: 24),
                  Expanded(child: productsCard),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final sideBySide = constraints.maxWidth >= 900;
              final methodsCard = AdminSectionCard(
                title: 'Payment methods',
                subtitle: 'Usage and revenue per method',
                child: _paymentMethods(methodCount, methodRevenue),
              );
              final revenueCard = AdminSectionCard(
                title: 'Total revenue',
                subtitle: 'All orders, including active and cancelled',
                child: _revenueSummary(totalRevenue),
              );
              if (!sideBySide) {
                return Column(
                  children: [
                    methodsCard,
                    const SizedBox(height: 16),
                    revenueCard,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: methodsCard),
                  const SizedBox(width: 24),
                  Expanded(child: revenueCard),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _desktopMetric(
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

  Widget _statusBreakdown(
    List<MapEntry<String, int>> entries,
    int totalOrders,
  ) {
    if (entries.isEmpty) {
      return const Text(
        'No orders yet.',
        style: TextStyle(fontSize: 13, color: AdminColors.muted),
      );
    }
    return Column(
      children: [
        for (final entry in entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(
                    entry.key.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: AdminColors.ink,
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: totalOrders == 0 ? 0 : entry.value / totalOrders,
                      minHeight: 9,
                      backgroundColor: AdminColors.canvas,
                      color: _statusColor(entry.key),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 28,
                  child: Text(
                    '${entry.value}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AdminColors.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _topProducts(List<MapEntry<String, int>> sortedSold) {
    if (sortedSold.isEmpty) {
      return const Text(
        'No sales data yet.',
        style: TextStyle(fontSize: 13, color: AdminColors.muted),
      );
    }
    final total = sortedSold.fold<int>(0, (sum, entry) => sum + entry.value);
    return Column(
      children: [
        for (var i = 0; i < sortedSold.length.clamp(0, 8); i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                SizedBox(
                  width: 26,
                  child: Text(
                    '#${i + 1}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AdminColors.muted,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sortedSold[i].key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AdminColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: total == 0 ? 0 : sortedSold[i].value / total,
                          minHeight: 6,
                          backgroundColor: AdminColors.canvas,
                          color: AdminColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'x${sortedSold[i].value}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AdminColors.ink,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _paymentMethods(Map<String, int> counts, Map<String, double> revenue) {
    final methods = [
      'cod',
      'gcash',
      'maya',
      'card',
    ].where((method) => counts[method] != null).toList();
    if (methods.isEmpty) {
      return const Text(
        'No payment data yet.',
        style: TextStyle(fontSize: 13, color: AdminColors.muted),
      );
    }
    return Column(
      children: [
        for (final method in methods)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _methodLabel(method),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AdminColors.ink,
                    ),
                  ),
                ),
                Text(
                  '${counts[method]} orders',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AdminColors.muted,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  _formatCurrency(revenue[method] ?? 0),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AdminColors.ink,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _revenueSummary(double totalRevenue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _formatCurrency(totalRevenue),
          style: const TextStyle(
            fontSize: 32,
            height: 1.1,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            color: AdminColors.ink,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Across every order recorded in the store.',
          style: TextStyle(fontSize: 12, color: AdminColors.muted),
        ),
      ],
    );
  }

  Widget _metricCard(String label, String value, IconData icon, Color accent) {
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
