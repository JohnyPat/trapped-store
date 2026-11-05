import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_snack.dart';
import '../../utils/validators.dart';
import '../../widgets/brand_header.dart';
import '../../widgets/responsive.dart';
import '../../widgets/trapped_button.dart';
import '../../widgets/trapped_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final auth = context.read<AuthProvider>();
    final success = await auth.changePassword(
      currentPassword: _current.text,
      newPassword: _next.text,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (success) {
      AppSnack.success(context, 'Password updated.');
      Navigator.of(context).pop();
    } else {
      AppSnack.error(
        context,
        auth.error ?? 'The password could not be updated.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                maxWidth: 560,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 32),
                      Text(
                        'CHANGE PASSWORD',
                        style: AppTextStyles.label.copyWith(
                          fontSize: 11,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'For your security, enter your current password before choosing a new one.',
                        style: AppTextStyles.bodyMuted.copyWith(
                          fontSize: 10.5,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 28),
                      TrappedTextField(
                        label: 'Current password',
                        controller: _current,
                        hint: '••••••••',
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        validator: Validators.password,
                        autofillHints: const [AutofillHints.password],
                      ),
                      const SizedBox(height: 15),
                      TrappedTextField(
                        label: 'New password',
                        controller: _next,
                        hint: 'At least 6 characters',
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        validator: Validators.password,
                        autofillHints: const [AutofillHints.newPassword],
                      ),
                      const SizedBox(height: 15),
                      TrappedTextField(
                        label: 'Confirm new password',
                        controller: _confirm,
                        hint: 'Repeat your new password',
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        validator: (value) => Validators.confirmPassword(
                          value,
                          _next.text,
                        ),
                        onFieldSubmitted: (_) => _submit(),
                        autofillHints: const [AutofillHints.newPassword],
                      ),
                      const SizedBox(height: 26),
                      TrappedButton(
                        label: 'UPDATE PASSWORD',
                        onPressed: _saving ? null : _submit,
                        loading: _saving,
                        height: 48,
                      ),
                      const SizedBox(height: 10),
                      TrappedButton(
                        label: 'CANCEL',
                        onPressed: _saving
                            ? null
                            : () => Navigator.of(context).pop(),
                        variant: TrappedButtonVariant.outline,
                        height: 46,
                      ),
                      const SizedBox(height: 42),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
