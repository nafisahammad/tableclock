import 'dart:async';

import 'package:flutter/material.dart';

class ClockWidget extends StatefulWidget {
  const ClockWidget({
    super.key,
    this.batteryLevel,
    required this.showDetails,
  });

  final int? batteryLevel;
  final bool showDetails;

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
        var timeFontSize = (width * 0.22).clamp(96.0, 220.0);
        if (!widget.showDetails) {
          timeFontSize = (timeFontSize * 2.5).clamp(140.0, width * 0.95);
        }
        final detailFontSize = (height * 0.055).clamp(22.0, 46.0);
        final batteryFontSize = (height * 0.045).clamp(18.0, 38.0);

        final timeStyle = TextStyle(
          fontFamily: 'Technology',
          color: Colors.white,
          fontSize: timeFontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.0,
        );
        final detailStyle = TextStyle(
          fontFamily: 'Technology',
          color: Colors.white,
          fontSize: detailFontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        );
        final batteryStyle = TextStyle(
          fontFamily: 'Technology',
          color: Colors.white,
          fontSize: batteryFontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        );

        return SizedBox(
          width: width,
          height: height,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: SizedBox(
              width: width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeText,
                    style: timeStyle,
                    textAlign: TextAlign.center,
                  ),
                  if (widget.showDetails) ...[
                    const SizedBox(height: 20),
                    Text(
                      dateText,
                      style: detailStyle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      batteryText,
                      style: batteryStyle,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime now) {
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
