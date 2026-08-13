import '../../data/models/product.dart';
import 'scheme_sheets.dart';
import 'shop_sheets.dart';

/// Stable facade used across the app.
abstract final class AppSheets {
  static void showSearch() => showSearchSheet();
  static void showProduct(Product product) => showProductSheet(product);
  static void showCart() => showCartSheet();
  static void showWishlist() => showWishlistSheet();
  static void showCheckout() => showCheckoutSheet();
  static void showOrders() => showOrdersSheet();
  static void showAddresses() => showAddressesSheet();
  static void showSchemeDetails() => showSchemeDetailsSheet();
  static void showSchemeEnrollment() => showSchemeEnrollmentSheet();
  static void showSchemePayment() => showSchemePaymentSheet();
  static void showRedemption() => showRedemptionSheet();
  static void showContactWavoo() => showContactSheet();
}
