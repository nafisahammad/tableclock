import 'dart:async';

import 'package:flutter/material.dart';

import 'weather_widget.dart';

class ClockWidget extends StatefulWidget {
  const ClockWidget({
    super.key,
    this.batteryLevel,
    required this.showBattery,
    required this.showDate,
    required this.showWeather,
    required this.onBatteryTap,
    required this.onDateTap,
    required this.onWeatherTap,
    this.weatherLabel,
  });

  final int? batteryLevel;
  final bool showBattery;
  final bool showDate;
  final bool showWeather;
  final VoidCallback onBatteryTap;
  final VoidCallback onDateTap;
  final VoidCallback onWeatherTap;
  final String? weatherLabel;

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  Timer? _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final timeText = _formatTime(_now);
        final dateText = _formatDate(_now);
        final batteryText = widget.batteryLevel == null
            ? 'Battery --%'
            : 'Battery ${widget.batteryLevel}%';

        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        // Time font size - adjusted to fit on screen
        final timeFontSize = (width * 0.85).clamp(100.0, 400.0);

        final detailFontSize = (height * 0.055).clamp(22.0, 46.0);
        final batteryFontSize = (height * 0.045).clamp(18.0, 38.0);
        final cornerFontSize = (height * 0.04).clamp(16.0, 32.0);

        final timeStyle = TextStyle(
          fontFamily: 'DigitalDismay',
          color: Colors.white,
          fontSize: timeFontSize,
          fontWeight: FontWeight.normal,
          letterSpacing: 2.0,
        );
        final cornerStyle = TextStyle(
          fontFamily: 'Technology',
          color: Colors.white,
          fontSize: cornerFontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        );

        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [
              // Centered time (locked)
              Center(
                child: Text(
                  timeText,
                  style: timeStyle,
                  textAlign: TextAlign.center,
                ),
              ),

              // Top right: Battery
              Positioned(
                top: 16,
                right: 16,
                child: AnimatedOpacity(
                  opacity: widget.showBattery ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: GestureDetector(
                    onTap: widget.onBatteryTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.battery_full,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.batteryLevel ?? '--'}%',
                            style: cornerStyle,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom right: Date
              Positioned(
                bottom: 16,
                right: 16,
                child: AnimatedOpacity(
                  opacity: widget.showDate ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: GestureDetector(
                    onTap: widget.onDateTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _formatDate(_now),
                        style: cornerStyle,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom left: Weather
              Positioned(
                bottom: 16,
                left: 16,
                child: WeatherWidget(
                  visible: widget.showWeather,
                  onTap: widget.onWeatherTap,
                  text: widget.weatherLabel ?? 'Weather',
                  textStyle: cornerStyle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime now) {
    final hour24 = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour24:$minute';
  }

  String _formatDate(DateTime now) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final weekday = weekdays[now.weekday - 1];
    final month = months[now.month - 1];
    return '$weekday, $month ${now.day}';
  }
}
