import 'package:intl/intl.dart';

abstract final class Formatters {
  /// Set once at boot (and on country switch) from the selected
  /// country — every unlabeled amount in the app renders in it.
  static String defaultCurrency = 'USD';

  static String currency(num amount, {String? code}) =>
      NumberFormat.simpleCurrency(name: code ?? defaultCurrency).format(amount);

  /// `€2.49 / kg`, `$0.12 / oz`
  static String unitPrice(num amount, String unit, {String? code}) =>
      '${currency(amount, code: code)} / $unit';

  static String date(DateTime d) => DateFormat.yMMMd().format(d);

  static String shortDate(DateTime d) => DateFormat.Md().format(d);

  static String weekday(DateTime d) => DateFormat.EEEE().format(d);

  static String time(DateTime d) => DateFormat.jm().format(d);

  static String relativeDays(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(d.year, d.month, d.day);
    final diff = target.difference(today).inDays;
    return switch (diff) {
      < 0 => '${-diff}d ago',
      0 => 'Today',
      1 => 'Tomorrow',
      < 7 => 'In $diff days',
      _ => date(d),
    };
  }

  static String distanceKm(double km) =>
      km < 1 ? '${(km * 1000).round()} m' : '${km.toStringAsFixed(1)} km';

  static String duration(Duration d) {
    if (d.inMinutes < 60) return '${d.inMinutes} min';
    return '${d.inHours}h ${d.inMinutes % 60}m';
  }

  /// Raw data keys ('gluten_free', 'dairy') rendered as UI labels
  /// ('Gluten Free', 'Dairy') — chips and legends must not read like
  /// debug output.
  static String titleCase(String raw) => raw
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}
