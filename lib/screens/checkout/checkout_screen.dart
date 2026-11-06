import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/cart_line.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/orders_provider.dart';
import '../../utils/app_snack.dart';
import '../../utils/formatters.dart';
import '../../utils/validators.dart';
import '../../widgets/brand_header.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/product_image.dart';
import '../../widgets/responsive.dart';
import '../../widgets/trapped_button.dart';
import '../../widgets/trapped_text_field.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _street = TextEditingController();
  final _barangay = TextEditingController();
  final _city = TextEditingController();
  final _province = TextEditingController();
  final _postalCode = TextEditingController();
  final _notes = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final profile = auth.profile;
    _fullName.text = profile?.fullName ?? '';
    _email.text = profile?.email.isNotEmpty == true
        ? profile!.email
        : (auth.email ?? '');
    _phone.text = profile?.phone ?? '';
    _street.text = profile?.address ?? '';
    _barangay.text = profile?.barangay ?? '';
    _city.text = profile?.city ?? '';
    _province.text = profile?.province ?? '';
    _postalCode.text = profile?.postalCode ?? '';
  }

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _street.dispose();
    _barangay.dispose();
    _city.dispose();
    _province.dispose();
    _postalCode.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final cart = context.read<CartProvider>();
    final catalog = context.read<CatalogProvider>();
    final validation = cart.validateForCheckout(catalog.productMap);
    if (validation != null) {
      AppSnack.error(context, validation);
      return;
    }
    setState(() => _submitting = true);
    try {
      final selectedPayment = PaymentMethod.cod;
      final order = await context.read<OrdersProvider>().placeOrder(
        cartItems: cart.items,
        address: ShippingAddress(
          fullName: _fullName.text.trim(),
          phone: _phone.text.trim(),
          email: _email.text.trim(),
          street: _street.text.trim(),
          barangay: _barangay.text.trim(),
          city: _city.text.trim(),
          province: _province.text.trim(),
          postalCode: _postalCode.text.trim(),
          notes: _notes.text.trim(),
        ),
        paymentMethod: selectedPayment,
        notes: _notes.text.trim(),
      );
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => OrderSuccessScreen(order: order),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      AppSnack.error(context, error.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();
    final catalog = context.watch<CatalogProvider>();
    final isDesktop = Breakpoints.isDesktop(context);

    if (!auth.isAuthenticated) {
      return Scaffold(
        backgroundColor: AppColors.paper,
        body: Column(
          children: [
            BrandHeader(
              onLeading: () => Navigator.of(context).pop(),
              leadingIcon: Icons.arrow_back,
            ),
            Expanded(
              child: EmptyState(
                icon: Icons.lock_outline,
                title: 'Sign in to checkout',
                message:
                    'Your delivery details and order history are protected by your account.',
                actionLabel: 'GO BACK',
                onAction: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      );
    }

    final lines = cart.lines(catalog.productMap);
    if (lines.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.paper,
        body: Column(
          children: [
            BrandHeader(
              onLeading: () => Navigator.of(context).pop(),
              leadingIcon: Icons.arrow_back,
            ),
            const Expanded(
              child: EmptyState(
                icon: Icons.shopping_bag_outlined,
                title: 'Your bag is empty',
                message:
                    'Add a piece to your bag before heading to checkout.',
              ),
            ),
          ],
        ),
      );
    }

    final subtotal = cart.subtotal(catalog.productMap);
    final shipping = cart.shippingFee(catalog.productMap);
    final total = cart.total(catalog.productMap);

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Column(
        children: [
          BrandHeader(
            onLeading: () => Navigator.of(context).pop(),
            leadingIcon: Icons.arrow_back,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: ContentFrame(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    Text(
                      'CHECKOUT',
                      style: AppTextStyles.label.copyWith(
                        fontSize: 11,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Complete your delivery details. Payment is cash on delivery.',
                      style: AppTextStyles.bodyMuted.copyWith(
                        fontSize: 10.5,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 26),
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: _buildForm(context)),
                          const SizedBox(width: 36),
                          Expanded(
                            flex: 2,
                            child: _CheckoutSummary(
                              lines: lines,
                              subtotal: subtotal,
                              shipping: shipping,
                              total: total,
                              submitting: _submitting,
                              onPlaceOrder: _placeOrder,
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildForm(context),
                          const SizedBox(height: 24),
                          _CheckoutSummary(
                            lines: lines,
                            subtotal: subtotal,
                            shipping: shipping,
                            total: total,
                            submitting: _submitting,
                            onPlaceOrder: _placeOrder,
                          ),
                        ],
                      ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FormSection(
            title: 'CONTACT',
            children: [
              TrappedTextField(
                label: 'Full name',
                controller: _fullName,
                hint: 'Name of the recipient',
                textInputAction: TextInputAction.next,
                validator: Validators.fullName,
                autofillHints: const [AutofillHints.name],
              ),
              const SizedBox(height: 14),
              TrappedTextField(
                label: 'Email',
                controller: _email,
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: Validators.email,
                autofillHints: const [AutofillHints.email],
              ),
              const SizedBox(height: 14),
              TrappedTextField(
                label: 'Phone',
                controller: _phone,
                hint: '+63 9XX XXX XXXX',
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: Validators.phone,
                autofillHints: const [AutofillHints.telephoneNumber],
              ),
            ],
          ),
          const SizedBox(height: 26),
          _FormSection(
            title: 'DELIVERY ADDRESS',
            children: [
              TrappedTextField(
                label: 'Street address',
                controller: _street,
                hint: 'House number, street, subdivision',
                textInputAction: TextInputAction.next,
                validator: Validators.address,
                autofillHints: const [AutofillHints.streetAddressLine1],
              ),
              const SizedBox(height: 14),
              TrappedTextField(
                label: 'Barangay (optional)',
                controller: _barangay,
                hint: 'Barangay',
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TrappedTextField(
                      label: 'City',
                      controller: _city,
                      hint: 'City',
                      textInputAction: TextInputAction.next,
                      validator: (value) =>
                          Validators.required(value, field: 'City'),
                      autofillHints: const [AutofillHints.addressCity],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TrappedTextField(
                      label: 'Province',
                      controller: _province,
                      hint: 'Province',
                      textInputAction: TextInputAction.next,
                      validator: (value) =>
                          Validators.required(value, field: 'Province'),
                      autofillHints: const [AutofillHints.addressState],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TrappedTextField(
                label: 'Postal code',
                controller: _postalCode,
                hint: '1000',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: Validators.postalCode,
                autofillHints: const [AutofillHints.postalCode],
              ),
              const SizedBox(height: 14),
              TrappedTextField(
                label: 'Delivery notes (optional)',
                controller: _notes,
                hint: 'Landmark, gate instructions, preferred time',
                maxLines: 3,
                textInputAction: TextInputAction.newline,
              ),
            ],
          ),
          const SizedBox(height: 26),
          _FormSection(
            title: 'PAYMENT',
            children: [
              const _PaymentOption(
                title: 'Cash on delivery',
                subtitle: 'Pay the courier when your order arrives.',
                selected: true,
                enabled: true,
              ),
              const SizedBox(height: 10),
              const _PaymentOption(
                title: 'GCash',
                subtitle:
                    'Simulated GCash payment. Amount will be deducted from demo balance.',
                selected: false,
                enabled: true,
              ),
              const SizedBox(height: 10),
              const _PaymentOption(
                title: 'Maya',
                subtitle:
                    'Simulated Maya payment. Amount will be deducted from demo balance.',
                selected: false,
                enabled: true,
              ),
              const SizedBox(height: 10),
              const _PaymentOption(
                title: 'Credit/Debit Card',
                subtitle:
                    'Simulated card payment. Use fictional test information only.',
                selected: false,
                enabled: true,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  border: Border.all(color: AppColors.line),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      size: 15,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'Online payments are simulated for demonstration purposes. '
                        'No real transactions occur. Orders will be processed after confirmation.',
                        style: AppTextStyles.small.copyWith(
                          fontSize: 9,
                          height: 1.6,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: AppTextStyles.micro.copyWith(
            fontSize: 8,
            letterSpacing: 2,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.enabled,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? AppColors.ink
        : enabled
        ? AppColors.lineDark
        : AppColors.line;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: enabled ? AppColors.paper : AppColors.canvas,
        border: Border.all(color: borderColor, width: selected ? 1.4 : 1),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? AppColors.ink
                    : enabled
                    ? AppColors.lineDark
                    : AppColors.faint,
              ),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.ink,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title.toUpperCase(),
                        style: AppTextStyles.micro.copyWith(
                          fontSize: 8.5,
                          letterSpacing: 1.5,
                          color: enabled ? AppColors.ink : AppColors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: AppTextStyles.small.copyWith(
                    fontSize: 9.5,
                    height: 1.55,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutSummary extends StatelessWidget {
  const _CheckoutSummary({
    required this.lines,
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.submitting,
    required this.onPlaceOrder,
  });

  final List<CartLine> lines;
  final double subtotal;
  final double shipping;
  final double total;
  final bool submitting;
  final VoidCallback onPlaceOrder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'YOUR ORDER',
            style: AppTextStyles.micro.copyWith(
              fontSize: 8,
              letterSpacing: 2,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 16),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 48,
                    height: 58,
                    child: ProductImage(
                      imageUrl: line.product.imageUrl,
                      fallbackAsset: line.product.localFallback,
                      padding: const EdgeInsets.all(4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          line.product.name.toUpperCase(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.micro.copyWith(
                            fontSize: 7.5,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'SIZE ${line.item.size} · QTY ${line.item.quantity}',
                          style: AppTextStyles.micro.copyWith(
                            fontSize: 6.5,
                            letterSpacing: 0.6,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    Formatters.currency(line.lineTotal),
                    style: AppTextStyles.price.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
          Divider(color: AppColors.lineDark, height: 1),
          const SizedBox(height: 16),
          _SummaryRow(label: 'Subtotal', value: Formatters.currency(subtotal)),
          const SizedBox(height: 10),
          _SummaryRow(
            label: 'Shipping',
            value: shipping == 0 ? 'FREE' : Formatters.currency(shipping),
          ),
          const SizedBox(height: 14),
          Divider(color: AppColors.lineDark, height: 1),
          const SizedBox(height: 14),
          _SummaryRow(
            label: 'Total',
            value: Formatters.currency(total),
            emphasize: true,
          ),
          const SizedBox(height: 20),
          TrappedButton(
            label: 'PLACE ORDER',
            onPressed: submitting ? null : onPlaceOrder,
            loading: submitting,
            height: 48,
            fontSize: 9.5,
          ),
          const SizedBox(height: 12),
          Text(
            'By placing this order you agree to the payment terms. '
            'Cash on delivery orders will be confirmed before dispatch. '
            'Simulated online payments will be recorded for demonstration.',
            textAlign: TextAlign.center,
            style: AppTextStyles.small.copyWith(
              fontSize: 8.5,
              height: 1.6,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label.toUpperCase(),
            style: AppTextStyles.micro.copyWith(
              fontSize: emphasize ? 9 : 8,
              letterSpacing: emphasize ? 1.8 : 1.2,
              color: emphasize ? AppColors.ink : AppColors.muted,
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.price.copyWith(
            fontSize: emphasize ? 14 : 11,
          ),
        ),
      ],
    );
  }
}