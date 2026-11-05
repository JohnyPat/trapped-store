import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

abstract final class Formatters {
  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '${AppConstants.currencySymbol} ',
    decimalDigits: 2,
  );

  static final DateFormat _date = DateFormat('MMM d, yyyy');
  static final DateFormat _dateTime = DateFormat('MMM d, yyyy · h:mm a');
  static final DateFormat _shortDate = DateFormat('MM.dd.yy');

  static String currency(num amount) => _currency.format(amount);

  static String date(DateTime? value) =>
      value == null ? '—' : _date.format(value.toLocal());

  static String dateTime(DateTime? value) =>
      value == null ? '—' : _dateTime.format(value.toLocal());

  static String shortDate(DateTime? value) =>
      value == null ? '—' : _shortDate.format(value.toLocal());

  static String initials(String? name) {
    final parts = (name ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'TR';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  static String orderStatus(String status) {
    switch (status) {
      case 'pending':
        return 'PENDING';
      case 'confirmed':
        return 'CONFIRMED';
      case 'processing':
        return 'PROCESSING';
      case 'shipped':
        return 'SHIPPED';
      case 'delivered':
        return 'DELIVERED';
      case 'cancelled':
        return 'CANCELLED';
      default:
        return status.toUpperCase();
    }
  }

  static String paymentStatus(String status) {
    switch (status) {
      case 'pending':
        return 'PENDING';
      case 'paid':
        return 'PAID';
      case 'failed':
        return 'FAILED';
      case 'refunded':
        return 'REFUNDED';
      case 'cancelled':
        return 'CANCELLED';
      default:
        return status.toUpperCase();
    }
  }

  static String paymentMethod(String method) {
    switch (method) {
      case 'cod':
        return 'CASH ON DELIVERY';
      case 'online':
        return 'ONLINE PAYMENT';
      default:
        return method.toUpperCase();
    }
  }

  static String plural(int count, String singular, [String? plural]) =>
      count == 1 ? singular : (plural ?? '${singular}S');
}
