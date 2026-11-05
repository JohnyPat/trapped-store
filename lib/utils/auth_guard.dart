import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../widgets/confirm_dialog.dart';

/// Opens the login flow on top of the current route. On success the login and
/// signup screens return to the first route, so the user lands back in the
/// store with their session bound to the user-scoped providers.
Future<void> openLogin(BuildContext context) async {
  await Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
  );
}

/// Returns true when the current session can write user-specific data.
/// Guests are shown the sign-in prompt and taken to the login screen.
Future<bool> ensureSignedIn(BuildContext context) async {
  final auth = context.read<AuthProvider>();
  if (auth.isAuthenticated) return true;
  final shouldSignIn = await showConfirmDialog(
    context,
    title: 'Members only',
    message:
        'Sign in to save pieces, build your bag and place orders. Your cart and wishlist sync across web and mobile.',
    confirmLabel: 'SIGN IN',
    cancelLabel: 'KEEP BROWSING',
  );
  if (shouldSignIn && context.mounted) {
    await openLogin(context);
  }
  return false;
}
