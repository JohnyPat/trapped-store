import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/auth_backdrop.dart';
import '../../widgets/auth_widgets.dart';
import '../../widgets/brand_mark.dart';
import '../../widgets/trapped_text_field.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _localError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _localError = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    if (!success) {
      setState(() => _localError = auth.error);
      return;
    }
    // When login was opened from the guest session this returns to the shell.
    // On a cold start the auth gate swaps the root route to the shell instead.
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final banner = _localError ?? auth.error;
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: AuthPageShell(
        showBack: Navigator.of(context).canPop(),
        children: [
          Center(child: BrandMark(size: 70)),
          const SizedBox(height: 22),
          Text(
            'Login',
            textAlign: TextAlign.center,
            style: AppTextStyles.title.copyWith(
              color: AppColors.paper,
              fontSize: 19,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 30),
          AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (banner != null) AuthErrorBanner(message: banner),
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
                  const SizedBox(height: 15),
                  TrappedTextField(
                    label: 'Password',
                    controller: _passwordController,
                    hint: '••••••••',
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    validator: Validators.password,
                    autofillHints: const [AutofillHints.password],
                    onFieldSubmitted: (_) => _submit(),
                    labelColor: AppColors.paper,
                    hintColor: AppColors.faint,
                    borderColor: AppColors.paper.withValues(alpha: .6),
                  ),
                  const SizedBox(height: 5),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AuthLink(
                      label: 'Forgot Password',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  AuthPrimaryButton(
                    label: 'Sign In',
                    loading: auth.isBusy,
                    onPressed: auth.isBusy ? null : _submit,
                  ),
                  const SizedBox(height: 18),
                  AuthLink(
                    label: 'Sign Up',
                    underline: false,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SignupScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  AuthLink(
                    label: 'Login as Guest',
                    underline: false,
                    onTap: () {
                      context.read<AuthProvider>().continueAsGuest();
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 34),
          Text(
            'WEAR YOUR CONVICTION.',
            textAlign: TextAlign.center,
            style: AppTextStyles.micro.copyWith(
              fontSize: 7,
              letterSpacing: 3.2,
              color: AppColors.paper.withValues(alpha: .55),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
