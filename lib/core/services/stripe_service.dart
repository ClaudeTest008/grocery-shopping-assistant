import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../config/app_config.dart';

/// Thin wrapper around flutter_stripe: SDK init and a single "present the
/// upgrade paywall" entry point. No-op (with an explanatory dialog) when
/// Stripe isn't configured for this build.
abstract final class StripeService {
  static Future<void> init() async {
    if (!AppConfig.hasStripe) return;
    try {
      Stripe.publishableKey = AppConfig.stripePublishableKey;
      await Stripe.instance.applySettings();
    } catch (e) {
      debugPrint('StripeService.init failed: $e');
    }
  }

  static Future<void> presentPaywall(BuildContext context) async {
    if (!AppConfig.hasStripe) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Payments unavailable'),
          content: const Text(
            'This build isn\'t configured for payments. Upgrading to '
            'Premium isn\'t available in demo mode.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    try {
      final response = await Dio().post<Map<String, dynamic>>(
        '${AppConfig.supabaseUrl}/functions/v1/stripe-checkout',
      );
      final clientSecret = response.data?['clientSecret'] as String?;
      if (clientSecret == null) {
        throw const FormatException('Missing clientSecret in response');
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Grocery Shopping Assistant',
        ),
      );
      await Stripe.instance.presentPaymentSheet();

      messenger.showSnackBar(
        const SnackBar(content: Text('Welcome to Premium!')),
      );
    } on StripeException catch (e) {
      final message = e.error.localizedMessage ?? 'Payment cancelled';
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Upgrade failed: $e')));
    }
  }
}
