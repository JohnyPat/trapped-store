import 'package:flutter/material.dart';

import 'package:trapped_store/shared/constants/admin_constants.dart';
import 'package:trapped_store/models/payment.dart';
import 'package:trapped_store/utils/app_snack.dart';
import 'package:trapped_store/admin/widgets/admin_appbar.dart';
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
    return Scaffold(
      appBar: AdminAppBar(
        onMenuToggle: () {},
        onLogout: () async {
          await AdminAuthService().signOut();
          if (!context.mounted) return;
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/admin/login',
            (route) => false,
          );
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

                  // Summary stats
                  _buildSummaryStats(),
                  const SizedBox(height: 24),

                  // Filters
                  _buildFilters(),
                  const SizedBox(height: 24),

                  // Payments list
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
          // Payment method filter
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
          // Status filter
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
                  setState(() => _selectedStatus = selected ? status.value : null);
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
}