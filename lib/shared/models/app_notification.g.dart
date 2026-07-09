// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    _AppNotification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type:
          $enumDecodeNullable(_$NotificationTypeEnumMap, json['type']) ??
          NotificationType.general,
      title: json['title'] as String,
      body: json['body'] as String,
      route: json['route'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      read: json['read'] as bool? ?? false,
    );

Map<String, dynamic> _$AppNotificationToJson(_AppNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'title': instance.title,
      'body': instance.body,
      'route': instance.route,
      'created_at': instance.createdAt.toIso8601String(),
      'read': instance.read,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.priceDrop: 'priceDrop',
  NotificationType.couponExpiring: 'couponExpiring',
  NotificationType.sale: 'sale',
  NotificationType.shoppingReminder: 'shoppingReminder',
  NotificationType.nearbyOffer: 'nearbyOffer',
  NotificationType.pantryExpiring: 'pantryExpiring',
  NotificationType.general: 'general',
};
