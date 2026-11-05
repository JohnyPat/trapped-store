import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_snack.dart';
import '../../utils/validators.dart';
import '../../widgets/auth_backdrop.dart';
import '../../widgets/auth_widgets.dart';
import '../../widgets/brand_mark.dart';
import '../../widgets/trapped_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _localError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _localError = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    if (!success) {
      setState(() => _localError = auth.error);
      return;
    }
    AppSnack.success(context, 'Account created. Welcome to [trapped].');
    Navigator.of(context).popUntil((route) => route.isFirst);
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
            'Create Account',
            textAlign: TextAlign.center,
            style: AppTextStyles.title.copyWith(
              color: AppColors.paper,
              fontSize: 18,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 28),
          AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_localError != null) AuthErrorBanner(message: _localError!),
                  TrappedTextField(
                    label: 'Full Name',
                    controller: _nameController,
                    hint: 'Your name',
                    textInputAction: TextInputAction.next,
                    validator: Validators.fullName,
                    autofillHints: const [AutofillHints.name],
                    labelColor: AppColors.paper,
                    hintColor: AppColors.faint,
                    borderColor: AppColors.paper.withValues(alpha: .6),
                  ),
                  const SizedBox(height: 13),
                  TrappedTextField(
                    label: 'Email',
                    controller: _emailController,
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: Validators.email,
                    autofillHints: const [AutofillHints.email],
                    labelColor: AppColors.paper,
                    hintColor: AppColors.faint,
                    borderColor: AppColors.paper.withValues(alpha: .6),
                  ),
                  const SizedBox(height: 13),
                  TrappedTextField(
                    label: 'Phone Number',
                    controller: _phoneController,
                    hint: '+63 9XX XXX XXXX',
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    validator: Validators.phone,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    labelColor: AppColors.paper,
                    hintColor: AppColors.faint,
                    borderColor: AppColors.paper.withValues(alpha: .6),
                  ),
                  const SizedBox(height: 13),
                  TrappedTextField(
                    label: 'Password',
                    controller: _passwordController,
                    hint: 'At least 6 characters',
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    validator: Validators.password,
                    autofillHints: const [AutofillHints.newPassword],
                    labelColor: AppColors.paper,
                    hintColor: AppColors.faint,
                    borderColor: AppColors.paper.withValues(alpha: .6),
                  ),
                  const SizedBox(height: 13),
                  TrappedTextField(
                    label: 'Confirm Password',
                    controller: _confirmController,
                    hint: 'Repeat your password',
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    validator: (value) => Validators.confirmPassword(
                      value,
                      _passwordController.text,
                    ),
                    onFieldSubmitted: (_) => _submit(),
                    labelColor: AppColors.paper,
                    hintColor: AppColors.faint,
                    borderColor: AppColors.paper.withValues(alpha: .6),
                  ),
                  const SizedBox(height: 22),
                  AuthPrimaryButton(
                    label: 'Sign Up',
                    loading: auth.isBusy,
                    onPressed: auth.isBusy ? null : _submit,
                  ),
                  const SizedBox(height: 10),
                  AuthOutlineButton(
                    label: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
