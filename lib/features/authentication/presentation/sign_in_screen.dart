import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../settings/presentation/account_section.dart'
    show privacyUrl, termsUrl;
import '../data/auth_repositories.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSignUp = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSubmitting = true);
    final auth = ref.read(authRepositoryProvider);
    try {
      if (_isSignUp) {
        await auth.signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        await auth.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }
      // Success: router redirect (listening to authStateProvider) handles
      // navigation away from this screen.
    } on AuthFailure catch (e) {
      if (mounted) context.showSnack(e.message, error: true);
    } catch (e) {
      if (mounted) context.showSnack('Something went wrong', error: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _oauth(Future<void> Function() action) async {
    setState(() => _isSubmitting = true);
    try {
      await action();
    } on AuthFailure catch (e) {
      if (mounted) context.showSnack(e.message, error: true);
    } catch (e) {
      if (mounted) context.showSnack('Something went wrong', error: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.shopping_basket_rounded,
                          size: 44,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isSignUp ? 'Create your account' : 'Welcome back',
                      textAlign: TextAlign.center,
                      style: context.text.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isSignUp
                          ? 'Sign up to start saving on groceries'
                          : 'Sign in to continue',
                      textAlign: TextAlign.center,
                      style: context.text.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Store policies require informed consent at the
                    // point of account creation, not buried in settings.
                    Text.rich(
                      TextSpan(
                        text: 'By continuing you agree to the ',
                        children: [
                          TextSpan(
                            text: 'Terms of use',
                            style: TextStyle(
                              color: colors.primary,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => launchUrl(
                                Uri.parse(termsUrl),
                                mode: LaunchMode.externalApplication,
                              ),
                          ),
                          const TextSpan(text: ' and the '),
                          TextSpan(
                            text: 'Privacy policy',
                            style: TextStyle(
                              color: colors.primary,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => launchUrl(
                                Uri.parse(privacyUrl),
                                mode: LaunchMode.externalApplication,
                              ),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: context.text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    if (AppConfig.isDemoMode) ...[
                      const SizedBox(height: 20),
                      FilledButton.tonalIcon(
                        onPressed: () => ref
                            .read(authRepositoryProvider)
                            .signInWithEmail('demo@grocery.app', 'demo'),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Explore the demo — no account'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Demo mode — any credentials work',
                        textAlign: TextAlign.center,
                        style: context.text.bodySmall?.copyWith(
                          color: colors.primary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.mail_outline_rounded),
                      ),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline_rounded),
                      ),
                      validator: Validators.password,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(_isSignUp ? 'Create account' : 'Sign in'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => setState(() => _isSignUp = !_isSignUp),
                      child: Text(
                        _isSignUp
                            ? 'Already have an account? Sign in'
                            : "Don't have an account? Create one",
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: Divider(color: colors.outlineVariant)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'or',
                            style: context.text.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: colors.outlineVariant)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _isSubmitting
                          ? null
                          : () => _oauth(
                              () => ref
                                  .read(authRepositoryProvider)
                                  .signInWithGoogle(),
                            ),
                      icon: const Icon(Icons.g_mobiledata, size: 28),
                      label: const Text('Continue with Google'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _isSubmitting
                          ? null
                          : () => _oauth(
                              () => ref
                                  .read(authRepositoryProvider)
                                  .signInWithApple(),
                            ),
                      icon: const Icon(Icons.apple),
                      label: const Text('Continue with Apple'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
