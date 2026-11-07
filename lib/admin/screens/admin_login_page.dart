import 'package:flutter/material.dart';

import 'package:trapped_store/shared/constants/admin_constants.dart';

import '../services/admin_auth_service.dart';
import '../widgets/admin_breakpoints.dart';
import '../widgets/admin_section_card.dart';

/// Admin login page with email/password and admin check.
class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _resetEmailController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _resetEmailController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await AdminAuthService().signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Check if user is admin
      final isAdmin = await AdminAuthService().isAdmin;
      if (isAdmin) {
        // Navigate to dashboard
        if (!mounted) return;
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/admin/dashboard', (route) => false);
      } else {
        // Show error if not admin — include the signed-in UID so the
        // mismatch can be fixed in Firebase Console
        if (!mounted) return;
        final uid = AdminAuthService().uid ?? '(unknown)';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 15),
            content: Text(
              'Not admin. Your UID is:\n$uid\n\n'
              'Set settings/adminUid in Firebase Realtime Database to this value.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final message = e is AdminAuthException ? e.message : 'Login failed: $e';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showForgotPassword() async {
    _resetEmailController.text = _emailController.text.trim();
    final email = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset password'),
        content: TextField(
          controller: _resetEmailController,
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Admin email',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext)
                    .pop(_resetEmailController.text.trim()),
            child: const Text('SEND LINK'),
          ),
        ],
      ),
    );
    if (email == null || email.isEmpty) return;
    try {
      await AdminAuthService().sendPasswordReset(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset link sent to $email.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not send reset link: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final desktop = AdminBreakpoints.isDesktop(context);
    return Scaffold(
      backgroundColor: desktop ? AdminColors.canvas : null,
      appBar: desktop ? null : AppBar(title: const Text('Admin Login')),
      body: desktop ? _buildDesktopLogin() : _buildMobileLogin(),
    );
  }

  // ── Mobile login (centred and width-capped on wide windows) ─────────

  Widget _buildMobileLogin() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Admin Login',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _signIn,
                        child: const Text('Sign In'),
                      ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _showForgotPassword,
                  child: const Text('Forgot password?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Desktop centered login card ─────────────────────────────────────

  Widget _buildDesktopLogin() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AdminColors.ink,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: AdminColors.paper,
                  size: 26,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Trapped Admin',
                style: TextStyle(
                  fontSize: 28,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AdminColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Sign in to manage the store.',
                style: TextStyle(fontSize: 14, color: AdminColors.muted),
              ),
              const SizedBox(height: 24),
              AdminSectionCard(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildEmailField(),
                      const SizedBox(height: 16),
                      _buildPasswordField(),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 48,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _signIn,
                          style: FilledButton.styleFrom(
                            backgroundColor: AdminColors.ink,
                            foregroundColor: AdminColors.paper,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: TextButton(
                          onPressed: _isLoading ? null : _showForgotPassword,
                          child: const Text('Forgot password?'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Admin access only',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 0.5,
                  color: AdminColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Shared field builders ───────────────────────────────────────────

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.email),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!value.contains('@')) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Password',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: _isPasswordVisible
            ? IconButton(
                icon: const Icon(Icons.visibility),
                onPressed: () {
                  setState(() => _isPasswordVisible = false);
                },
              )
            : IconButton(
                icon: const Icon(Icons.visibility_off),
                onPressed: () {
                  setState(() => _isPasswordVisible = true);
                },
              ),
      ),
      obscureText: !_isPasswordVisible,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
    );
  }
}
