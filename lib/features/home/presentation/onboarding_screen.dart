import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import '../../../core/storage/local_store.dart';
import '../../../shared/extensions/context_extensions.dart';

const _seenOnboardingKey = 'seen_onboarding';

/// First-run flag, seeded from Hive so onboarding shows exactly once
/// (and again after a demo reset wipes storage).
final seenOnboardingProvider = StateProvider<bool>(
  (ref) => ref.watch(localStoreProvider).prefs.get(_seenOnboardingKey) == true,
);

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    (
      Icons.route_rounded,
      'One list. The cheapest trip.',
      'The optimizer prices your whole basket at every store nearby — '
          'including coupons and the cost of driving — and tells you when '
          'a second stop genuinely pays off.',
    ),
    (
      Icons.auto_awesome_rounded,
      'An assistant that knows groceries',
      'Ask for a week of dinners under \$60, cheaper substitutes, or '
          'whether to wait for next week\'s sale. Meal plans use what\'s '
          'already in your pantry.',
    ),
    (
      Icons.receipt_long_rounded,
      'Scan receipts, see the truth',
      'Point the camera at any receipt: spending charts, category '
          'breakdowns, and a forecast of next month appear automatically.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(localStoreProvider).prefs.put(_seenOnboardingKey, true);
    ref.read(seenOnboardingProvider.notifier).state = true;
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final last = _page == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('Skip'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) {
                  final (icon, title, body) = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TweenAnimationBuilder<double>(
                          key: ValueKey(i),
                          tween: Tween(begin: 0.7, end: 1),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutBack,
                          builder: (_, scale, child) =>
                              Transform.scale(scale: scale, child: child),
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: context.colors.primaryContainer.withValues(
                                alpha: 0.5,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icon,
                              size: 72,
                              color: context.colors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: context.text.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          body,
                          textAlign: TextAlign.center,
                          style: context.text.bodyLarge?.copyWith(
                            color: context.colors.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _pages.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _page ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page
                          ? context.colors.primary
                          : context.colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: last
                      ? _finish
                      : () => _controller.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                        ),
                  child: Text(last ? 'Start shopping smarter' : 'Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
