import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../platform/platform_support.dart';

/// Thin wrapper around flutter_stripe: SDK init and a single "present the
/// upgrade paywall" entry point. No-op (with an explanatory dialog) when
/// Stripe isn't configured for this build.
abstract final class StripeService {
  static Future<void> init() async {
    // flutter_stripe has no desktop implementation; touching the SDK
    // there throws before any UI can explain why.
    if (!AppConfig.hasStripe || !PlatformSupport.hasPaymentSheet) return;
    try {
      Stripe.publishableKey = AppConfig.stripePublishableKey;
      await Stripe.instance.applySettings();
    } catch (e) {
      debugPrint('StripeService.init failed: $e');
    }
  }

  static Future<void> presentPaywall(BuildContext context) async {
    if (!AppConfig.hasStripe || !PlatformSupport.hasPaymentSheet) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Payments unavailable'),
          content: Text(
            !PlatformSupport.hasPaymentSheet
                ? 'The payment sheet is not supported on '
                      '${PlatformSupport.platformName}. Upgrade to Premium '
                      'from the Android, iOS or web app — your account '
                      'unlocks everywhere.'
                : 'This build isn\'t configured for payments. Upgrading to '
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
      // The edge function requires a signed-in Supabase session.
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Sign in to upgrade')),
        );
        return;
      }
      final response = await Dio().post<Map<String, dynamic>>(
        '${AppConfig.supabaseUrl}/functions/v1/stripe-checkout',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session.accessToken}',
            'apikey': AppConfig.supabaseAnonKey,
          },
        ),
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
