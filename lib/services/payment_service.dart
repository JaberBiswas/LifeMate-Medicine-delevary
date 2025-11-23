import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentService {
  late Razorpay _razorpay;

  PaymentService() {
    _razorpay = Razorpay();
  }

  void init({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onFailure,
    required Function(dynamic) onExternalWallet,
  }) {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onFailure);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
  }

  void openCheckout({
    required String keyId,
    required double amount,
    required String name,
    required String description,
    Map<String, dynamic>? prefill,
  }) {
    final options = {
      'key': keyId,
      'amount': (amount * 100).toInt(), // Convert to paise
      'name': name,
      'description': description,
      'prefill': prefill ?? {},
      'external': {
        'wallets': ['paytm']
      }
    };

    _razorpay.open(options);
  }

  void dispose() {
    _razorpay.clear();
  }
}

