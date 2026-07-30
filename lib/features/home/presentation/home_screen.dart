import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/formatters.dart';
import '../../../shared/data/notification_repository.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/section_header.dart';
import '../../authentication/data/auth_repositories.dart';
import '../../offers/data/offer_repositories.dart';
import '../../profile/data/preferences_repository.dart';
import '../../receipts/data/receipt_repositories.dart';
import '../../shopping_lists/presentation/shopping_lists_providers.dart';

final _monthSpendProvider = FutureProvider<double>((ref) async {
  final receipts = await ref.watch(receiptRepositoryProvider).receipts();
  final now = DateTime.now();
  return receipts
      .where(
        (r) =>
            r.purchasedAt.year == now.year && r.purchasedAt.month == now.month,
      )
      .fold<double>(0.0, (sum, r) => sum + r.total);
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final unread =
        ref.watch(notificationsProvider).value?.where((n) => !n.read).length ??
        0;
    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${user?.displayName?.split(' ').first ?? 'there'}'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => context.push('/notifications'),
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text('$unread'),
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref
            ..invalidate(_monthSpendProvider)
            ..invalidate(shoppingListsProvider)
            ..invalidate(activeOffersProvider)
            ..invalidate(notificationsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: const [
            _BudgetCard(),
            _ActiveListCard(),
            _QuickActions(),
            _OffersPreview(),
          ],
        ),
      ),
    );
  }
}

class _BudgetCard extends ConsumerWidget {
  const _BudgetCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spend = ref.watch(_monthSpendProvider).value ?? 0;
    final budget = ref.watch(preferencesProvider).monthlyBudget;
    final over = budget != null && spend > budget;
    // Without merging, a screen reader reads "Spent this month", "$243",
    // "$57 left of $300" as three unrelated fragments.
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Card(
          color: context.colors.primaryContainer.withValues(alpha: 0.5),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => context.push('/insights'),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spent this month',
                    style: context.text.labelLarge?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.currency(spend),
                    style: context.text.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (budget != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (spend / budget).clamp(0.0, 1.0),
                        minHeight: 8,
                        color: over ? context.colors.error : null,
                        backgroundColor: context.colors.surface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      over
                          ? '${Formatters.currency(spend - budget)} over your ${Formatters.currency(budget)} budget'
                          : '${Formatters.currency(budget - spend)} left of ${Formatters.currency(budget)}',
                      style: context.text.bodySmall?.copyWith(
                        color: over
                            ? context.colors.error
                            : context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveListCard extends ConsumerWidget {
  const _ActiveListCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lists = ref.watch(shoppingListsProvider).value;
    final list = lists?.firstOrNull;
    // A brand-new account would otherwise open on a home screen with a
    // hole where its most important action belongs.
    if (list == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: context.colors.primaryContainer,
              child: Icon(
                Icons.add_shopping_cart_rounded,
                color: context.colors.onPrimaryContainer,
              ),
            ),
            title: const Text(
              'Start your first list',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: const Text(
              'Add what you need and we will find the cheapest trip',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/lists'),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor: context.colors.primaryContainer,
            child: Icon(
              Icons.checklist_rounded,
              color: context.colors.onPrimaryContainer,
            ),
          ),
          title: Text(
            list.name,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            '${list.checkedCount}/${list.items.length} items done',
          ),
          trailing: FilledButton.tonal(
            onPressed: () => context.push('/lists/${list.id}/optimize'),
            child: const Text('Optimize'),
          ),
          onTap: () => context.push('/lists/${list.id}'),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.receipt_long_rounded, 'Scan receipt', '/receipts/scan'),
      (Icons.auto_awesome_rounded, 'AI assistant', '/assistant'),
      (Icons.restaurant_menu_rounded, 'Meal planner', '/meal-planner'),
      (Icons.local_offer_rounded, 'Coupons', '/coupons'),
      (Icons.kitchen_rounded, 'Pantry', '/pantry'),
      (Icons.search_rounded, 'Products', '/products'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Quick actions'),
        GridView.count(
          crossAxisCount: context.isTablet ? 6 : 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            for (final (icon, label, route) in actions)
              Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.push(route),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 28, color: context.colors.primary),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        style: context.text.labelMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _OffersPreview extends ConsumerWidget {
  const _OffersPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offers = ref.watch(activeOffersProvider).value ?? [];
    if (offers.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Deals near you',
          actionLabel: 'See all',
          onAction: () => context.push('/offers'),
        ),
        SizedBox(
          height: 130,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: offers.length.clamp(0, 5),
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final offer = offers[i];
              return SizedBox(
                width: 220,
                child: Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.push('/offers'),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.local_offer_rounded,
                                size: 16,
                                color: context.colors.primary,
                              ),
                              const SizedBox(width: 6),
                              if (offer.discountPercent != null)
                                Text(
                                  '${offer.discountPercent!.round()}% off',
                                  style: context.text.labelMedium?.copyWith(
                                    color: context.colors.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            offer.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Ends ${Formatters.relativeDays(offer.validTo)}',
                            style: context.text.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
