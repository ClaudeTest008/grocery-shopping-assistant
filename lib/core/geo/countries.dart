/// Country registry — THE definition of "supported country".
///
/// Everything country-specific in the app is data on one of these
/// configs: chains, demo city, currency, VAT, units, date order,
/// price level. Adding a country is adding an entry here plus
/// translations/seed content — never a business-logic change.
library;

/// One grocery chain within a country's demo dataset.
class ChainSpec {
  const ChainSpec(this.id, this.name, this.priceMultiplier);

  /// Stable id fragment ('mercadona'); store ids become
  /// `<country>-<chain>-<n>`.
  final String id;
  final String name;

  /// Relative price level vs the country baseline (discounters < 1).
  final double priceMultiplier;
}

class CountryConfig {
  const CountryConfig({
    required this.code,
    required this.name,
    required this.flag,
    required this.currency,
    required this.languages,
    required this.city,
    required this.lat,
    required this.lng,
    required this.chains,
    required this.vatRateFood,
    required this.pricesIncludeVat,
    required this.dmyDates,
    required this.units,
    required this.priceLevel,
  });

  /// ISO 3166-1 alpha-2.
  final String code;
  final String name;
  final String flag;

  /// ISO 4217.
  final String currency;

  /// Primary language first (drives localized product names).
  final List<String> languages;

  /// Demo city + its centre — map fallback and store generation anchor.
  final String city;
  final double lat;
  final double lng;

  final List<ChainSpec> chains;

  /// Reduced VAT rate applying to most groceries, as a fraction.
  final double vatRateFood;

  /// EU shelf prices include VAT; US shelf prices exclude sales tax.
  final bool pricesIncludeVat;

  /// Receipt dates: true = DD/MM/YYYY, false = MM/DD/YYYY.
  final bool dmyDates;

  /// 'metric' | 'imperial' — seeds the units preference.
  final String units;

  /// Cost-of-living factor applied to baseline demo prices.
  final double priceLevel;

  String get primaryLanguage => languages.first;
}

abstract final class Countries {
  static const all = <CountryConfig>[
    CountryConfig(
      code: 'ES',
      name: 'Spain',
      flag: '🇪🇸',
      currency: 'EUR',
      languages: ['es'],
      city: 'Madrid',
      lat: 40.4168,
      lng: -3.7038,
      chains: [
        ChainSpec('mercadona', 'Mercadona', 0.90),
        ChainSpec('carrefour', 'Carrefour', 1.02),
        ChainSpec('lidl', 'Lidl', 0.86),
        ChainSpec('aldi', 'Aldi', 0.87),
        ChainSpec('dia', 'Dia', 0.88),
        ChainSpec('alcampo', 'Alcampo', 0.96),
        ChainSpec('consum', 'Consum', 1.00),
        ChainSpec('eroski', 'Eroski', 1.04),
      ],
      vatRateFood: 0.10,
      pricesIncludeVat: true,
      dmyDates: true,
      units: 'metric',
      priceLevel: 0.92,
    ),
    CountryConfig(
      code: 'PT',
      name: 'Portugal',
      flag: '🇵🇹',
      currency: 'EUR',
      languages: ['pt'],
      city: 'Lisbon',
      lat: 38.7223,
      lng: -9.1393,
      chains: [
        ChainSpec('continente', 'Continente', 0.98),
        ChainSpec('pingodoce', 'Pingo Doce', 0.95),
        ChainSpec('auchan', 'Auchan', 1.00),
        ChainSpec('lidl', 'Lidl', 0.86),
        ChainSpec('aldi', 'Aldi', 0.87),
      ],
      vatRateFood: 0.06,
      pricesIncludeVat: true,
      dmyDates: true,
      units: 'metric',
      priceLevel: 0.88,
    ),
    CountryConfig(
      code: 'FR',
      name: 'France',
      flag: '🇫🇷',
      currency: 'EUR',
      languages: ['fr'],
      city: 'Paris',
      lat: 48.8566,
      lng: 2.3522,
      chains: [
        ChainSpec('carrefour', 'Carrefour', 1.02),
        ChainSpec('leclerc', 'E.Leclerc', 0.93),
        ChainSpec('intermarche', 'Intermarché', 0.97),
        ChainSpec('auchan', 'Auchan', 1.00),
        ChainSpec('monoprix', 'Monoprix', 1.22),
      ],
      vatRateFood: 0.055,
      pricesIncludeVat: true,
      dmyDates: true,
      units: 'metric',
      priceLevel: 1.08,
    ),
    CountryConfig(
      code: 'DE',
      name: 'Germany',
      flag: '🇩🇪',
      currency: 'EUR',
      languages: ['de'],
      city: 'Berlin',
      lat: 52.5200,
      lng: 13.4050,
      chains: [
        ChainSpec('edeka', 'Edeka', 1.05),
        ChainSpec('rewe', 'Rewe', 1.03),
        ChainSpec('kaufland', 'Kaufland', 0.92),
        ChainSpec('lidl', 'Lidl', 0.86),
        ChainSpec('aldinord', 'Aldi Nord', 0.85),
        ChainSpec('aldisued', 'Aldi Süd', 0.86),
      ],
      vatRateFood: 0.07,
      pricesIncludeVat: true,
      dmyDates: true,
      units: 'metric',
      priceLevel: 1.00,
    ),
    CountryConfig(
      code: 'IT',
      name: 'Italy',
      flag: '🇮🇹',
      currency: 'EUR',
      languages: ['it'],
      city: 'Milan',
      lat: 45.4642,
      lng: 9.1900,
      chains: [
        ChainSpec('esselunga', 'Esselunga', 1.06),
        ChainSpec('coop', 'Coop', 1.02),
        ChainSpec('conad', 'Conad', 1.00),
        ChainSpec('eurospin', 'Eurospin', 0.84),
      ],
      vatRateFood: 0.10,
      pricesIncludeVat: true,
      dmyDates: true,
      units: 'metric',
      priceLevel: 0.98,
    ),
    CountryConfig(
      code: 'NL',
      name: 'Netherlands',
      flag: '🇳🇱',
      currency: 'EUR',
      languages: ['nl'],
      city: 'Amsterdam',
      lat: 52.3676,
      lng: 4.9041,
      chains: [
        ChainSpec('albertheijn', 'Albert Heijn', 1.06),
        ChainSpec('jumbo', 'Jumbo', 1.00),
        ChainSpec('plus', 'PLUS', 1.03),
        ChainSpec('lidl', 'Lidl', 0.86),
      ],
      vatRateFood: 0.09,
      pricesIncludeVat: true,
      dmyDates: true,
      units: 'metric',
      priceLevel: 1.05,
    ),
    CountryConfig(
      code: 'BE',
      name: 'Belgium',
      flag: '🇧🇪',
      currency: 'EUR',
      languages: ['fr', 'nl'],
      city: 'Brussels',
      lat: 50.8503,
      lng: 4.3517,
      chains: [
        ChainSpec('colruyt', 'Colruyt', 0.92),
        ChainSpec('delhaize', 'Delhaize', 1.08),
        ChainSpec('carrefour', 'Carrefour', 1.02),
        ChainSpec('lidl', 'Lidl', 0.86),
      ],
      vatRateFood: 0.06,
      pricesIncludeVat: true,
      dmyDates: true,
      units: 'metric',
      priceLevel: 1.06,
    ),
    CountryConfig(
      code: 'IE',
      name: 'Ireland',
      flag: '🇮🇪',
      currency: 'EUR',
      languages: ['en'],
      city: 'Dublin',
      lat: 53.3498,
      lng: -6.2603,
      chains: [
        ChainSpec('tesco', 'Tesco', 1.00),
        ChainSpec('supervalu', 'SuperValu', 1.06),
        ChainSpec('dunnes', 'Dunnes Stores', 1.02),
        ChainSpec('lidl', 'Lidl', 0.86),
        ChainSpec('aldi', 'Aldi', 0.87),
      ],
      // Most staple foods are zero-rated in Ireland.
      vatRateFood: 0.0,
      pricesIncludeVat: true,
      dmyDates: true,
      units: 'metric',
      priceLevel: 1.12,
    ),
    // The US is deliberately just one more entry — not a special case.
    CountryConfig(
      code: 'US',
      name: 'United States',
      flag: '🇺🇸',
      currency: 'USD',
      languages: ['en'],
      city: 'Austin',
      lat: 30.2672,
      lng: -97.7431,
      chains: [
        ChainSpec('aldi', 'Aldi', 0.86),
        ChainSpec('walmart', 'Walmart', 0.92),
        ChainSpec('kroger', 'Kroger', 1.02),
        ChainSpec('target', 'Target', 1.06),
        ChainSpec('heb', 'H-E-B', 0.95),
        ChainSpec('traderjoes', "Trader Joe's", 1.10),
        ChainSpec('wholefoods', 'Whole Foods Market', 1.35),
        ChainSpec('costco', 'Costco', 0.88),
      ],
      // Shelf prices exclude sales tax; no VAT concept.
      vatRateFood: 0.0,
      pricesIncludeVat: false,
      dmyDates: false,
      units: 'imperial',
      priceLevel: 1.00,
    ),
  ];

  static CountryConfig byCode(String code) => all.firstWhere(
    (c) => c.code == code.toUpperCase(),
    orElse: () => fallback,
  );

  static bool supports(String code) =>
      all.any((c) => c.code == code.toUpperCase());

  /// Default when nothing is chosen and the device locale is not a
  /// supported country.
  static CountryConfig get fallback => byCode('US');
}
