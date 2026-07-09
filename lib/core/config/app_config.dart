/// Compile-time configuration via --dart-define.
///
/// Example:
/// ```
/// flutter run \
///   --dart-define=SUPABASE_URL=https://xyz.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=eyJ... \
///   --dart-define=LLM_PROVIDER=anthropic \
///   --dart-define=LLM_API_KEY=sk-ant-...
/// ```
///
/// When Supabase credentials are absent the app boots in demo mode:
/// every repository is backed by seeded in-memory/Hive data so the full
/// UX is explorable without any backend.
abstract final class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const googleMapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
  static const stripePublishableKey =
      String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');

  /// One of: `anthropic`, `openai`, `mock`.
  static const llmProvider =
      String.fromEnvironment('LLM_PROVIDER', defaultValue: 'mock');
  static const llmApiKey = String.fromEnvironment('LLM_API_KEY');
  static const llmModel = String.fromEnvironment('LLM_MODEL');

  static const sentryDsn = String.fromEnvironment('SENTRY_DSN');

  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static bool get hasStripe => stripePublishableKey.isNotEmpty;

  /// Demo mode: no backend configured, run on seeded local data.
  static bool get isDemoMode => !hasSupabase;

  static const appName = 'Grocery Shopping Assistant';

  /// Default assumptions used by the basket optimizer; user-overridable
  /// in preferences.
  static const defaultFuelCostPerKm = 0.12; // USD
  static const defaultMultiStoreSavingsThreshold = 2.0; // USD
}
