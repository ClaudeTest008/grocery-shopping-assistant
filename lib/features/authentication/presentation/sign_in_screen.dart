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

  // TextSpan recognizers must be owned and disposed by their State;
  // creating them inline in build leaks one pair per rebuild.
  late final TapGestureRecognizer _termsRecognizer = TapGestureRecognizer()
    ..onTap = () =>
        launchUrl(Uri.parse(termsUrl), mode: LaunchMode.externalApplication);
  late final TapGestureRecognizer _privacyRecognizer = TapGestureRecognizer()
    ..onTap = () =>
        launchUrl(Uri.parse(privacyUrl), mode: LaunchMode.externalApplication);

  bool _isSignUp = false;
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
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
        // Email-confirmation signups leave no session, so the router
        // redirect below never fires; tell the user what happens next.
        if (auth.currentUser == null && mounted) {
          await showDialog<void>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Almost there — confirm your email'),
              content: Text(
                'We sent a link to ${_emailController.text.trim()}. '
                'Sign in after confirming.',
              ),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
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

  Future<void> _forgotPassword() async {
    if (AppConfig.isDemoMode) {
      context.showSnack('Demo mode — any credentials work');
      return;
    }
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController(
      text: _emailController.text.trim(),
    );
    final email = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        void submit() {
          if (formKey.currentState?.validate() ?? false) {
            Navigator.pop(dialogContext, controller.text.trim());
          }
        }

        return AlertDialog(
          title: const Text('Reset password'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
              validator: Validators.email,
              onFieldSubmitted: (_) => submit(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(onPressed: submit, child: const Text('Send link')),
          ],
        );
      },
    );
    controller.dispose();
    if (email == null || !mounted) return;
    setState(() => _isSubmitting = true);
    final auth = ref.read(authRepositoryProvider);
    try {
      // resetPassword lives on the concrete type only; the demo guard
      // above means Supabase is the only repository that reaches here.
      if (auth is SupabaseAuthRepository) await auth.resetPassword(email);
      if (mounted) context.showSnack('Check your email for a reset link');
    } on AuthFailure catch (e) {
      if (mounted) context.showSnack(e.message, error: true);
    } catch (e) {
      if (mounted) context.showSnack('Something went wrong', error: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _runAuth(Future<void> Function() action) async {
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
                            recognizer: _termsRecognizer,
                          ),
                          const TextSpan(text: ' and the '),
                          TextSpan(
                            text: 'Privacy policy',
                            style: TextStyle(
                              color: colors.primary,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: _privacyRecognizer,
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
                        onPressed: _isSubmitting
                            ? null
                            : () => _runAuth(
                                () => ref
                                    .read(authRepositoryProvider)
                                    .signInWithEmail(
                                      'demo@grocery.app',
                                      'demo',
                                    ),
                              ),
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
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? 'Show password'
                              : 'Hide password',
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      validator: Validators.password,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    if (!_isSignUp)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isSubmitting ? null : _forgotPassword,
                          child: const Text('Forgot password?'),
                        ),
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
                          : () => _runAuth(
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
                          : () => _runAuth(
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
