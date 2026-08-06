import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/formatters.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/async_value_widget.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../profile/data/preferences_repository.dart';
import '../../receipts/data/receipt_repositories.dart';

const _monthInitials = [
  'J',
  'F',
  'M',
  'A',
  'M',
  'J',
  'J',
  'A',
  'S',
  'O',
  'N',
  'D',
];

typedef _MonthTotal = ({DateTime month, double total});

class _Analytics {
  const _Analytics({
    required this.thisMonthSpend,
    required this.monthlyBudget,
    required this.monthlyTotals,
    required this.categoryTotals,
  });

  final double thisMonthSpend;
  final double? monthlyBudget;
  final List<_MonthTotal> monthlyTotals;
  final Map<String, double> categoryTotals;
}

final _insightsProvider = FutureProvider<_Analytics>((ref) async {
  final receipts = await ref.watch(receiptRepositoryProvider).receipts();
  final prefs = ref.watch(preferencesProvider);
  final now = DateTime.now();

  final monthlyTotals = <_MonthTotal>[
    for (var i = 5; i >= 0; i--)
      (
        month: DateTime(now.year, now.month - i),
        total: receipts
            .where(
              (r) =>
                  r.purchasedAt.year ==
                      DateTime(now.year, now.month - i).year &&
                  r.purchasedAt.month ==
                      DateTime(now.year, now.month - i).month,
            )
            .fold(0.0, (sum, r) => sum + r.total),
      ),
  ];

  final thisMonthReceipts = receipts.where(
    (r) => r.purchasedAt.year == now.year && r.purchasedAt.month == now.month,
  );
  final thisMonthSpend = thisMonthReceipts.fold(0.0, (sum, r) => sum + r.total);

  final categoryTotals = <String, double>{};
  for (final r in thisMonthReceipts) {
    for (final item in r.items) {
      final cat = item.category ?? 'other';
      categoryTotals[cat] = (categoryTotals[cat] ?? 0) + item.price;
    }
  }

  return _Analytics(
    thisMonthSpend: thisMonthSpend,
    monthlyBudget: prefs.monthlyBudget,
    monthlyTotals: monthlyTotals,
    categoryTotals: categoryTotals,
  );
});

/// Fits y = a + bx over the monthly totals via ordinary least squares.
({double predicted, bool trendUp, bool enoughData}) _forecast(
  List<_MonthTotal> totals,
) {
  final monthsWithData = totals.where((t) => t.total > 0).length;
  if (monthsWithData < 2) {
    return (predicted: 0, trendUp: false, enoughData: false);
  }
  final n = totals.length;
  final xs = [for (var i = 0; i < n; i++) i.toDouble()];
  final ys = [for (final t in totals) t.total];
  final sumX = xs.fold(0.0, (a, b) => a + b);
  final sumY = ys.fold(0.0, (a, b) => a + b);
  var sumXY = 0.0, sumX2 = 0.0;
  for (var i = 0; i < n; i++) {
    sumXY += xs[i] * ys[i];
    sumX2 += xs[i] * xs[i];
  }
  final denom = n * sumX2 - sumX * sumX;
  if (denom == 0) {
    return (predicted: ys.last, trendUp: false, enoughData: true);
  }
  final b = (n * sumXY - sumX * sumY) / denom;
  final a = (sumY - b * sumX) / n;
  final predicted = a + b * n;
  return (
    predicted: predicted < 0 ? 0 : predicted,
    trendUp: b > 0,
    enoughData: true,
  );
}

List<Color> _palette(ColorScheme c) => [
  c.primary,
  c.secondary,
  c.tertiary,
  c.error,
  c.primaryContainer,
  c.secondaryContainer,
  c.tertiaryContainer,
  c.outline,
];

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(_insightsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: AsyncValueWidget(
        value: analyticsAsync,
        onRetry: () => ref.invalidate(_insightsProvider),
        data: (a) {
          final hasData =
              a.categoryTotals.isNotEmpty ||
              a.monthlyTotals.any((t) => t.total > 0);
          if (!hasData) {
            return EmptyState(
              icon: Icons.insights_rounded,
              title: 'No receipts yet',
              message: 'Scan a receipt to see your spending insights.',
              actionLabel: 'Scan receipt',
              onAction: () => context.push('/receipts/scan'),
            );
          }
          return _InsightsBody(analytics: a);
        },
      ),
    );
  }
}

class _InsightsBody extends StatelessWidget {
  const _InsightsBody({required this.analytics});

  final _Analytics analytics;

  @override
  Widget build(BuildContext context) {
    final forecast = _forecast(analytics.monthlyTotals);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _BudgetCard(analytics: analytics),
        const SizedBox(height: 16),
        _ChartCard(
          title: 'Monthly spending',
          child: _MonthlyBarChart(totals: analytics.monthlyTotals),
        ),
        const SizedBox(height: 16),
        _ChartCard(
          title: 'By category',
          child: _CategoryPieChart(categoryTotals: analytics.categoryTotals),
        ),
        const SizedBox(height: 16),
        _ForecastCard(forecast: forecast),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: context.text.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.analytics});

  final _Analytics analytics;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final budget = analytics.monthlyBudget;
    final overBudget = budget != null && analytics.thisMonthSpend > budget;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This month',
              style: context.text.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  Formatters.currency(analytics.thisMonthSpend),
                  style: context.text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: overBudget ? colors.error : colors.primary,
                  ),
                ),
                if (budget != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    'of ${Formatters.currency(budget)}',
                    style: context.text.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            if (budget != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (analytics.thisMonthSpend / budget)
                      .clamp(0.0, 1.0)
                      .toDouble(),
                  minHeight: 8,
                  backgroundColor: colors.surfaceContainerHigh,
                  color: overBudget ? colors.error : colors.primary,
                ),
              )
            else
              InkWell(
                onTap: () => context.push('/settings'),
                child: Text(
                  'Set a monthly budget in Settings to track progress.',
                  style: context.text.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyBarChart extends StatelessWidget {
  const _MonthlyBarChart({required this.totals});

  final List<_MonthTotal> totals;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final maxTotal = totals.fold(0.0, (m, t) => t.total > m ? t.total : m);
    final maxY = maxTotal <= 0 ? 10.0 : maxTotal * 1.2;
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          barTouchData: const BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= totals.length) return const SizedBox();
                  final letter = _monthInitials[totals[idx].month.month - 1];
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      letter,
                      style: context.text.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < totals.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: totals[i].total,
                    color: colors.primary,
                    width: 18,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPieChart extends StatelessWidget {
  const _CategoryPieChart({required this.categoryTotals});

  final Map<String, double> categoryTotals;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (categoryTotals.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'No purchases recorded this month.',
            style: context.text.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    final entries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold(0.0, (sum, e) => sum + e.value);
    final palette = _palette(colors);

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                for (var i = 0; i < entries.length; i++)
                  PieChartSectionData(
                    value: entries[i].value,
                    color: palette[i % palette.length],
                    radius: 56,
                    title: total == 0
                        ? ''
                        : '${(entries[i].value / total * 100).round()}%',
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            for (var i = 0; i < entries.length; i++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: palette[i % palette.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${Formatters.titleCase(entries[i].key)} · ${Formatters.currency(entries[i].value)}',
                    style: context.text.labelMedium,
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _ForecastCard extends StatelessWidget {
  const _ForecastCard({required this.forecast});

  final ({double predicted, bool trendUp, bool enoughData}) forecast;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next month forecast',
                    style: context.text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (forecast.enoughData)
                    Text(
                      Formatters.currency(forecast.predicted),
                      style: context.text.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    )
                  else
                    Text(
                      'Add a couple months of receipts to see a forecast.',
                      style: context.text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (forecast.enoughData)
              Icon(
                forecast.trendUp
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: forecast.trendUp ? colors.error : colors.primary,
                size: 32,
              ),
          ],
        ),
      ),
    );
  }
}
