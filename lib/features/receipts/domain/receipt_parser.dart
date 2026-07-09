import 'package:uuid/uuid.dart';

import 'receipt.dart';

/// Heuristic parser turning raw OCR text into a structured [Receipt].
/// Pure Dart — unit-testable without ML Kit.
class ReceiptParser {
  const ReceiptParser();

  static const _uuid = Uuid();

  static final _priceLine =
      RegExp(r'^(.{2,40}?)\s+\$?(\d{1,4}[.,]\d{2})\s*[A-Z]?$');
  static final _totalLine = RegExp(
      r'(?:total|amount due|balance)\s*:?\s*\$?(\d{1,4}[.,]\d{2})',
      caseSensitive: false);
  static final _subtotalWords =
      RegExp(r'subtotal|sub-total|tax|change|cash|credit|debit|tend',
          caseSensitive: false);
  static final _date = RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})');

  static const _knownChains = {
    'aldi': 'Aldi',
    'walmart': 'Walmart',
    'wal-mart': 'Walmart',
    'kroger': 'Kroger',
    'target': 'Target',
    'h-e-b': 'H-E-B',
    'heb': 'H-E-B',
    'trader joe': "Trader Joe's",
    'costco': 'Costco',
    'safeway': 'Safeway',
    'publix': 'Publix',
  };

  Receipt parse(String ocrText, {required String userId}) {
    final lines = ocrText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final receiptId = _uuid.v4();
    String? storeName;
    double? total;
    DateTime? purchasedAt;
    final items = <ReceiptItem>[];

    // Store: first known chain mention, else first all-caps-ish header line.
    for (final line in lines.take(6)) {
      final lower = line.toLowerCase();
      for (final entry in _knownChains.entries) {
        if (lower.contains(entry.key)) {
          storeName = entry.value;
          break;
        }
      }
      if (storeName != null) break;
    }
    storeName ??= lines.isNotEmpty ? lines.first : null;

    for (final line in lines) {
      final totalMatch = _totalLine.firstMatch(line);
      if (totalMatch != null) {
        // Keep the LAST total-looking line (grand total follows subtotal).
        total = _num(totalMatch.group(1)!);
        continue;
      }
      final dateMatch = _date.firstMatch(line);
      if (dateMatch != null && purchasedAt == null) {
        purchasedAt = _parseDate(dateMatch);
      }
      if (_subtotalWords.hasMatch(line)) continue;
      final itemMatch = _priceLine.firstMatch(line);
      if (itemMatch != null) {
        final name = itemMatch.group(1)!.trim();
        // Skip lines that are clearly not products.
        if (name.length < 2 || _date.hasMatch(name)) continue;
        items.add(ReceiptItem(
          id: _uuid.v4(),
          receiptId: receiptId,
          name: _titleCase(name),
          price: _num(itemMatch.group(2)!),
        ));
      }
    }

    return Receipt(
      id: receiptId,
      userId: userId,
      storeName: storeName,
      total: total ?? items.fold(0.0, (sum, i) => sum + i.price),
      purchasedAt: purchasedAt ?? DateTime.now(),
      items: items,
    );
  }

  static double _num(String s) => double.parse(s.replaceAll(',', '.'));

  static DateTime? _parseDate(RegExpMatch m) {
    final a = int.parse(m.group(1)!);
    final b = int.parse(m.group(2)!);
    var year = int.parse(m.group(3)!);
    if (year < 100) year += 2000;
    // US receipts: MM/DD/YYYY.
    final month = a <= 12 ? a : b;
    final day = a <= 12 ? b : a;
    if (month > 12 || day > 31) return null;
    final parsed = DateTime(year, month, day);
    return parsed.isAfter(DateTime.now()) ? null : parsed;
  }

  static String _titleCase(String s) => s
      .toLowerCase()
      .split(' ')
      .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
      .join(' ');
}
