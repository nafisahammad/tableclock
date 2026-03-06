# tableclock

A new Flutter project.

## Setup

### Weather API

This app uses OpenWeatherMap for weather data. To enable weather functionality:

1. Get a free API key from [OpenWeatherMap](https://openweathermap.org/api)
2. Copy `lib/secrets.template.dart` to `lib/secrets.dart`
3. Run the app with your API key:
   ```bash
   flutter run --dart-define=OPENWEATHER_API_KEY=your_api_key_here
   ```

**Important:** Never commit `lib/secrets.dart` to version control as it contains your API key.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
