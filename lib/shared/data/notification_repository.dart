import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/config/app_config.dart';
import '../../core/demo/demo_collection.dart';
import '../../core/demo/demo_seed.dart';
import '../../core/services/supabase_service.dart';
import '../../core/storage/local_store.dart';
import '../models/app_notification.dart';

abstract interface class NotificationRepository {
  Future<List<AppNotification>> notifications();

  Future<void> markRead(String id);

  Future<void> markAllRead();
}

class DemoNotificationRepository implements NotificationRepository {
  DemoNotificationRepository(LocalStore store)
      : _items = DemoCollection(
          store,
          'demo_notifications',
          fromJson: AppNotification.fromJson,
          toJson: (n) => n.toJson(),
          seed: _seed,
        );

  final DemoCollection<AppNotification> _items;

  static List<AppNotification> _seed() {
    const uuid = Uuid();
    final now = DateTime.now();
    AppNotification n(NotificationType type, String title, String body,
            String? route, int hoursAgo) =>
        AppNotification(
          id: uuid.v4(),
          userId: DemoSeed.demoUserId,
          type: type,
          title: title,
          body: body,
          route: route,
          createdAt: now.subtract(Duration(hours: hoursAgo)),
        );
    return [
      n(NotificationType.priceDrop, 'Price drop: Chicken Breast',
          'Now \$2.57/lb at Kroger — 22% below its 90-day average.',
          '/products/chicken', 2),
      n(NotificationType.couponExpiring, 'Coupon expires tomorrow',
          '50c off Peanut Butter at Walmart is about to expire.',
          '/coupons', 6),
      n(NotificationType.sale, 'Weekly ads are out',
          '5 new offers at stores near you.', '/offers', 26),
      n(NotificationType.pantryExpiring, 'Use your yogurt',
          'Greek Yogurt in your fridge expires in 2 days.', '/pantry', 30),
    ];
  }

  @override
  Future<List<AppNotification>> notifications() async => _items.load()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  @override
  Future<void> markRead(String id) async {
    final items = _items.load();
    final idx = items.indexWhere((n) => n.id == id);
    if (idx < 0) return;
    items[idx] = items[idx].copyWith(read: true);
    await _items.saveAll(items);
  }

  @override
  Future<void> markAllRead() async {
    await _items.saveAll(
        [for (final n in _items.load()) n.copyWith(read: true)]);
  }
}

class SupabaseNotificationRepository implements NotificationRepository {
  SupabaseNotificationRepository(this._client);

  final SupabaseClient _client;

  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<List<AppNotification>> notifications() async {
    final rows = await _client
        .from('notifications')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false)
        .limit(100);
    return rows.map(AppNotification.fromJson).toList();
  }

  @override
  Future<void> markRead(String id) =>
      _client.from('notifications').update({'read': true}).eq('id', id);

  @override
  Future<void> markAllRead() => _client
      .from('notifications')
      .update({'read': true}).eq('user_id', _userId);
}

final notificationRepositoryProvider =
    Provider<NotificationRepository>((ref) {
  if (AppConfig.isDemoMode) {
    return DemoNotificationRepository(ref.watch(localStoreProvider));
  }
  return SupabaseNotificationRepository(ref.watch(supabaseClientProvider));
});

final notificationsProvider = FutureProvider<List<AppNotification>>(
  (ref) => ref.watch(notificationRepositoryProvider).notifications(),
);
