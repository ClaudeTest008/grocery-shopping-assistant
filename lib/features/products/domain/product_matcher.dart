import 'product.dart';

/// Matches free text (a receipt line, a typed item) to a catalog
/// product. Deliberately conservative: recording a wrong price against a
/// product poisons its history, while skipping an unmatched line costs
/// nothing — so this only answers when the match is unambiguous.
abstract final class ProductMatcher {
  /// The single confident match for [rawName] among [candidates], or
  /// null. Confident means: exactly one candidate whose normalized name
  /// equals the text, or whose full name appears inside it (receipt
  /// lines carry noise like "GV WHOLE MILK 1GAL").
  static Product? confidentMatch(List<Product> candidates, String rawName) {
    final needle = _normalize(rawName);
    if (needle.length < 3) return null;

    final exact = candidates
        .where((p) => _normalize(p.name) == needle)
        .toList();
    if (exact.length == 1) return exact.first;
    if (exact.length > 1) return null;

    final contained = candidates.where((p) {
      final name = _normalize(p.name);
      return name.length >= 4 && needle.contains(name);
    }).toList();
    if (contained.length == 1) return contained.first;

    return null;
  }

  static String _normalize(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
