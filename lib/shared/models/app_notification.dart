import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_notification.freezed.dart';
part 'app_notification.g.dart';

enum NotificationType {
  priceDrop,
  couponExpiring,
  sale,
  shoppingReminder,
  nearbyOffer,
  pantryExpiring,
  general,
}

@freezed
abstract class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required String userId,
    @Default(NotificationType.general) NotificationType type,
    required String title,
    required String body,

    /// Deep-link route, e.g. /products/abc123.
    String? route,
    required DateTime createdAt,
    @Default(false) bool read,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}
