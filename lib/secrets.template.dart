/// Stores opaquely-defined secrets so they can be overridden via build-time defines.
/// This is a template file - copy to secrets.dart and fill in your actual values.
///
/// IMPORTANT: Never commit secrets.dart to version control!
class AppSecrets {
  AppSecrets._();

  /// Key for OpenWeatherMap (set with `--dart-define=OPENWEATHER_API_KEY=...`).
  /// Get your free API key from: https://openweathermap.org/api
  static const openWeatherApiKey = String.fromEnvironment('OPENWEATHER_API_KEY');
}