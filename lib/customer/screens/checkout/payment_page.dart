import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:trapped_store/models/payment.dart';
import 'package:trapped_store/providers/auth_provider.dart';
import 'package:trapped_store/services/payment_service.dart';

import 'payment_processing_page.dart';
import 'payment_result_page.dart';

class PaymentPage extends StatefulWidget {
  final String orderId;
  final double totalAmount;

  const PaymentPage({
    super.key,
    required this.orderId,
    required this.totalAmount,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late String _selectedMethod;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _selectedMethod = 'cod';
  }

  void _selectMethod(String method) {
    setState(() => _selectedMethod = method);
  }

  Future<void> _processPayment() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final paymentMethod = PaymentMethod.values.firstWhere(
        (method) => method.value == _selectedMethod,
        orElse: () => PaymentMethod.cod,
      );

      // Give the context a second to unfocus
      FocusManager.instance.primaryFocus?.unfocus();

      final payment = await PaymentService().processSimulation(
        orderId: widget.orderId,
        userId: context.read<AuthProvider>().uid!,
        paymentMethod: paymentMethod,
        amount: widget.totalAmount,
      );

      if (!mounted) return;

      // Navigate to processing animation
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const PaymentProcessingPage(),
        ),
      );

      // Simulate processing time
      await Future<void>.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Navigate to result
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PaymentResultPage(
            payment: payment,
            isSuccessful: payment.paymentStatus == PaymentStatus.paidSimulated,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Method'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            _buildMethodOption(
              PaymentMethod.cod,
              'Cash on Delivery (COD)',
              Icons.receipt_long,
            ),
            const SizedBox(height: 16),
            _buildMethodOption(
              PaymentMethod.gcash,
              'GCash (SIMULATED)',
              Icons.account_balance_wallet,
            ),
            const SizedBox(height: 16),
            _buildMethodOption(
              PaymentMethod.maya,
              'Maya (SIMULATED)',
              Icons.account_balance,
            ),
            const SizedBox(height: 16),
            _buildMethodOption(
              PaymentMethod.card,
              'Credit/Debit Card (SIMULATED)',
              Icons.credit_card,
            ),
            const SizedBox(height: 32),
            _isProcessing
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _processPayment,
                    child: const Text('Place Order & Pay'),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodOption(PaymentMethod method, String label, IconData icon) {
    final isSelected = _selectedMethod == method.value;
    return InkWell(
      borderRadius: BorderRadius.circular(3),
      onTap: () => _selectMethod(method.value),
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 0),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? const Color(0xFF0B0B0B) : const Color(0xFFC9C5BA), width: isSelected ? 1.4 : 1),
          borderRadius: BorderRadius.circular(3),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF0B0B0B)),
          ],
        ),
      ),
    );
  }
}