import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/formatters.dart';
import '../../../shared/data/notification_repository.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/models/app_notification.dart';
import '../../../shared/widgets/async_value_widget.dart';
import '../../../shared/widgets/empty_state.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(notificationRepositoryProvider).markAllRead();
              ref.invalidate(notificationsProvider);
            },
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: AsyncValueWidget(
        value: notifications,
        onRetry: () => ref.invalidate(notificationsProvider),
        data: (items) => items.isEmpty
            ? const EmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'All caught up',
                message:
                    'Price drops, expiring coupons, and reminders '
                    'show up here.',
              )
            : ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final n = items[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: n.read
                          ? context.colors.surfaceContainerHighest
                          : context.colors.primaryContainer,
                      child: Icon(
                        _icon(n.type),
                        size: 20,
                        color: n.read
                            ? context.colors.onSurfaceVariant
                            : context.colors.onPrimaryContainer,
                      ),
                    ),
                    title: Text(
                      n.title,
                      style: TextStyle(
                        fontWeight: n.read ? FontWeight.w400 : FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(n.body),
                    trailing: Text(
                      Formatters.relativeDays(n.createdAt),
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    onTap: () async {
                      await ref
                          .read(notificationRepositoryProvider)
                          .markRead(n.id);
                      ref.invalidate(notificationsProvider);
                      if (n.route != null && context.mounted) {
                        await context.push(n.route!);
                      }
                    },
                  );
                },
              ),
      ),
    );
  }

  IconData _icon(NotificationType type) => switch (type) {
    NotificationType.priceDrop => Icons.trending_down_rounded,
    NotificationType.couponExpiring => Icons.local_offer_rounded,
    NotificationType.sale => Icons.campaign_rounded,
    NotificationType.shoppingReminder => Icons.checklist_rounded,
    NotificationType.nearbyOffer => Icons.near_me_rounded,
    NotificationType.pantryExpiring => Icons.kitchen_rounded,
    NotificationType.general => Icons.notifications_rounded,
  };
}
