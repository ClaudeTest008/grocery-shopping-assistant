import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/stripe_service.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/async_value_widget.dart';
import '../../authentication/data/auth_repositories.dart';
import '../../stores/data/store_repositories.dart';
import '../../stores/domain/store.dart';
import '../data/preferences_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  String _initials(String? name, String email) {
    final source = (name != null && name.trim().isNotEmpty) ? name : email;
    final parts = source.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return source.isNotEmpty ? source[0].toUpperCase() : '?';
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You can sign back in at any time.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authRepositoryProvider).signOut();
    }
  }

  void _openFavoriteStores(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _FavoriteStoresSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final colors = context.colors;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: colors.primaryContainer,
                backgroundImage: user.avatarUrl != null
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: user.avatarUrl == null
                    ? Text(
                        _initials(user.displayName, user.email),
                        style: context.text.titleLarge?.copyWith(
                          color: colors.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName ?? user.email,
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      user.email,
                      style: context.text.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Settings'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/settings'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.storefront_outlined),
                  title: const Text('Favorite stores'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _openFavoriteStores(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _PremiumCard(isPremium: user.isPremium),
          const SizedBox(height: 16),
          Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: Icon(Icons.logout_rounded, color: colors.error),
              title: Text('Sign out', style: TextStyle(color: colors.error)),
              onTap: () => _confirmSignOut(context, ref),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard({required this.isPremium});

  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Card(
      color: colors.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.workspace_premium_rounded,
                  color: colors.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  isPremium ? 'Premium' : 'Upgrade to Premium',
                  style: context.text.titleMedium?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isPremium
                  ? "You're enjoying unlimited AI meal planning and price "
                        'predictions.'
                  : 'Unlock unlimited AI meal suggestions, price-drop '
                        'predictions, and priority support.',
              style: context.text.bodyMedium?.copyWith(
                color: colors.onPrimaryContainer,
              ),
            ),
            if (!isPremium) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => StripeService.presentPaywall(context),
                child: const Text('Upgrade'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FavoriteStoresSheet extends ConsumerWidget {
  const _FavoriteStoresSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storesAsync = ref.watch(nearbyStoresProvider);
    final prefs = ref.watch(preferencesProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Favorite stores',
              style: context.text.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.5,
              ),
              child: AsyncValueWidget<List<Store>>(
                value: storesAsync,
                onRetry: () => ref.invalidate(nearbyStoresProvider),
                data: (stores) => ListView(
                  shrinkWrap: true,
                  children: [
                    for (final store in stores)
                      CheckboxListTile(
                        title: Text(store.name),
                        subtitle: Text(store.address),
                        value: prefs.favoriteStoreIds.contains(store.id),
                        onChanged: (checked) {
                          final ids = [...prefs.favoriteStoreIds];
                          if (checked ?? false) {
                            ids.add(store.id);
                          } else {
                            ids.remove(store.id);
                          }
                          ref
                              .read(preferencesProvider.notifier)
                              .update(prefs.copyWith(favoriteStoreIds: ids));
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
