import 'dart:async';
import 'dart:math';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_android_volume_keydown/flutter_android_volume_keydown.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:weather/weather.dart';

import 'secrets.dart';
import 'widgets/clock_widget.dart';

class ClockScreen extends StatefulWidget {
  const ClockScreen({super.key});

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen>
    with WidgetsBindingObserver {
  static const double _minBrightness = 0.1;
  static const double _maxBrightness = 1.0;
  static const double _brightnessStep = 0.1;
  static const int _burnInRange = 40;
  static const Duration _burnInInterval = Duration(seconds: 60);
  static const Duration _triplePressWindow = Duration(milliseconds: 700);
  static const String _weatherApiKey = AppSecrets.openWeatherApiKey;
  static const String _weatherCity = 'Barisal,BD';
  static const Duration _weatherUpdateInterval = Duration(minutes: 30);

  final Battery _battery = Battery();
  final Random _random = Random();
  final List<int> _volumeDownTimes = <int>[];

  StreamSubscription<BatteryState>? _batteryStateSub;
  StreamSubscription<HardwareButton>? _volumeSub;
  Timer? _burnInTimer;
  Timer? _batteryTimer;
  Timer? _dateTimer;
  Timer? _weatherTimer;
  Timer? _weatherFetchTimer;
  WeatherFactory? _weatherFactory;
  _WeatherInfo? _weatherInfo;

  int? _batteryLevel;
  double _brightness = 1.0;
  Offset _offset = Offset.zero;
  bool _showBattery = false;
  bool _showDate = false;
  bool _showWeather = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _enableImmersiveMode();
    _enableWakelock();
    _listenToBattery();
    _listenToVolumeButtons();
    _setupWeather();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _burnInTimer?.cancel();
    _batteryTimer?.cancel();
    _dateTimer?.cancel();
    _weatherTimer?.cancel();
    _weatherFetchTimer?.cancel();
    _batteryStateSub?.cancel();
    _volumeSub?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _enableImmersiveMode();
      _enableWakelock();
    }
  }

  Future<void> _enableWakelock() async {
    await WakelockPlus.enable();
  }

  Future<void> _enableImmersiveMode() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _startBurnInTimer() {
    _burnInTimer = Timer.periodic(_burnInInterval, (_) {
      setState(() {
        _offset = Offset(
          _randomOffset(),
          _randomOffset(),
        );
      });
    });
  }

  double _randomOffset() {
    return (_random.nextInt(_burnInRange * 2 + 1) - _burnInRange).toDouble();
  }

  void _listenToBattery() {
    _refreshBatteryLevel();
    _batteryStateSub = _battery.onBatteryStateChanged.listen((_) {
      _refreshBatteryLevel();
    });
  }

  Future<void> _refreshBatteryLevel() async {
    final level = await _battery.batteryLevel;
    if (!mounted) return;
    setState(() {
      _batteryLevel = level;
    });
  }

  void _listenToVolumeButtons() {
    _volumeSub = FlutterAndroidVolumeKeydown.stream.listen((event) {
      if (event == HardwareButton.volume_up) {
        _updateBrightness(_brightness + _brightnessStep);
      } else if (event == HardwareButton.volume_down) {
        _updateBrightness(_brightness - _brightnessStep);
        _handleTriplePressExit();
      }
    });
  }

  void _updateBrightness(double value) {
    final clamped = value.clamp(_minBrightness, _maxBrightness);
    if (clamped == _brightness) return;
    setState(() {
      _brightness = clamped;
    });
  }

  void _handleTriplePressExit() {
    final now = DateTime.now().millisecondsSinceEpoch;
    _volumeDownTimes.add(now);
    final cutoff = now - _triplePressWindow.inMilliseconds;
    _volumeDownTimes.removeWhere((time) => time < cutoff);
    if (_volumeDownTimes.length >= 3) {
      _volumeDownTimes.clear();
      SystemNavigator.pop();
    }
  }

  void _setupWeather() {
    if (_weatherApiKey.isEmpty) {
      debugPrint(
        'OpenWeather API key not provided (OPENWEATHER_API_KEY); '
        'skipping weather refresh.',
      );
      return;
    }
    _weatherFactory = WeatherFactory(_weatherApiKey);
    _refreshWeatherInfo();
    _weatherFetchTimer = Timer.periodic(_weatherUpdateInterval, (_) {
      _refreshWeatherInfo();
    });
  }

  Future<void> _refreshWeatherInfo() async {
    final factory = _weatherFactory;
    if (factory == null) return;
    try {
    final weather = await factory.currentWeatherByCityName(_weatherCity);
      if (!mounted) return;
      setState(() {
        _weatherInfo = _WeatherInfo.fromWeather(weather, _weatherCity);
      });
    } catch (error) {
      debugPrint('Failed to refresh weather: $error');
      if (!mounted) return;
      setState(() {
        _weatherInfo = _WeatherInfo.error();
      });
    }
  }

  void _showBatteryTemporarily() {
    _batteryTimer?.cancel();
    setState(() {
      _showBattery = true;
    });
    _batteryTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _showBattery = false;
      });
    });
  }

  void _showDateTemporarily() {
    _dateTimer?.cancel();
    setState(() {
      _showDate = true;
    });
    _dateTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _showDate = false;
      });
    });
  }

  void _showWeatherTemporarily() {
    _weatherTimer?.cancel();
    setState(() {
      _showWeather = true;
    });
    _weatherTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _showWeather = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: false,
        bottom: false,
        left: false,
        right: false,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            transform: Matrix4.translationValues(
              _offset.dx,
              _offset.dy,
              0,
            ),
            child: Opacity(
              opacity: _brightness,
              child: ClockWidget(
                batteryLevel: _batteryLevel,
                showBattery: _showBattery,
                showDate: _showDate,
                showWeather: _showWeather,
                onBatteryTap: _showBatteryTemporarily,
                onDateTap: _showDateTemporarily,
                onWeatherTap: _showWeatherTemporarily,
                weatherLabel: _weatherInfo?.summary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

@immutable
class _WeatherInfo {
  const _WeatherInfo(this.summary);

  final String summary;

  factory _WeatherInfo.fromWeather(Weather weather, String fallbackCity) {
    final area = weather.areaName;
    final city = (area?.isNotEmpty == true) ? area! : fallbackCity;
    final countrySuffix = (weather.country?.isNotEmpty == true)
        ? ', ${weather.country!}'
        : '';
    final location = '$city$countrySuffix';
    final description =
        weather.weatherDescription ?? weather.weatherMain ?? 'Weather';
    final temperature = weather.temperature?.celsius;
    final tempLabel =
        (temperature != null) ? '${temperature.toStringAsFixed(0)}°C' : '--°';
    return _WeatherInfo('$location · $tempLabel · $description');
  }

  factory _WeatherInfo.error() => const _WeatherInfo('Weather unavailable');
}
