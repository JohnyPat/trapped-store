import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/catalog_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/payments_provider.dart';
import 'providers/wishlist_provider.dart';
import 'screens/app_shell.dart';
import 'screens/auth/login_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'admin/screens/admin_login_page.dart';
import 'admin/screens/admin_dashboard.dart';
import 'services/auth_service.dart';
import 'services/cart_service.dart';
import 'services/database_service.dart';
import 'services/order_service.dart';
import 'services/payment_service.dart';
import 'services/product_service.dart';
import 'services/storage_service.dart';
import 'services/wishlist_service.dart';
import 'theme/app_theme.dart';

class TrappedApp extends StatelessWidget {
  const TrappedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DatabaseService>(create: (_) => DatabaseService()),
        Provider<AuthService>(
          create: (context) =>
              AuthService(database: context.read<DatabaseService>()),
        ),
        Provider<ProductService>(
          create: (context) =>
              ProductService(database: context.read<DatabaseService>()),
        ),
        Provider<CartService>(
          create: (context) =>
              CartService(database: context.read<DatabaseService>()),
        ),
        Provider<WishlistService>(
          create: (context) =>
              WishlistService(database: context.read<DatabaseService>()),
        ),
        Provider<OrderService>(
          create: (context) =>
              OrderService(database: context.read<DatabaseService>()),
        ),
        Provider<PaymentService>(
          create: (context) =>
              PaymentService(database: context.read<DatabaseService>()),
        ),
        Provider<StorageService>(create: (_) => StorageService()),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            authService: context.read<AuthService>(),
            databaseService: context.read<DatabaseService>(),
            storageService: context.read<StorageService>(),
          )..initialize(),
        ),
        ChangeNotifierProvider<CatalogProvider>(
          create: (context) => CatalogProvider(
            productService: context.read<ProductService>(),
          )..initialize(),
        ),
        ChangeNotifierProvider<WishlistProvider>(
          create: (context) => WishlistProvider(
            wishlistService: context.read<WishlistService>(),
          ),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (context) =>
              CartProvider(cartService: context.read<CartService>()),
        ),
        ChangeNotifierProvider<OrdersProvider>(
          create: (context) =>
              OrdersProvider(orderService: context.read<OrderService>()),
        ),
        ChangeNotifierProvider<PaymentsProvider>(
          create: (context) =>
              PaymentsProvider(paymentService: context.read<PaymentService>()),
        ),
      ],
      child: const _UserDataBinder(child: _TrappedMaterialApp()),
    );
  }
}

class _TrappedMaterialApp extends StatelessWidget {
  const _TrappedMaterialApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '[trapped]',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthGate(),
      routes: {
        '/admin/login': (_) => const AdminLoginPage(),
        '/admin/dashboard': (_) => const AdminDashboard(),
      },
    );
  }
}

/// Keeps the user-scoped providers in sync with the Firebase session.
class _UserDataBinder extends StatefulWidget {
  const _UserDataBinder({required this.child});

  final Widget child;

  @override
  State<_UserDataBinder> createState() => _UserDataBinderState();
}

class _UserDataBinderState extends State<_UserDataBinder> {
  AuthProvider? _auth;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      _auth = auth;
      auth.addListener(_syncUserData);
      _syncUserData();
    });
  }

  void _syncUserData() {
    if (!mounted) return;
    final uid = _auth?.uid;
    context.read<WishlistProvider>().bindUser(uid);
    context.read<CartProvider>().bindUser(uid);
    context.read<OrdersProvider>().bindUser(uid);
    context.read<PaymentsProvider>().bindUser(uid);
  }

  @override
  void dispose() {
    _auth?.removeListener(_syncUserData);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.isInitializing) {
      return const SplashScreen();
    }
    if (!auth.isAuthenticated && !auth.isGuest) {
      return const LoginScreen();
    }
    return const AppShell();
  }
}
