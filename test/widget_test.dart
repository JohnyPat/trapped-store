import 'package:flutter_test/flutter_test.dart';
import 'package:trapped_store/admin/models/admin_order_model.dart';
import 'package:trapped_store/models/app_user.dart';
import 'package:trapped_store/models/product.dart';
import 'package:trapped_store/utils/formatters.dart';
import 'package:trapped_store/utils/validators.dart';

void main() {
  group('Validators', () {
    test('rejects empty and malformed email addresses', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email('patrick@gmail.com'), isNull);
    });

    test('requires a password of at least six characters', () {
      expect(Validators.password('123'), isNotNull);
      expect(Validators.password('patty'), isNotNull);
      expect(Validators.password('trapped'), isNull);
    });

    test('requires matching password confirmation', () {
      expect(Validators.confirmPassword('secret1', 'secret2'), isNotNull);
      expect(Validators.confirmPassword('secret1', 'secret1'), isNull);
    });
  });

  group('Formatters', () {
    test('formats PHP currency', () {
      expect(Formatters.currency(1500), contains('PHP'));
      expect(Formatters.currency(1500), contains('1,500.00'));
    });

    test('formats initials', () {
      expect(Formatters.initials('John Patrick Cruz'), 'JC');
      expect(Formatters.initials(''), 'TR');
    });
  });

  group('AppUser', () {
    test('parses Firebase values and defaults status to active', () {
      final user = AppUser.fromMap('abc123', {
        'uid': 'abc123',
        'fullName': 'Juan Dela Cruz',
        'email': 'juan@gmail.com',
        'phone': '09123456789',
        'address': '609 Bagong Bayan',
        'barangay': 'Darangan',
        'city': 'Binangonan',
        'province': 'Rizal',
        'postalCode': '1940',
        'lastLoginAt': 1793664000000,
        'createdAt': 1793664000000,
        'updatedAt': 1793664000000,
      });

      expect(user.uid, 'abc123');
      expect(user.phone, '09123456789');
      expect(user.address, '609 Bagong Bayan');
      expect(user.barangay, 'Darangan');
      expect(user.city, 'Binangonan');
      expect(user.province, 'Rizal');
      expect(user.postalCode, '1940');
      expect(user.hasCompleteDeliveryInfo, isTrue);
      expect(user.status, 'active');
      expect(user.isActive, isTrue);
      expect(user.isDisabled, isFalse);
      expect(user.lastLoginAt, isNotNull);

      final payload = user.toMap();
      expect(payload['uid'], 'abc123');
      expect(payload['status'], 'active');
      expect(payload.containsKey('password'), isFalse);
    });

    test('honours explicit disabled status from the database', () {
      final user = AppUser.fromMap('abc123', {
        'uid': 'abc123',
        'fullName': 'Juan Dela Cruz',
        'email': 'juan@gmail.com',
        'phone': '09123456789',
        'status': 'disabled',
      });
      expect(user.isActive, isFalse);
      expect(user.isDisabled, isTrue);
    });
  });

  group('Product', () {
    test('parses Firebase values and defaults safely', () {
      final product = Product.fromMap('test-piece', {
        'name': 'TEST PIECE',
        'price': 1299,
        'stock': 4,
        'sizes': ['S', 'M'],
        'active': true,
      });

      expect(product.id, 'test-piece');
      expect(product.price, 1299);
      expect(product.stock, 4);
      expect(product.sizes, ['S', 'M']);
      expect(product.inStock, isTrue);
      expect(product.active, isTrue);
    });
  });

  group('AdminOrder', () {
    test('uses the parent user id and delivery address as fallbacks', () {
      final order = AdminOrder.fromMap('order-1', {
        'orderNumber': 'TRP-1',
        'subtotal': 600,
        'shippingFee': 150,
        'totalAmount': 750,
        'paymentMethod': 'cod',
        'paymentStatus': 'pending',
        'orderStatus': 'pending',
        'createdAt': 1793943765705,
        'items': <dynamic>[],
        'deliveryAddress': {'fullName': 'patrtick', 'email': 'jp@gmail.com'},
      }, userId: 'uid-1');

      expect(order.userId, 'uid-1');
      expect(order.customerName, 'patrtick');
      expect(order.customerEmail, 'jp@gmail.com');
    });
  });
}
