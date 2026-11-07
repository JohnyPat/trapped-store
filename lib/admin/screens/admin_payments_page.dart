import 'package:flutter/material.dart';

import 'package:trapped_store/shared/constants/admin_constants.dart';
import 'package:trapped_store/models/payment.dart';
import 'package:trapped_store/utils/app_snack.dart';
import 'package:trapped_store/admin/widgets/admin_appbar.dart';
import 'package:trapped_store/admin/widgets/admin_breakpoints.dart';
import 'package:trapped_store/admin/widgets/admin_page_container.dart';
import 'package:trapped_store/admin/widgets/admin_section_card.dart';
import 'package:trapped_store/admin/widgets/admin_stat_card.dart';
import 'package:trapped_store/admin/widgets/dashboard_card.dart';
import 'package:trapped_store/admin/services/admin_auth_service.dart';

class AdminPaymentsPage extends StatefulWidget {
  const AdminPaymentsPage({super.key});

  @override
  State<AdminPaymentsPage> createState() => _AdminPaymentsPageState();
}

class _AdminPaymentsPageState extends State<AdminPaymentsPage> {
  String? _selectedStatus;
  String? _selectedMethod;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoading = true);
    try {
      // Admin can see all payments — in this demo build we just finish loading.
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      AppSnack.error(context, 'Failed to load payments: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (AdminBreakpoints.isDesktop(context)) {
      return _buildDesktop();
    }
    return _buildMobile();
  }

  // ── Mobile (unchanged layout) ───────────────────────────────────────

  Widget _buildMobile() {
    return Scaffold(
      appBar: AdminAppBar(
        onMenuToggle: () {},
        onLogout: () async {
          await AdminAuthService().signOut();
          if (!mounted) return;
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/admin/login', (route) => false);
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PAYMENTS REPORT',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.ink,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSummaryStats(),
                  const SizedBox(height: 24),
                  _buildFilters(),
                  const SizedBox(height: 24),
                  _buildPaymentsList(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryStats() {
    return Row(
      children: [
        Expanded(
          child: DashboardCard(
            title: 'Total Payments',
            value: '0',
            iconData: Icons.payment,
            color: AdminColors.accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DashboardCard(
            title: 'Successful',
            value: '0',
            iconData: Icons.check_circle,
            color: AdminColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.paper,
        border: Border.all(color: AdminColors.line),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AdminColors.ink,
            ),
          ),
          const SizedBox(height: 16),
          _buildFilterChip(
            label: 'All Methods',
            isSelected: _selectedMethod == null,
            onSelected: (selected) {
              setState(() {
                _selectedMethod = selected ? null : 'all';
              });
            },
          ),
          const SizedBox(height: 8),
          _buildFilterChip(
            label: 'GCash',
            isSelected: _selectedMethod == 'gcash',
            onSelected: (selected) {
              setState(() => _selectedMethod = selected ? 'gcash' : null);
            },
          ),
          const SizedBox(height: 8),
          _buildFilterChip(
            label: 'Maya',
            isSelected: _selectedMethod == 'maya',
            onSelected: (selected) {
              setState(() => _selectedMethod = selected ? 'maya' : null);
            },
          ),
          const SizedBox(height: 8),
          _buildFilterChip(
            label: 'Card',
            isSelected: _selectedMethod == 'card',
            onSelected: (selected) {
              setState(() => _selectedMethod = selected ? 'card' : null);
            },
          ),
          const SizedBox(height: 8),
          _buildFilterChip(
            label: 'COD',
            isSelected: _selectedMethod == 'cod',
            onSelected: (selected) {
              setState(() => _selectedMethod = selected ? 'cod' : null);
            },
          ),
          const SizedBox(height: 8),
          const Text(
            'Status:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AdminColors.muted,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: PaymentStatus.values.map((status) {
              return FilterChip(
                label: Text(status.label),
                selected: _selectedStatus == status.value,
                onSelected: (selected) {
                  setState(
                    () => _selectedStatus = selected ? status.value : null,
                  );
                },
                backgroundColor: AdminColors.paper,
                selectedColor: AdminColors.accent,
                checkmarkColor: AdminColors.ink,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: AdminColors.paper,
      selectedColor: AdminColors.accent,
      checkmarkColor: AdminColors.ink,
    );
  }

  Widget _buildPaymentsList() {
    return const Center(
      child: Text('Payment list will appear here after Firebase setup'),
    );
  }

  // ── Desktop layout ──────────────────────────────────────────────────

  Widget _buildDesktop() {
    return Scaffold(
      backgroundColor: AdminColors.canvas,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : AdminPageContainer(
              scrollable: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AdminPageHeader(
                    title: 'Payments',
                    subtitle: 'Review payment methods and settlement status across orders.',
                    actions: OutlinedButton.icon(
                      onPressed: _loadPayments,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Refresh'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AdminColors.ink,
                        side: const BorderSide(color: AdminColors.line),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 132,
                          child: AdminStatCard(
                            title: 'Total Payments',
                            value: '0',
                            iconData: Icons.payment,
                            color: AdminColors.accent,
                            hint: 'Payments recorded across all orders',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 132,
                          child: AdminStatCard(
                            title: 'Successful',
                            value: '0',
                            iconData: Icons.check_circle_outline,
                            color: AdminColors.success,
                            hint: 'Payments confirmed by the provider',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AdminSectionCard(
                    title: 'Filters',
                    subtitle: 'Narrow the payment list by method or status.',
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'PAYMENT METHOD',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: AdminColors.muted,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildFilterChip(
                                    label: 'All Methods',
                                    isSelected: _selectedMethod == null,
                                    onSelected: (selected) {
                                      setState(() {
                                        _selectedMethod = selected
                                            ? null
                                            : 'all';
                                      });
                                    },
                                  ),
                                  _buildFilterChip(
                                    label: 'GCash',
                                    isSelected: _selectedMethod == 'gcash',
                                    onSelected: (selected) {
                                      setState(
                                        () => _selectedMethod = selected
                                            ? 'gcash'
                                            : null,
                                      );
                                    },
                                  ),
                                  _buildFilterChip(
                                    label: 'Maya',
                                    isSelected: _selectedMethod == 'maya',
                                    onSelected: (selected) {
                                      setState(
                                        () => _selectedMethod = selected
                                            ? 'maya'
                                            : null,
                                      );
                                    },
                                  ),
                                  _buildFilterChip(
                                    label: 'Card',
                                    isSelected: _selectedMethod == 'card',
                                    onSelected: (selected) {
                                      setState(
                                        () => _selectedMethod = selected
                                            ? 'card'
                                            : null,
                                      );
                                    },
                                  ),
                                  _buildFilterChip(
                                    label: 'COD',
                                    isSelected: _selectedMethod == 'cod',
                                    onSelected: (selected) {
                                      setState(
                                        () => _selectedMethod = selected
                                            ? 'cod'
                                            : null,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 32),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'PAYMENT STATUS',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: AdminColors.muted,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: PaymentStatus.values.map((status) {
                                  return FilterChip(
                                    label: Text(status.label),
                                    selected: _selectedStatus == status.value,
                                    onSelected: (selected) {
                                      setState(
                                        () => _selectedStatus = selected
                                            ? status.value
                                            : null,
                                      );
                                    },
                                    backgroundColor: AdminColors.paper,
                                    selectedColor: AdminColors.accent,
                                    checkmarkColor: AdminColors.ink,
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AdminSectionCard(
                    title: 'Payment records',
                    subtitle:
                        'Payment list will appear here after Firebase setup.',
                    child: const SizedBox(
                      height: 140,
                      child: Center(
                        child: Text(
                          'Payment list will appear here after Firebase setup',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AdminColors.muted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
