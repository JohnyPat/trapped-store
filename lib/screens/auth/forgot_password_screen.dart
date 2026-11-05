import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/auth_backdrop.dart';
import '../../widgets/auth_widgets.dart';
import '../../widgets/brand_mark.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/trapped_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String? _localError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _localError = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.sendPasswordReset(_emailController.text.trim());
    if (!mounted) return;
    if (!success) {
      setState(() => _localError = auth.error);
      return;
    }
    await showInfoDialog(
      context,
      title: 'Check your inbox',
      message:
          'If an account exists for ${_emailController.text.trim()}, a password reset link has been sent. Follow the link to choose a new password.',
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: AuthPageShell(
        showBack: true,
        children: [
          Center(child: BrandMark(size: 64)),
          const SizedBox(height: 20),
          Text(
            'Reset Password',
            textAlign: TextAlign.center,
            style: AppTextStyles.title.copyWith(
              color: AppColors.paper,
              fontSize: 18,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Enter the email linked to your account. We will send a secure reset link.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMuted.copyWith(
              color: AppColors.paper.withValues(alpha: .65),
              fontSize: 10.5,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 26),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_localError != null) AuthErrorBanner(message: _localError!),
                TrappedTextField(
                  label: 'Email',
                  controller: _emailController,
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: Validators.email,
                  onFieldSubmitted: (_) => _submit(),
                  labelColor: AppColors.paper,
                  hintColor: AppColors.faint,
                  borderColor: AppColors.paper.withValues(alpha: .6),
                ),
                const SizedBox(height: 20),
                AuthPrimaryButton(
                  label: 'Send Reset Link',
                  loading: auth.isBusy,
                  onPressed: auth.isBusy ? null : _submit,
                ),
                const SizedBox(height: 10),
                AuthOutlineButton(
                  label: 'Back to Login',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
