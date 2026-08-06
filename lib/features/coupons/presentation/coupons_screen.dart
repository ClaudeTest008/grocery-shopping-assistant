import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/observability/telemetry.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/async_value_widget.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_header.dart';
import '../data/coupon_repositories.dart';
import '../domain/coupon.dart';

String _valueLabel(Coupon coupon) {
  if (coupon.discountAmount != null) {
    return '${Formatters.currency(coupon.discountAmount!)} off';
  }
  if (coupon.discountPercent != null) {
    return '${coupon.discountPercent!.toStringAsFixed(0)}% off';
  }
  return '';
}

class CouponsScreen extends ConsumerWidget {
  const CouponsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couponsAsync = ref.watch(couponsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Coupons')),
      body: AsyncValueWidget<List<Coupon>>(
        value: couponsAsync,
        onRetry: () => ref.invalidate(couponsProvider),
        data: (coupons) {
          if (coupons.isEmpty) {
            return const EmptyState(
              icon: Icons.confirmation_number_outlined,
              title: 'No coupons available',
              message: 'Check back later for new savings.',
            );
          }
          final clipped = coupons.where((c) => c.clipped).toList();
          final available = coupons.where((c) => !c.clipped).toList();
          return ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              // The coupon→optimizer link is invisible otherwise: "Clip"
              // alone never says what clipping is for.
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(
                  'Clipped coupons are applied automatically when we '
                  'price your trip.',
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
              if (clipped.isNotEmpty) ...[
                const SectionHeader(title: 'Clipped'),
                for (final coupon in clipped) _CouponCard(coupon: coupon),
              ],
              if (available.isNotEmpty) ...[
                const SectionHeader(title: 'Available'),
                for (final coupon in available) _CouponCard(coupon: coupon),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _CouponCard extends ConsumerWidget {
  const _CouponCard({required this.coupon});

  final Coupon coupon;

  Future<void> _toggleClip(WidgetRef ref) async {
    await ref
        .read(couponRepositoryProvider)
        .setClipped(coupon.id, !coupon.clipped);
    Telemetry.logEvent('coupon_clipped', {'clipped': !coupon.clipped});
    ref.invalidate(couponsProvider);
  }

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: coupon.code!));
    context.showSnack('Code copied');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coupon.title,
                    style: context.text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _valueLabel(coupon),
                    style: context.text.bodyMedium?.copyWith(
                      color: colors.primary,
                    ),
                  ),
                  if (coupon.minSpend != null)
                    Text(
                      'Min spend ${Formatters.currency(coupon.minSpend!)}',
                      style: context.text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  Text(
                    'Expires ${Formatters.relativeDays(coupon.expiresAt)}',
                    style: context.text.bodySmall?.copyWith(
                      color: coupon.expiresSoon
                          ? colors.error
                          : colors.onSurfaceVariant,
                      fontWeight: coupon.expiresSoon ? FontWeight.w700 : null,
                    ),
                  ),
                  if (coupon.code != null) ...[
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () => _copyCode(context),
                      child: Chip(
                        label: Text(
                          coupon.code!,
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                        avatar: const Icon(Icons.copy_outlined, size: 16),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonal(
              onPressed: () => _toggleClip(ref),
              child: Text(coupon.clipped ? 'Unclip' : 'Clip'),
            ),
          ],
        ),
      ),
    );
  }
}
